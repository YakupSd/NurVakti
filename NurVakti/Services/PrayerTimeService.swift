import Foundation
import CoreLocation
import Combine
import WidgetKit

@MainActor
final class PrayerTimeService: ObservableObject {
    static let shared = PrayerTimeService()
    
    @Published var todayPrayers: PrayerTime?
    @Published var monthlyPrayers: [PrayerTime] = []
    @Published var nextPrayer: (name: PrayerName, time: Date)?
    @Published var countdown: TimeInterval = 0
    
    private var timer: AnyCancellable?
    
    init() {
        // Timer kaldırıldı — HomeViewModel kendi 1-saniyelik timer'ını kullanıyor.
        // İkili timer gereksiz CPU yükü yaratıyordu.
    }
    
    // MARK: - Widget Veri Yazma (App Group)
    func writeWidgetData(prayer: PrayerTime) {
        let language = LocalizationManager.shared.currentLanguage
        let cal = Calendar.current
        let now = Date()

        // 1. Çok günlük kaynak havuzunu al (monthlyPrayers veya Cache)
        var sourcePrayers = self.monthlyPrayers
        if sourcePrayers.isEmpty {
            sourcePrayers = PersistenceService.shared.loadPrayerCache()
        }
        if sourcePrayers.isEmpty {
            sourcePrayers = [prayer]
        }

        // Bugünden itibaren olan günleri sırala
        let todayStart = cal.startOfDay(for: now)
        let relevantPrayers = sourcePrayers.filter { cal.startOfDay(for: $0.date) >= todayStart }.sorted { $0.date < $1.date }

        // 2. Çok günlük widget veri paketlerini hazırla
        let widgetDays: [WidgetDayPrayerData] = relevantPrayers.map { p in
            let dayStart = cal.startOfDay(for: p.date)
            let hijriStr = "\(p.hijriDate.day) \(p.hijriDate.monthName(for: language)) \(p.hijriDate.year)"
            let dayEntries: [WidgetPrayerEntry] = PrayerName.allCases.map { name in
                let time = prayerDate(for: name, in: p)
                return WidgetPrayerEntry(
                    name: name.localizedName(for: language),
                    nameEn: name.localizedName(for: .en),
                    time: time,
                    isNext: false,
                    isPast: time <= now
                )
            }
            return WidgetDayPrayerData(date: dayStart, hijriDateString: hijriStr, prayers: dayEntries)
        }

        // 3. Sıradaki ilk vakti bul
        let allEntriesToday: [WidgetPrayerEntry] = PrayerName.allCases.map { name in
            let time = prayerDate(for: name, in: prayer)
            return WidgetPrayerEntry(
                name: name.localizedName(for: language),
                nameEn: name.localizedName(for: .en),
                time: time,
                isNext: false,
                isPast: time <= now
            )
        }

        let next = findNextPrayer(from: prayer)
        let nextName = next?.name.localizedName(for: language) ?? (allEntriesToday.first?.name ?? "İmsak")
        let nextNameEn = next?.name.localizedName(for: .en) ?? (allEntriesToday.first?.nameEn ?? "Imsak")
        let nextTime = next?.time ?? (allEntriesToday.first?.time.addingTimeInterval(86400) ?? now.addingTimeInterval(3600))

        NurWidgetData.updatePrayers(
            nextName: nextName,
            nextNameEn: nextNameEn,
            nextTime: nextTime,
            all: allEntriesToday,
            days: widgetDays,
            city: prayer.cityName.isEmpty ? PersistenceService.shared.lastKnownCityName : prayer.cityName,
            hijri: "\(prayer.hijriDate.day) \(prayer.hijriDate.monthName(for: language)) \(prayer.hijriDate.year)",
            lang: language.rawValue
        )

        // Widget timeline'ını zorla güncelle
        WidgetCenter.shared.reloadAllTimelines()
    }

