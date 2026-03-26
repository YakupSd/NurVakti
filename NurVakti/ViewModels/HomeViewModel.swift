import Foundation
import Combine
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    // Services
    private let prayerService: PrayerTimeService
    private let locationService: LocationService
    private let bgService: BackgroundGradientService
    private let notifService: NotificationService
    private let persistService: PersistenceService
    
    // Published state
    @Published var todayPrayers: PrayerTime?
    @Published var nextPrayer: (name: PrayerName, time: Date)?
    @Published var countdown: String = "00:00:00"
    @Published var currentTheme: PrayerTheme = .ishaTheme
    @Published var cityName: String = ""
    @Published var hijriText: String = ""
    @Published var completedPrayers: Int = 0
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var dailyGuidance: GuidanceItem? = nil
    @Published var prayerProgress: [PrayerName: Double] = [:]
    @Published var remTimeStrings: [PrayerName: String] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private var hasAppeared = false
    
    init(prayerService: PrayerTimeService? = nil,
         locationService: LocationService? = nil,
         bgService: BackgroundGradientService? = nil,
         notifService: NotificationService? = nil,
         persistService: PersistenceService? = nil) {
        self.prayerService = prayerService ?? PrayerTimeService()
        self.locationService = locationService ?? LocationService()
        self.bgService = bgService ?? BackgroundGradientService()
        self.notifService = notifService ?? .shared
        self.persistService = persistService ?? .shared
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Location binding
        locationService.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                Task { await self?.handleLocationUpdate(location) }
            }
            .store(in: &cancellables)
            
        // Saniyede bir bağımsız timer — prayerService.nextPrayer'a değil,
        // kendi nextPrayer'ına bakıyor; cache'den yüklenince de çalışır
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCountdown()
            }
            .store(in: &cancellables)
            
        // Service'ten gelen temayı VM temasına bağla
        bgService.$currentTheme
            .assign(to: &$currentTheme)
    }
    
    func onAppear() async {
        // Sayfa geri dönüşlerinde mevcut prayer verisini uygula (timer için)
        if hasAppeared {
            if let cached = prayerService.loadCached(for: Date()) {
                applyPrayers(cached)
            }
            return
        }
        hasAppeared = true
        
        // 1. Önce cache kontrolü
        if let cached = prayerService.loadCached(for: Date()) {
            applyPrayers(cached)
            let city = (cached.cityName.isEmpty) ? persistService.lastKnownCityName : cached.cityName
            self.cityName = city.isEmpty ? NSLocalizedString("general.calculating", comment: "") : city
            isLoading = false
        }
        
        // 2. Konum izni ve güncelleme başlat
        locationService.requestPermission()
        locationService.startUpdating()
        
        // 3. Eğer hala loading ise ve son bilinen konum varsa onu kullan
        if isLoading, let lastLoc = persistService.lastKnownLocation {
            await handleLocationUpdate(lastLoc, force: true)
        }
        
        self.dailyGuidance = GuidanceService.shared.getDailyGuidance(for: persistService.settings.language)
        
        languageDidChange(persistService.settings.language)
    }
    
    private func handleLocationUpdate(_ location: CLLocation, force: Bool = false) async {
        let lastLoc = persistService.lastKnownLocation
        // GÜNCELLEME: Kullanıcının yeni matematik formüllerini görmesi için mesafeyi zorla büyük tutuyoruz
        let distance = (force || lastLoc == nil) ? Double.greatestFiniteMagnitude : location.distance(from: lastLoc!)
        
        let settings = persistService.settings
        
        // 1. Mesafe kontrolü: 10km'den az değişim varsa ve bugün için vakitler varsa çekme
        if !force, distance < 10000 {
            if let cached = prayerService.loadCached(for: Date()) {
                applyPrayers(cached)
                let city = (cached.cityName.isEmpty) ? persistService.lastKnownCityName : cached.cityName
                self.cityName = city.isEmpty ? NSLocalizedString("general.calculating", comment: "") : city
                isLoading = false
                return
            }
        }
        
        // 2. Konum değiştiyse veya cache yoksa
        let resolvedCity = await locationService.resolveCity(for: location)
        let finalCity = (resolvedCity.isEmpty) ? persistService.lastKnownCityName : resolvedCity
        self.cityName = finalCity
        persistService.saveLastKnownLocation(location)
        if !resolvedCity.isEmpty {
            persistService.saveLastKnownCityName(resolvedCity)
        }
        
        // 30 günlük veriyi API'den çek (async)
        do {
            let monthlyPrayers = try await prayerService.calculateMonthly(
                for: location,
                method: settings.calculationMethod,
                madhab: settings.madhab
            )
            
            if let first = monthlyPrayers.first(where: { Calendar.current.isDateInToday($0.date) }) {
                // Struct immutable olduğu için city ismini manuel ekliyoruz
                let prayerWithCity = PrayerTime(
                    id: first.id,
                    date: first.date,
                    imsak: first.imsak,
                    fajr: first.fajr,
                    sunrise: first.sunrise,
                    dhuhr: first.dhuhr,
                    asr: first.asr,
                    maghrib: first.maghrib,
                    isha: first.isha,
                    cityName: finalCity,
                    hijriDate: first.hijriDate,
                    calculationMethod: first.calculationMethod
                )
                applyPrayers(prayerWithCity)
                
                // Bildirimleri planla
                await notifService.scheduleAll(prayers: monthlyPrayers, alarms: persistService.loadAlarms(), language: settings.language)
            }
        } catch {
            self.errorMessage = "Vakitler güncellenemedi: \(error.localizedDescription)"
            print("HomeViewModel: API Error — \(error)")
        }
        
        isLoading = false
    }
    
    private func applyPrayers(_ prayers: PrayerTime) {
        self.todayPrayers = prayers
        self.nextPrayer = prayerService.findNextPrayer(from: prayers)
        self.hijriText = prayers.hijriDate.formatted(for: persistService.settings.language)
        
        if let next = nextPrayer {
            bgService.updateTheme(prayers: prayers, currentTime: Date())
        }
    }
    
    func languageDidChange(_ code: LanguageCode) {
        if let prayers = todayPrayers {
            self.hijriText = prayers.hijriDate.formatted(for: code)
        }
        updateCountdown()
    }
    
    private func updateCountdown() {
        guard let next = nextPrayer else { return }
        let diff = next.time.timeIntervalSince(Date())
        
        if diff <= 0 {
            // Vakit değişti, yeniden hesapla
            if let prayers = todayPrayers {
                self.nextPrayer = prayerService.findNextPrayer(from: prayers)
            }
            return
        }
        
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        let seconds = Int(diff) % 60
        self.countdown = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
        // Tamamlanan vakit sayısını güncelle
        updateCompletedPrayersCount()
        
        // Bireysel vakit sayaçlarını ve progreslerini güncelle
        updateIndividualPrayerProgress()
    }
    
    private func updateIndividualPrayerProgress() {
        guard let prayers = todayPrayers else { return }
        let now = Date()
        var newProgress: [PrayerName: Double] = [:]
        var newRemStrings: [PrayerName: String] = [:]
        
        // Vakitlerin başlangıç/bitişlerini hesapla (basitleştirilmiş periyotlar)
        let periods: [(PrayerName, Date, Date)] = [
            (.imsak, prayers.imsak, prayers.fajr),
            (.fajr, prayers.fajr, prayers.sunrise),
            (.sunrise, prayers.sunrise, prayers.dhuhr),
            (.dhuhr, prayers.dhuhr, prayers.asr),
            (.asr, prayers.asr, prayers.maghrib),
            (.maghrib, prayers.maghrib, prayers.isha),
            (.isha, prayers.isha, prayers.imsak.addingTimeInterval(86400))
        ]
        
        for (name, start, end) in periods {
            if now >= start && now < end {
                let total = end.timeIntervalSince(start)
                let elapsed = now.timeIntervalSince(start)
                newProgress[name] = min(1.0, max(0.0, elapsed / total))
                
                let rem = end.timeIntervalSince(now)
                let h = Int(rem) / 3600
                let m = (Int(rem) % 3600) / 60
                newRemStrings[name] = String(format: "%02d:%02d", h, m)
            } else if now >= end {
                newProgress[name] = 1.0
            } else {
                newProgress[name] = 0.0
            }
        }
        
        self.prayerProgress = newProgress
        self.remTimeStrings = newRemStrings
    }
    
    private func updateCompletedPrayersCount() {
        guard let prayers = todayPrayers else { return }
        let now = Date()
        var count = 0
        if now > prayers.imsak { count += 1 }
        if now > prayers.fajr { count += 1 }
        if now > prayers.sunrise { count += 1 }
        if now > prayers.dhuhr { count += 1 }
        if now > prayers.asr { count += 1 }
        if now > prayers.maghrib { count += 1 }
        if now > prayers.isha { count += 1 }
        self.completedPrayers = count
    }
    
    func toggleNotification(for prayer: PrayerName) {
        var allAlarms = persistService.loadAlarms()
        
        if let index = allAlarms.firstIndex(where: { $0.prayerName == prayer }) {
            // Mevcut alarmı kapat/aç
            allAlarms[index].isActive.toggle()
        } else {
            // Yeni aktif alarm oluştur (varsayılan: 0 dk önce, ezan sesi)
            let newAlarm = AlarmModel(
                id: UUID(),
                prayerName: prayer,
                minutesBefore: 0,
                isActive: true,
                soundType: .ezan,
                repeatDays: []
            )
            allAlarms.append(newAlarm)
        }
        
        persistService.saveAlarms(allAlarms)
        
        // Bildirimleri sistemde güncelle
        if let monthly = prayerService.monthlyPrayers.isEmpty ? nil : prayerService.monthlyPrayers {
            Task {
                await notifService.scheduleAll(
                    prayers: monthly,
                    alarms: allAlarms,
                    language: persistService.settings.language
                )
            }
        }
        
        // UI'ı güncellemek için
        objectWillChange.send()
    }
    
    func isNotificationEnabled(for prayer: PrayerName) -> Bool {
        return persistService.loadAlarms().first(where: { $0.prayerName == prayer })?.isActive ?? false
    }
    
    func formattedTime(_ date: Date, language: LanguageCode) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = language.locale
        return formatter.string(from: date)
    }
}
