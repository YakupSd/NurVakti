//
//  SharedModels.swift
//  NurVaktiWidgetn
//
//  Widget Extension ile Ana Uygulama arasında paylaşılan veri modelleri.
//  App Group: group.com.yakupsuda.NurVaktiApp
//

import Foundation

// MARK: - Widget Paylaşım Modeli
struct NurWidgetData: Codable {
    var nextPrayerName: String
    var nextPrayerNameEn: String
    var nextPrayerTime: Date
    var allPrayers: [WidgetPrayerEntry]
    var activeDhikrName: String?
    var activeDhikrCount: Int?
    var activeDhikrTarget: Int?
    var cityName: String
    var hijriDateString: String
    var languageCode: String
    var lastUpdated: Date

    static let appGroupID = "group.com.yakupsuda.NurVaktiApp"
    static let dataKey    = "widget_data"
}

struct WidgetPrayerEntry: Codable, Identifiable, Equatable {
    var id: String { name }
    let name: String
    let nameEn: String
    let time: Date
    let isNext: Bool
    let isPast: Bool
}

// MARK: - App Group Read
extension NurWidgetData {
    static func load() -> NurWidgetData? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: dataKey),
              let decoded = try? JSONDecoder().decode(NurWidgetData.self, from: data) else {
            return nil
        }
        return decoded
    }
}