    func prayerDate(for name: PrayerName, in prayer: PrayerTime) -> Date {
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
    
    private let prayerManager = PrayerManager()
    
    // MARK: - API'den 30 Günlük Çek (Sadece cache geçersiz olduğunda çağrılır)
    func calculateMonthly(for location: CLLocation,
                          method: String,
                          madhab: Madhab) async throws -> [PrayerTime] {
        
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        
        // Aladhan API Method mapping
        let methodInt: Int
        switch method.lowercased() {
        case "diyanet": methodInt = 13
        case "muslim world league": methodInt = 3
        case "isna": methodInt = 2
        case "egypt": methodInt = 5
        case "karachi": methodInt = 1
        case "tehran": methodInt = 7
        default: methodInt = 13
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            prayerManager.getPrayerTimes(latitude: lat, longitude: lng, method: methodInt) { response in
                let results = response.data.compactMap { day -> PrayerTime? in
                    let timings = day.timings
                    let dateStr = day.date.readable
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    dateFormatter.locale = Locale(identifier: "en_US")
                    guard let date = dateFormatter.date(from: dateStr) else { return nil }
                    
                    func parseTime(_ timeStr: String) -> Date {
                        let cleanTime = (timeStr.components(separatedBy: " ").first ?? timeStr).replacingOccurrences(of: "(EET)", with: "").replacingOccurrences(of: "(EEST)", with: "").trimmingCharacters(in: .whitespaces)
                        
                        let timeFormatter = DateFormatter()
                        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        timeFormatter.timeZone = TimeZone.current
                        
                        let dayFormatter = DateFormatter()
                        dayFormatter.dateFormat = "yyyy-MM-dd"
                        let dayStr = dayFormatter.string(from: date)
                        
                        return timeFormatter.date(from: "\(dayStr) \(cleanTime)") ?? date
                    }
                    
                    let hijri = HijriDate(
                        day: Int(day.date.hijri.day) ?? 1,
                        month: day.date.hijri.month.number,
                        year: Int(day.date.hijri.year) ?? 1447
                    )
                    
                    return PrayerTime(
                        id: UUID(),
                        date: date,
                        imsak:   parseTime(timings["Imsak"] ?? ""),
                        fajr:    parseTime(timings["Fajr"] ?? ""),
                        sunrise: parseTime(timings["Sunrise"] ?? ""),
                        dhuhr:   parseTime(timings["Dhuhr"] ?? ""),
                        asr:     parseTime(timings["Asr"] ?? ""),
                        maghrib: parseTime(timings["Maghrib"] ?? ""),
                        isha:    parseTime(timings["Isha"] ?? ""),
                        cityName: "",
                        hijriDate: hijri,
                        calculationMethod: "Diyanet (API)"
                    )
                }
                
                DispatchQueue.main.async {
                    self.monthlyPrayers = results
                    if let firstToday = results.first(where: { Calendar.current.isDateInToday($0.date) }) {
                        self.todayPrayers = firstToday
                        self.nextPrayer = self.findNextPrayer(from: firstToday)
                        self.writeWidgetData(prayer: firstToday)
                    }
                    // Cache'i metadata ile birlikte kaydet
                    PersistenceService.shared.savePrayerCacheWithMetadata(results, location: location, method: method)
                    continuation.resume(returning: results)
                }
            } onFailure: { error in
                continuation.resume(throwing: error ?? ApplicationErrorType.noResponse(desc: "Unknown error", code: nil))
            }
        }
    }
    
    // MARK: - Deprecated Calculation (Astronomical)
    @available(*, deprecated, message: "Use async calculateMonthly instead")
    func calculate(for location: CLLocation,
                   method: String,
                   madhab: Madhab) -> PrayerTime {
        let prayer = PrayerCalculator.shared.calculate(for: location, method: method, madhab: madhab)
        return prayer
    }
    
    // Bir sonraki vakti bul (Bugün bittiyse yarına bak)
    func findNextPrayer(from today: PrayerTime) -> (name: PrayerName, time: Date)? {
        let now = Date()
        
        let allToday: [(PrayerName, Date)] = [
            (.imsak, today.imsak),
            (.fajr, today.fajr),
            (.sunrise, today.sunrise),
            (.dhuhr, today.dhuhr),
            (.asr, today.asr),
            (.maghrib, today.maghrib),
            (.isha, today.isha)
        ].sorted { $0.1 < $1.1 }
        
        for p in allToday {
            if p.1 > now {
                return p
            }
        }
        
        // Bugün bittiyse yarının İmsak vaktine bak
        if let tomorrow = monthlyPrayers.first(where: { Calendar.current.isDate($0.date, inSameDayAs: Date().addingTimeInterval(86400)) }) {
            return (.imsak, tomorrow.imsak)
        }
        
        return nil
    }
    
    // Kalan süre (saniye)
    func secondsUntil(_ date: Date) -> TimeInterval {
        date.timeIntervalSince(Date())
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
    
    // MARK: - Cache Operations
    
    /// Bugünün cache'ten yüklenmesi
    func loadCached(for date: Date) -> PrayerTime? {
        let all = PersistenceService.shared.loadPrayerCache()
        return all.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    /// Cache'ten aylık veriyi yükle ve monthlyPrayers'ı doldur
    func loadMonthlyFromCache() {
        let all = PersistenceService.shared.loadPrayerCache()
        if !all.isEmpty {
            self.monthlyPrayers = all
        }
    }
    
    func saveToCache(_ prayers: [PrayerTime]) {
        PersistenceService.shared.savePrayerCache(prayers)
    }
}
