import Foundation

public struct AlarmModel: Codable, Identifiable, Hashable {
    public let id: UUID
    public var prayerName: PrayerName
    public var minutesBefore: Int        // 0, 5, 10, 15, 20, 30
    public var isActive: Bool
    public var soundType: AlarmSound
    public var repeatDays: Set<Weekday>  // boş = her gün
    
    public init(id: UUID = UUID(), prayerName: PrayerName, minutesBefore: Int, isActive: Bool, soundType: AlarmSound, repeatDays: Set<Weekday>) {
        self.id = id
        self.prayerName = prayerName
        self.minutesBefore = minutesBefore
        self.isActive = isActive
        self.soundType = soundType
        self.repeatDays = repeatDays
    }
}

public enum AlarmSound: String, Codable, CaseIterable {
    case ezan
    case fajr
    case system
    case silent

    // Localizable kullanılarak, name kopyalaması önlendi (SoundService extension'ı da bunu kullanacak)
    public func localizedName(for language: LanguageCode) -> String {
        switch self {
        case .ezan:   return NSLocalizedString("alarm.sound.ezan", comment: "")
        case .fajr:   return NSLocalizedString("alarm.sound.fajr", comment: "")
        case .system: return NSLocalizedString("alarm.sound.system", comment: "")
        case .silent: return NSLocalizedString("alarm.sound.silent", comment: "")
        }
    }
}

public enum Weekday: Int, Codable, CaseIterable {
    case sunday=1, monday, tuesday, wednesday, thursday, friday, saturday
    
    public func shortName(for language: LanguageCode) -> String {
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
    
    public var isFriday: Bool { self == .friday }
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
