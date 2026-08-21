//
//  SharedModels.swift
//  NurVaktiWidgetn
//
//  Widget Extension ile Ana Uygulama arasında paylaşılan veri modelleri.
//  App Group: group.com.yakupsuda.NurVaktiApp
//

import Foundation

// MARK: - Widget Paylaşım Modeli
public struct WidgetPrayerEntry: Codable, Identifiable, Equatable {
    public var id: String { "\(nameEn)_\(time.timeIntervalSince1970)" }
    public let name: String      // Lokalize isim (Örn: "Öğle")
    public let nameEn: String    // İngilizce (Örn: "Dhuhr")
    public let time: Date
    public let isNext: Bool
    public let isPast: Bool

    public init(name: String, nameEn: String, time: Date, isNext: Bool, isPast: Bool) {
        self.name = name
        self.nameEn = nameEn
        self.time = time
        self.isNext = isNext
        self.isPast = isPast
    }
}

public struct WidgetDayPrayerData: Codable, Equatable {
    public let date: Date
    public let hijriDateString: String
    public let prayers: [WidgetPrayerEntry]

    public init(date: Date, hijriDateString: String, prayers: [WidgetPrayerEntry]) {
        self.date = date
        self.hijriDateString = hijriDateString
        self.prayers = prayers
    }
}

public struct NurWidgetData: Codable {
    // Sonraki vakit (anlık / varsayılan)
    public var nextPrayerName: String
    public var nextPrayerNameEn: String
    public var nextPrayerTime: Date

    // Aktif / bugünkü vakitler
    public var allPrayers: [WidgetPrayerEntry]

    // Çok günlük takvim verisi (14-30 günlük kesintisiz timeline için)
    public var days: [WidgetDayPrayerData]?

    // Zikirmatik
    public var activeDhikrName: String?
    public var activeDhikrCount: Int?
    public var activeDhikrTarget: Int?

    // Konum & Ayarlar
    public var cityName: String
    public var hijriDateString: String
    public var languageCode: String
    public var lastUpdated: Date

    public static let appGroupID = "group.com.yakupsuda.NurVaktiApp"
    public static let dataKey    = "widget_data"

    public init(
        nextPrayerName: String,
        nextPrayerNameEn: String,
        nextPrayerTime: Date,
        allPrayers: [WidgetPrayerEntry],
        days: [WidgetDayPrayerData]? = nil,
        activeDhikrName: String? = nil,
        activeDhikrCount: Int? = nil,
        activeDhikrTarget: Int? = nil,
        cityName: String,
        hijriDateString: String,
        languageCode: String,
        lastUpdated: Date
    ) {
        self.nextPrayerName = nextPrayerName
        self.nextPrayerNameEn = nextPrayerNameEn
        self.nextPrayerTime = nextPrayerTime
        self.allPrayers = allPrayers
        self.days = days
        self.activeDhikrName = activeDhikrName
        self.activeDhikrCount = activeDhikrCount
        self.activeDhikrTarget = activeDhikrTarget
        self.cityName = cityName
        self.hijriDateString = hijriDateString
        self.languageCode = languageCode
        self.lastUpdated = lastUpdated
    }
}

// MARK: - App Group Okuma / Yazma & Akıllı Hesaplama
extension NurWidgetData {

