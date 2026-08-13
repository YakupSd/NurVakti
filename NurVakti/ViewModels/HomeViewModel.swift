import Foundation
import Combine
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    public static let shared = HomeViewModel()
    
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
    
    // NEW additions:
    @Published var dailyAyah: DailyContent = .placeholder
    @Published var dailyDua: DailyContent = .placeholder
    @Published var dhikrCount: Int = 0
    @Published var dhikrTarget: Int = 99
    @Published var dhikrProgress: Double = 0
    @Published var lastReadSurah: String = "Bakara · 2. Sure"
    @Published var qiblaDirectionText: String = "158° · Güneydoğu"
    @Published var nextReligiousDay: String = ""
    @Published var currentRoutineSlot: RoutineSlot = .none
    
    // UI Animation State
    @Published var sunPosition: Double = 0.5
    @Published var isNight: Bool = false
    
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
            
        // Saniyede bir bağımsız timer
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
        
        let settings = persistService.settings
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // CACHE-FIRST STRATEJİ
        // Önce 30 günlük cache'i kontrol et.
        // Cache geçerliyse API'ye hiç istek atma — anında yükle.
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        let currentLocation = persistService.lastKnownLocation
        let cacheValid = persistService.isCacheValid(
            for: currentLocation,
            method: settings.calculationMethod
        )
        
        if cacheValid {
            // ✅ Cache geçerli — API'ye istek ATMA, cache'ten anında yükle
            let cachedPrayers = persistService.loadPrayerCache()
            prayerService.loadMonthlyFromCache()
            
            if let today = cachedPrayers.first(where: { Calendar.current.isDateInToday($0.date) }) {
                let city = today.cityName.isEmpty ? persistService.lastKnownCityName : today.cityName
                self.cityName = city.isEmpty ? NSLocalizedString("general.calculating", comment: "") : city
                applyPrayers(today)
                
                // Bildirimleri planla
                Task {
                    await notifService.scheduleAll(
                        prayers: cachedPrayers,
                        alarms: persistService.loadAlarms(),
                        language: settings.language
                    )
                }
            }
            
            isLoading = false
            print("HomeViewModel: ✅ Cache'ten yüklendi (API çağrısı yapılmadı)")
        } else {
            // Cache yok veya geçersiz — bugün için varsa geçici göster
            if let cached = prayerService.loadCached(for: Date()) {
                applyPrayers(cached)
                let city = cached.cityName.isEmpty ? persistService.lastKnownCityName : cached.cityName
                self.cityName = city.isEmpty ? NSLocalizedString("general.calculating", comment: "") : city
                isLoading = false
            }
        }
        
        // Konum izni ve güncelleme başlat
        locationService.requestPermission()
        locationService.startUpdating()
        
        // Eğer hala loading ise ve son bilinen konum varsa onu kullan
        if isLoading, let lastLoc = persistService.lastKnownLocation {
            await handleLocationUpdate(lastLoc, force: true)
        }
        
        self.dailyGuidance = GuidanceService.shared.getDailyGuidance(for: settings.language)
        loadDailyContent(language: settings.language)
        
        updateNextReligiousDay(language: settings.language)
        updateRoutineSlot()
        updateDhikrStatus()
        updateReadingProgress()
        
        languageDidChange(settings.language)
    }
    
    func loadDailyContent(language: LanguageCode) {
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        Task {
            self.dailyAyah = DailyAyahProvider.ayah(for: dayIndex, language: language)
            self.dailyDua = DailyDuaProvider.dua(for: dayIndex, language: language)
        }
    }
    
    // MARK: - API Content Fetchers
    
    func loadDailyAyah(surah: Int, ayah: Int) async -> DailyContent {
        let editions = [
            "tr": "tr.diyanet",
            "en": "en.sahih", 
            "de": "de.aburida",
            "pt": "pt.elhayek",
            "ar": "ar.muyassar"
        ]
        
        var translations: [String: String] = [:]
        var arabicText = ""
        var source = ""
        
        await withTaskGroup(of: (String, String).self) { group in
            for (langCode, edition) in editions {
                group.addTask {
                    let url = URL(string: "https://api.alquran.cloud/v1/ayah/\(surah):\(ayah)/\(edition)")!
                    guard let (data, _) = try? await URLSession.shared.data(from: url),
                          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let dataObj = json["data"] as? [String: Any],
                          let text = dataObj["text"] as? String
                    else { return (langCode, "") }
                    return (langCode, text)
                }
            }
            
            for await (lang, text) in group {
                translations[lang] = text
            }
        }
        
        let url = URL(string: "https://api.alquran.cloud/v1/ayah/\(surah):\(ayah)/quran-uthmani")!
        if let (data, _) = try? await URLSession.shared.data(from: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let dataObj = json["data"] as? [String: Any],
           let text = dataObj["text"] as? String,
           let surahObj = dataObj["surah"] as? [String: Any],
           let surahName = surahObj["englishName"] as? String {
            arabicText = text
            source = "\(surahName), \(ayah)"
        }
        
        return DailyContent(
            id: UUID(),
            arabicText: arabicText,
            source: source,
            type: .ayat,
            translations: translations
        )
    }
    
    // MARK: - Konum Güncelleme (Akıllı Cache ile)
    private func handleLocationUpdate(_ location: CLLocation, force: Bool = false) async {
        let settings = persistService.settings
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // AKILLI CACHE KONTROLÜ
        // Cache geçerliyse (konum <5km, bugün dahil, metod aynı)
        // → API çağırMA, cache'ten yükle
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        if !force {
            let cacheValid = persistService.isCacheValid(
                for: location,
                method: settings.calculationMethod
            )
            
            if cacheValid {
                // Cache geçerli — API'ye istek ATMA
                if let cached = prayerService.loadCached(for: Date()) {
                    prayerService.loadMonthlyFromCache()
                    applyPrayers(cached)
                    let city = cached.cityName.isEmpty ? persistService.lastKnownCityName : cached.cityName
                    self.cityName = city.isEmpty ? NSLocalizedString("general.calculating", comment: "") : city
                    isLoading = false
                    
                    let cachedMonthly = prayerService.monthlyPrayers.isEmpty
                        ? persistService.loadPrayerCache()
                        : prayerService.monthlyPrayers
                    await notifService.scheduleAll(
                        prayers: cachedMonthly,
                        alarms: persistService.loadAlarms(),
                        language: settings.language
                    )
                    return
                }
            }
        }
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // CACHE GEÇERSİZ — API'den 30 günlük çek
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        print("HomeViewModel: 🔄 Cache geçersiz veya force — API'den çekiliyor...")
        
        let resolvedCity = await locationService.resolveCity(for: location)
        let finalCity = resolvedCity.isEmpty ? persistService.lastKnownCityName : resolvedCity
        self.cityName = finalCity
        persistService.saveLastKnownLocation(location)
        if !resolvedCity.isEmpty {
            persistService.saveLastKnownCityName(resolvedCity)
        }
        
        // 30 günlük veriyi API'den çek
        do {
            let monthlyPrayers = try await prayerService.calculateMonthly(
                for: location,
                method: settings.calculationMethod,
                madhab: settings.madhab
            )
            
            if let first = monthlyPrayers.first(where: { Calendar.current.isDateInToday($0.date) }) {
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
                await notifService.scheduleAll(
                    prayers: monthlyPrayers,
                    alarms: persistService.loadAlarms(),
                    language: settings.language
                )
            }
            
            print("HomeViewModel: ✅ API'den \(monthlyPrayers.count) gün çekildi ve cache'lendi")
        } catch {
            self.errorMessage = "Vakitler güncellenemedi: \(error.localizedDescription)"
            print("HomeViewModel: ❌ API Error — \(error)")
            
            // API başarısız olsa bile cache'ten bir şey varsa göster
            if todayPrayers == nil, let cached = prayerService.loadCached(for: Date()) {
                applyPrayers(cached)
                let city = cached.cityName.isEmpty ? persistService.lastKnownCityName : cached.cityName
                self.cityName = city
            }
        }
        
        isLoading = false
    }
    
    private func applyPrayers(_ prayers: PrayerTime) {
        self.todayPrayers = prayers
        self.nextPrayer = prayerService.findNextPrayer(from: prayers)
        self.hijriText = prayers.hijriDate.formatted(for: persistService.settings.language)
        
        if nextPrayer != nil {
            bgService.updateTheme(prayers: prayers, currentTime: Date())
        }
    }
    
    func languageDidChange(_ code: LanguageCode) {
        if let prayers = todayPrayers {
            self.hijriText = prayers.hijriDate.formatted(for: code)
        }
        loadDailyContent(language: code)
        updateNextReligiousDay(language: code)
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
        
        // Update UI animation states
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        let h = Double(components.hour ?? 0) + Double(components.minute ?? 0) / 60.0
        
        let start = h < 6 || h >= 18 ? (h >= 18 ? 18.0 : -6.0) : 6.0
        let duration = 12.0
        let progress = (h - start) / duration
        self.sunPosition = min(1.0, max(0.0, progress))
        
        let (phase, _, _) = SkyPhase.current(for: h)
        let nightPhases: [SkyPhase] = [.night, .deepNight, .earlyNight, .preDawn, .dusk]
        self.isNight = nightPhases.contains(phase)
        
        updateCompletedPrayersCount()
        updateIndividualPrayerProgress()
        updateRoutineSlot()
        updateDhikrStatus()
    }
    
    private func updateIndividualPrayerProgress() {
        guard let prayers = todayPrayers else { return }
        let now = Date()
        var newProgress: [PrayerName: Double] = [:]
        var newRemStrings: [PrayerName: String] = [:]
        
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
            allAlarms[index].isActive.toggle()
        } else {
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
        
        if let monthly = prayerService.monthlyPrayers.isEmpty ? nil : prayerService.monthlyPrayers {
            Task {
                await notifService.scheduleAll(
                    prayers: monthly,
                    alarms: allAlarms,
                    language: persistService.settings.language
                )
            }
        }
        
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
    
    func updateQiblaText(degrees: Double, language: LanguageCode) {
        let directions: [String: [LanguageCode: String]] = [
            "N": [.tr: "Kuzey", .en: "North"],
            "NE": [.tr: "Kuzeydoğu", .en: "Northeast"],
            "E": [.tr: "Doğu", .en: "East"],
            "SE": [.tr: "Güneydoğu", .en: "Southeast"],
            "S": [.tr: "Güney", .en: "South"],
            "SW": [.tr: "Güneybatı", .en: "Southwest"],
            "W": [.tr: "Batı", .en: "West"],
            "NW": [.tr: "Kuzeybatı", .en: "Northwest"]
        ]
        
        let index = Int((degrees + 22.5) / 45.0) & 7
        let keys = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let key = keys[index]
        let dirName = directions[key]?[language] ?? key
        
        self.qiblaDirectionText = "\(Int(degrees))° · \(dirName)"
    }
    
    func updateNextReligiousDay(language: LanguageCode) {
        let upcoming = IslamicCalendarService.shared.upcomingEvents(within: 365)
        if let next = upcoming.first {
            let diff = Calendar.current.dateComponents([.day], from: Date(), to: next.date).day ?? 0
            let daySuffix = (language == .tr) ? "Gün" : (language == .en ? "Days" : "d")
            self.nextReligiousDay = "\(next.event.key.name(for: language)) · \(diff) \(daySuffix)"
        } else {
            self.nextReligiousDay = "---"
        }
    }
    
    
    func updateRoutineSlot() {
        guard let prayers = todayPrayers else { return }
        let now = Date()
        
        if now >= prayers.fajr && now < prayers.dhuhr {
            self.currentRoutineSlot = .morning
        } 
        else if now >= prayers.asr || now < prayers.fajr {
            self.currentRoutineSlot = .evening
        } 
        else {
            self.currentRoutineSlot = .none
        }
    }
    
    public func updateDhikrStatus() {
        let items = persistService.dhikrItems
        let totalCount = items.reduce(0) { $0 + $1.currentCount }
        let totalTarget = items.reduce(0) { $0 + $1.targetCount }
        
        self.dhikrCount = totalCount
        self.dhikrTarget = totalTarget > 0 ? totalTarget : 99
        self.dhikrProgress = Double(dhikrCount) / Double(dhikrTarget)
    }
    
    public func updateReadingProgress() {
        let progress = persistService.readingProgress
        let surahName = PrayerGuideData.surahNames[max(1, min(114, progress.lastSurah)) - 1]
        self.lastReadSurah = "\(surahName) · \(progress.lastSurah). Sure"
    }
}
