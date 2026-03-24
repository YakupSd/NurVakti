import Foundation
import CoreLocation
import Combine
import WidgetKit
// import Adhan // SPM ile eklendiği varsayılıyor

final class PrayerTimeService: ObservableObject {
    @Published var todayPrayers: PrayerTime?
    @Published var monthlyPrayers: [PrayerTime] = []
    @Published var nextPrayer: (name: PrayerName, time: Date)?
    @Published var countdown: TimeInterval = 0
    
    private var timer: AnyCancellable?
    
    init() {
        startCountdownTimer()
    }
    
    // Adhan Swift kullanarak hesapla (Mock logic - Adhan entegrasyonu için yapı)
    func calculate(for location: CLLocation, 
                   method: String, 
                   madhab: Madhab) -> PrayerTime {
        // Gerçek implementasyonda Adhan kütüphanesi kullanılacak
        // Örn: let params = CalculationMethod.turkey().params
        // let prayers = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params)
        
        // Mock veri dönelim (şimdilik)
        let now = Date()
        let prayer = PrayerTime(
            id: UUID(),
            date: now,
            imsak: now.addingTimeInterval(3600),
            fajr: now.addingTimeInterval(5000),
            sunrise: now.addingTimeInterval(10000),
            dhuhr: now.addingTimeInterval(20000),
            asr: now.addingTimeInterval(30000),
            maghrib: now.addingTimeInterval(40000),
            isha: now.addingTimeInterval(50000),
            cityName: "İstanbul",
            hijriDate: hijriDate(from: now, language: .tr),
            calculationMethod: method
        )
        
        DispatchQueue.main.async {
            self.todayPrayers = prayer
            self.nextPrayer = self.findNextPrayer(from: prayer)
            // ── Persistence & Widget ────────────────────────────────────
            self.saveToCache([prayer])
            self.writeWidgetData(prayer: prayer)
        }
        return prayer
    }

    // MARK: - Widget Veri Yazma (App Group)
    private func writeWidgetData(prayer: PrayerTime) {
        guard let next = findNextPrayer(from: prayer) else { return }

        let language = LocalizationManager.shared.currentLanguage
        let allEntries: [WidgetPrayerEntry] = PrayerName.allCases.compactMap { name in
            let time = prayerDate(for: name, in: prayer)
            let isPast = time < Date()
            let isNext = next.name == name
            return WidgetPrayerEntry(
                name: name.localizedName(for: language),
                nameEn: name.localizedName(for: .en),
                time: time,
                isNext: isNext,
                isPast: isPast
            )
        }

        let widgetData = NurWidgetData(
            nextPrayerName: next.name.localizedName(for: language),
            nextPrayerNameEn: next.name.localizedName(for: .en),
            nextPrayerTime: next.time,
            allPrayers: allEntries,
            cityName: prayer.cityName,
            hijriDateString: "\(prayer.hijriDate.day) \(prayer.hijriDate.monthName(for: language)) \(prayer.hijriDate.year)",
            languageCode: language.rawValue,
            lastUpdated: Date()
        )
        NurWidgetData.save(widgetData)

        // Widget timeline'ını zorla güncelle
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func prayerDate(for name: PrayerName, in prayer: PrayerTime) -> Date {
        switch name {
        case .imsak:   return prayer.imsak
        case .fajr:    return prayer.fajr
        case .sunrise: return prayer.sunrise
        case .dhuhr:   return prayer.dhuhr
        case .asr:     return prayer.asr
        case .maghrib: return prayer.maghrib
        case .isha:    return prayer.isha
        }
    }
    
    // 30 günlük hesapla ve cache'le
    func calculateMonthly(for location: CLLocation,
                          method: String,
                          madhab: Madhab) -> [PrayerTime] {
        var results: [PrayerTime] = []
        // Loop for 30 days...
        self.monthlyPrayers = results
        saveToCache(results)
        return results
    }
    
    // Bir sonraki vakti bul
    func findNextPrayer(from prayers: PrayerTime) -> (name: PrayerName, time: Date)? {
        let now = Date()
        if prayers.imsak > now { return (.imsak, prayers.imsak) }
        if prayers.fajr > now { return (.fajr, prayers.fajr) }
        if prayers.sunrise > now { return (.sunrise, prayers.sunrise) }
        if prayers.dhuhr > now { return (.dhuhr, prayers.dhuhr) }
        if prayers.asr > now { return (.asr, prayers.asr) }
        if prayers.maghrib > now { return (.maghrib, prayers.maghrib) }
        if prayers.isha > now { return (.isha, prayers.isha) }
        return nil
    }
    
    // Kalan süre (saniye)
    func secondsUntil(_ date: Date) -> TimeInterval {
        date.timeIntervalSince(Date())
    }
    
    // Hicri tarih (Foundation built-in)
    func hijriDate(from date: Date, language: LanguageCode) -> HijriDate {
        let calendar = Calendar(identifier: .islamicUmmAlQura)
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        return HijriDate(day: components.day ?? 1, month: components.month ?? 1, year: components.year ?? 1446)
    }
    
    // Timer: her saniye countdown güncelle
    private func startCountdownTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let next = self.nextPrayer else { return }
                self.countdown = self.secondsUntil(next.time)
            }
    }
    
    // Cache
    func loadCached(for date: Date) -> PrayerTime? {
        let all = PersistenceService.shared.loadPrayerCache()
        return all.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func saveToCache(_ prayers: [PrayerTime]) {
        PersistenceService.shared.savePrayerCache(prayers)
    }
}