    /// Widget Extension tarafından çağrılır
    public static func load() -> NurWidgetData? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: dataKey),
              let decoded = try? JSONDecoder().decode(NurWidgetData.self, from: data) else {
            return fallbackData()
        }
        return decoded
    }

    /// Fallback örnek verisi (App Group henüz boşsa)
    public static func fallbackData() -> NurWidgetData {
        let now = Date()
        let cal = Calendar.current
        
        var generatedDays: [WidgetDayPrayerData] = []
        for dayOffset in 0..<7 {
            guard let dayDate = cal.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            let dayPrayers = [
                WidgetPrayerEntry(name: "İmsak",  nameEn: "Imsak",   time: cal.date(bySettingHour: 4, minute: 40, second: 0, of: dayDate) ?? dayDate, isNext: false, isPast: false),
                WidgetPrayerEntry(name: "Güneş",  nameEn: "Sunrise", time: cal.date(bySettingHour: 6, minute: 20, second: 0, of: dayDate) ?? dayDate, isNext: false, isPast: false),
                WidgetPrayerEntry(name: "Öğle",   nameEn: "Dhuhr",   time: cal.date(bySettingHour: 13, minute: 19, second: 0, of: dayDate) ?? dayDate, isNext: false, isPast: false),
                WidgetPrayerEntry(name: "İkindi", nameEn: "Asr",     time: cal.date(bySettingHour: 17, minute: 4, second: 0, of: dayDate) ?? dayDate, isNext: false, isPast: false),
                WidgetPrayerEntry(name: "Akşam",  nameEn: "Maghrib", time: cal.date(bySettingHour: 20, minute: 7, second: 0, of: dayDate) ?? dayDate, isNext: false, isPast: false),
                WidgetPrayerEntry(name: "Yatsı",  nameEn: "Isha",    time: cal.date(bySettingHour: 21, minute: 30, second: 0, of: dayDate) ?? dayDate, isNext: false, isPast: false)
            ]
            generatedDays.append(WidgetDayPrayerData(date: cal.startOfDay(for: dayDate), hijriDateString: "NurVakti", prayers: dayPrayers))
        }

        let base = NurWidgetData(
            nextPrayerName: "Öğle",
            nextPrayerNameEn: "Dhuhr",
            nextPrayerTime: cal.date(byAdding: .minute, value: 45, to: now) ?? now.addingTimeInterval(2700),
            allPrayers: generatedDays.first?.prayers ?? [],
            days: generatedDays,
            activeDhikrName: "Sübhanallah",
            activeDhikrCount: 24,
            activeDhikrTarget: 33,
            cityName: "İstanbul",
            hijriDateString: "NurVakti",
            languageCode: "tr",
            lastUpdated: now
        )
        return base.dataForDate(now)
    }

    /// Verilen tarihe (`date`) göre sıradaki vakti ve o günün vakit listesini hatasız hesaplar.
    /// Asla geçmişte kalmış vakit veya negatif geri sayım üretmez.
    public func dataForDate(_ date: Date) -> NurWidgetData {
        let cal = Calendar.current
        
        // 1. Çok günlük havuzdan tüm vakitleri topla ve sırala
        var allChronological: [WidgetPrayerEntry] = []
        if let days = self.days, !days.isEmpty {
            allChronological = days.flatMap { $0.prayers }.sorted { $0.time < $1.time }
        } else {
            allChronological = self.allPrayers.sorted { $0.time < $1.time }
        }

        guard !allChronological.isEmpty else { return self }

        // 2. date'ten sonraki İLK vakti bul
        let nextUpcoming = allChronological.first(where: { $0.time > date })

        let (nextName, nextNameEn, nextTime): (String, String, Date) = {
            if let next = nextUpcoming {
                return (next.name, next.nameEn, next.time)
            } else {
                // Eğer havuzdaki tüm vakitler geçmişse (örneğin eski veri kalmışsa),
                // en baştaki vakti gün bazında geleceğe öteleyerek kesinlikle GELECEKTE bir Date bul
                if let first = allChronological.first {
                    var safeTime = first.time
                    while safeTime <= date {
                        safeTime = cal.date(byAdding: .day, value: 1, to: safeTime) ?? safeTime.addingTimeInterval(86400)
                    }
                    return (first.name, first.nameEn, safeTime)
                }
                return (self.nextPrayerName, self.nextPrayerNameEn, max(date.addingTimeInterval(60), self.nextPrayerTime))
            }
        }()

        // 3. date anına denk gelen günün vakit satırlarını seç
        var targetDayPrayers: [WidgetPrayerEntry] = []
        var activeHijri = self.hijriDateString

        if let matchingDay = self.days?.first(where: { cal.isDate($0.date, inSameDayAs: date) }) {
            targetDayPrayers = matchingDay.prayers
            if !matchingDay.hijriDateString.isEmpty {
                activeHijri = matchingDay.hijriDateString
            }
        } else if let dayOfNext = self.days?.first(where: { cal.isDate($0.date, inSameDayAs: nextTime) }) {
            targetDayPrayers = dayOfNext.prayers
            if !dayOfNext.hijriDateString.isEmpty {
                activeHijri = dayOfNext.hijriDateString
            }
        } else {
            targetDayPrayers = self.allPrayers
        }

        // 4. Seçilen günün vakitleri için isPast ve isNext durumlarını güncelle
        let updatedPrayers = targetDayPrayers.map { p in
            let isPast = p.time <= date
            let isNext = (nextUpcoming != nil && p.nameEn == nextUpcoming?.nameEn && cal.isDate(p.time, inSameDayAs: nextUpcoming!.time))
            return WidgetPrayerEntry(
                name: p.name,
                nameEn: p.nameEn,
                time: p.time,
                isNext: isNext,
                isPast: isPast
            )
        }

        var copy = self
        copy.nextPrayerName = nextName
        copy.nextPrayerNameEn = nextNameEn
        copy.nextPrayerTime = nextTime
        copy.allPrayers = updatedPrayers
        copy.hijriDateString = activeHijri
        copy.lastUpdated = date
        return copy
    }
}
