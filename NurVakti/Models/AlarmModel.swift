import Foundation

struct AlarmModel: Codable, Identifiable, Hashable {
    let id: UUID
    var prayerName: PrayerName
    var minutesBefore: Int        // 0, 5, 10, 15, 20, 30
    var isActive: Bool
    var soundType: AlarmSound
    var repeatDays: Set<Weekday>  // boş = her gün
}

enum AlarmSound: String, Codable, CaseIterable {
    case ezan
    case fajr
    case system
    case silent

    // Localizable kullanılarak, name kopyalaması önlendi (SoundService extension'ı da bunu kullanacak)
    func localizedName(for language: LanguageCode) -> String {
        switch self {
        case .ezan:   return NSLocalizedString("alarm.sound.ezan", comment: "")
        case .fajr:   return NSLocalizedString("alarm.sound.fajr", comment: "")
        case .system: return NSLocalizedString("alarm.sound.system", comment: "")
        case .silent: return NSLocalizedString("alarm.sound.silent", comment: "")
        }
    }
}

enum Weekday: Int, Codable, CaseIterable {
    case sunday=1, monday, tuesday, wednesday, thursday, friday, saturday
    
    func shortName(for language: LanguageCode) -> String {
        switch (self, language) {
        case (.monday, .tr): return "Pzt"
        case (.tuesday, .tr): return "Sal"
        case (.wednesday, .tr): return "Çar"
        case (.thursday, .tr): return "Per"
        case (.friday, .tr): return "Cum"
        case (.saturday, .tr): return "Cmt"
        case (.sunday, .tr): return "Paz"
        // Portekizce vb.
        case (.monday, .pt): return "Seg"
        default: return String(self.rawValue)
        }
    }
    
    var isFriday: Bool { self == .friday }
}

extension AlarmModel {
    static func loadAll() -> [AlarmModel] {
        PersistenceService.shared.load(key: "alarms", as: [AlarmModel].self) ?? []
    }
    
    func save() {
        var all = AlarmModel.loadAll()
        if let index = all.firstIndex(where: { $0.id == self.id }) {
            all[index] = self
        } else {
            all.append(self)
        }
        PersistenceService.shared.save(all, key: "alarms")
    }
}
