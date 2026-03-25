import Foundation

// MARK: - Widget Paylaşım Modeli
// Ana uygulama bu struct'ı App Group container'a yazar.
// Widget extension aynı container'dan okur.
//
// App Group ID: group.com.nurvakti.shared
// (Xcode'da her iki target'a da eklenmelidir)

struct NurWidgetData: Codable {
    // Sonraki vakit
    var nextPrayerName: String        // "Akşam"
    var nextPrayerNameEn: String      // "Maghrib"
    var nextPrayerTime: Date
    // Bugünkü tüm vakitler (widget'ı zenginleştirmek için)
    var allPrayers: [WidgetPrayerEntry]
    // Zikirmatik (Yeni)
    var activeDhikrName: String?
    var activeDhikrCount: Int?
    var activeDhikrTarget: Int?

    // Konum
    var cityName: String
    // Hicri tarih
    var hijriDateString: String
    // Dil
    var languageCode: String
    // Son güncelleme
    var lastUpdated: Date

    static let appGroupID = "group.com.nurvakti.shared"
    static let dataKey    = "widget_data"
}

struct WidgetPrayerEntry: Codable, Identifiable {
    var id: String { name }
    let name: String      // Lokalize isim
    let nameEn: String    // İngilizce (widget locale için)
    let time: Date
    let isNext: Bool
    let isPast: Bool
}

// MARK: - App Group Okuma/Yazma
extension NurWidgetData {

    /// Ana uygulama tarafından çağrılır — veriyierini widget'a yazar
    static func save(_ data: NurWidgetData) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            print("WidgetData: App Group container bulunamadı!")
            return
        }
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        defaults.set(encoded, forKey: dataKey)
    }

    /// Widget Extension tarafından çağrılır
    static func load() -> NurWidgetData? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: dataKey),
              let decoded = try? JSONDecoder().decode(NurWidgetData.self, from: data) else {
            return nil
        }
        return decoded
    }

    /// Sadece zikir verisini günceller (Prayer verisini korur)
    static func updateDhikr(name: String, count: Int, target: Int) {
        var data = load() ?? createEmpty()
        data.activeDhikrName = name
        data.activeDhikrCount = count
        data.activeDhikrTarget = target
        save(data)
    }

    /// Sadece vakit verisini günceller (Zikir verisini korur)
    static func updatePrayers(nextName: String, nextNameEn: String, nextTime: Date, all: [WidgetPrayerEntry], city: String, hijri: String, lang: String) {
        var data = load() ?? createEmpty()
        data.nextPrayerName = nextName
        data.nextPrayerNameEn = nextNameEn
        data.nextPrayerTime = nextTime
        data.allPrayers = all
        data.cityName = city
        data.hijriDateString = hijri
        data.languageCode = lang
        data.lastUpdated = Date()
        save(data)
    }

    private static func createEmpty() -> NurWidgetData {
        NurWidgetData(
            nextPrayerName: "--",
            nextPrayerNameEn: "--",
            nextPrayerTime: Date(),
            allPrayers: [],
            activeDhikrName: nil,
            activeDhikrCount: nil,
            activeDhikrTarget: nil,
            cityName: "NurVakti",
            hijriDateString: "",
            languageCode: "tr",
            lastUpdated: Date()
        )
    }
}
