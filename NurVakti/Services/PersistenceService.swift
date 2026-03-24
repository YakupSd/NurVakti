import Foundation
import Combine
import CoreLocation

final class PersistenceService: ObservableObject {
    static let shared = PersistenceService()
    
    @Published var settings: AppSettings {
        didSet {
            objectWillChange.send()
        }
    }
    @Published var dhikrItems: [DhikrItem]
    @Published var alarms: [AlarmModel]
    @Published var bookmarks: [QuranBookmark]
    @Published var readingProgress: ReadingProgress
    // Background refresh distance check
    @Published var lastKnownLocation: CLLocation?
    
    private let defaults = UserDefaults.standard
    
    // Custom key for location dictionary
    private let locationLatKey = "lastKnownLat"
    private let locationLonKey = "lastKnownLon"
    
    private enum Keys: String {
        case settings, dhikr, alarms
        case bookmarks, readingProgress, prayerCache
    }
    
    init() {
        // 1. Initialize with defaults to satisfy compiler
        self.settings = AppSettings()
        self.dhikrItems = []
        self.alarms = []
        self.bookmarks = []
        self.readingProgress = ReadingProgress(lastSurah: 1, lastAyah: 1, lastReadDate: Date(), totalAyahsRead: 0)
        
        // 2. Load actual data using local instance methods (NOT static Model.load)
        if let s: AppSettings = load(key: Keys.settings.rawValue, as: AppSettings.self) {
            self.settings = s
        }
        
        self.dhikrItems = loadDhikr()
        if self.dhikrItems.isEmpty {
            self.dhikrItems = defaultDhikrItems()
            saveDhikr(self.dhikrItems)
        }
        
        if let a: [AlarmModel] = load(key: Keys.alarms.rawValue, as: [AlarmModel].self) {
            self.alarms = a
        }
        
        if let b: [QuranBookmark] = load(key: Keys.bookmarks.rawValue, as: [QuranBookmark].self) {
            self.bookmarks = b
        }
        
        if let p: ReadingProgress = load(key: Keys.readingProgress.rawValue, as: ReadingProgress.self) {
            self.readingProgress = p
        }
        
        let lat = defaults.double(forKey: locationLatKey)
        let lon = defaults.double(forKey: locationLonKey)
        if lat != 0 || lon != 0 {
            self.lastKnownLocation = CLLocation(latitude: lat, longitude: lon)
        }
    }
    
    func saveLastKnownLocation(_ location: CLLocation) {
        self.lastKnownLocation = location
        defaults.set(location.coordinate.latitude, forKey: locationLatKey)
        defaults.set(location.coordinate.longitude, forKey: locationLonKey)
    }
    
    func save<T: Encodable>(_ object: T, key: String) {
        if let encoded = try? JSONEncoder().encode(object) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    func load<T: Decodable>(key: String, as type: T.Type) -> T? {
        if let data = defaults.data(forKey: key) {
            return try? JSONDecoder().decode(type, from: data)
        }
        return nil
    }
    
    // MARK: - Specialized Save/Load
    
    func saveSettings(_ settings: AppSettings) {
        self.settings = settings
        save(settings, key: Keys.settings.rawValue)
    }
    
    func loadSettings() -> AppSettings {
        load(key: Keys.settings.rawValue, as: AppSettings.self) ?? AppSettings()
    }
    
    func saveDhikr(_ items: [DhikrItem]) {
        self.dhikrItems = items
        save(items, key: Keys.dhikr.rawValue)
    }
    
    func loadDhikr() -> [DhikrItem] {
        load(key: Keys.dhikr.rawValue, as: [DhikrItem].self) ?? []
    }
    
    func defaultDhikrItems() -> [DhikrItem] {
        return ZikirType.allCases.filter { $0 != .custom }.map { type in
            DhikrItem(id: UUID(), 
                      type: type, 
                      arabicText: type.arabicText, 
                      transliterationTR: "", 
                      meanings: [
                        .tr: type.meaning(for: .tr),
                        .en: type.meaning(for: .en)
                      ], 
                      targetCount: type.defaultTarget, 
                      currentCount: 0, 
                      isCustom: false, 
                      vibrateOnCount: true, 
                      dailyCompletions: 0, 
                      totalCompletions: 0)
        }
    }
    
    func saveAlarms(_ alarms: [AlarmModel]) {
        self.alarms = alarms
        save(alarms, key: Keys.alarms.rawValue)
    }
    
    func loadAlarms() -> [AlarmModel] {
        load(key: Keys.alarms.rawValue, as: [AlarmModel].self) ?? []
    }
    
    func saveBookmark(_ bookmark: QuranBookmark) {
        self.bookmarks.append(bookmark)
        save(self.bookmarks, key: Keys.bookmarks.rawValue)
    }
    
    func removeBookmark(id: UUID) {
        self.bookmarks.removeAll { $0.id == id }
        save(self.bookmarks, key: Keys.bookmarks.rawValue)
    }
    
    func saveReadingProgress(_ progress: ReadingProgress) {
        self.readingProgress = progress
        save(progress, key: Keys.readingProgress.rawValue)
    }
    
    // Cache
    func savePrayerCache(_ prayers: [PrayerTime]) {
        save(prayers, key: Keys.prayerCache.rawValue)
    }
    
    func loadPrayerCache() -> [PrayerTime] {
        load(key: Keys.prayerCache.rawValue, as: [PrayerTime].self) ?? []
    }
    
    func clearExpiredCache() {
        var all = loadPrayerCache()
        let now = Date()
        all.removeAll { $0.date < now.addingTimeInterval(-86400) }
        savePrayerCache(all)
    }
}
