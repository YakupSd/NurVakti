import Foundation
import CoreLocation
import Combine
import WidgetKit
// import Adhan // SPM ile eklendiği varsayılıyor

@MainActor
final class PrayerTimeService: ObservableObject {
    @Published var todayPrayers: PrayerTime?
    @Published var monthlyPrayers: [PrayerTime] = []
    @Published var nextPrayer: (name: PrayerName, time: Date)?
    @Published var countdown: TimeInterval = 0
    
    private var timer: AnyCancellable?
    
    init() {
        startCountdownTimer()
    }
    
    // Verilen koordinat için vakitleri Aladhan API'den (Diyanet Metodu) çeker.
    // Artık astronomik hesaplama yerine servis tabanlı çalışıyoruz.
    // ------------------------------------------------------------------

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

        NurWidgetData.updatePrayers(
            nextName: next.name.localizedName(for: language),
            nextNameEn: next.name.localizedName(for: .en),
            nextTime: next.time,
            all: allEntries,
            city: prayer.cityName,
            hijri: "\(prayer.hijriDate.day) \(prayer.hijriDate.monthName(for: language)) \(prayer.hijriDate.year)",
            lang: language.rawValue
        )

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
    
    // API'den 30 günlük (veya takvim ayı bazlı) çek
    func calculateMonthly(for location: CLLocation,
                          method: String,
                          madhab: Madhab) async throws -> [PrayerTime] {
        
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        
        // Aladhan API Calendar RPC (Diyanet=13, default=method)
        let methodParam: String
        switch method.lowercased() {
        case "diyanet": methodParam = "13"
        case "muslim world league": methodParam = "3"
        case "isna": methodParam = "2"
        case "egypt": methodParam = "5"
        case "karachi": methodParam = "1"
        case "tehran": methodParam = "7"
        default: methodParam = "13"
        }
        
        let urlString = "https://api.aladhan.com/v1/calendar?latitude=\(lat)&longitude=\(lng)&method=\(methodParam)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AladhanResponse.self, from: data)
        
        let results = response.data.compactMap { day -> PrayerTime? in
            let timings = day.timings
            let dateStr = day.date.readable // "24 Mar 2026"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            dateFormatter.locale = Locale(identifier: "en_US")
            guard let date = dateFormatter.date(from: dateStr) else { return nil }
            
            func parseTime(_ timeStr: String) -> Date {
                // "13:10 (EET)" -> "13:10"
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
                // Widget verisini yaz
                self.writeWidgetData(prayer: firstToday)
            }
            self.saveToCache(results)
        }
        
        return results
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
        
        // Bugün içindeki vakitleri kontrol et
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
    
    // Cache
    func loadCached(for date: Date) -> PrayerTime? {
        let all = PersistenceService.shared.loadPrayerCache()
        return all.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func saveToCache(_ prayers: [PrayerTime]) {
        PersistenceService.shared.savePrayerCache(prayers)
    }
}
