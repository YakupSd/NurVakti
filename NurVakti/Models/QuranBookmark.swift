import Foundation

public struct QuranBookmark: Codable, Identifiable {
    public let id: UUID
    public let surahNumber: Int
    public let ayahNumber: Int
    public let surahNameArabic: String
    public let surahNameLocalized: [LanguageCode: String]
    public let createdAt: Date
    public var note: String?
    
    public init(id: UUID = UUID(), surahNumber: Int, ayahNumber: Int, surahNameArabic: String, surahNameLocalized: [LanguageCode : String], createdAt: Date = Date(), note: String? = nil) {
        self.id = id
        self.surahNumber = surahNumber
        self.ayahNumber = ayahNumber
        self.surahNameArabic = surahNameArabic
        self.surahNameLocalized = surahNameLocalized
        self.createdAt = createdAt
        self.note = note
    }
}

public struct ReadingProgress: Codable {
    public var lastSurah: Int
    public var lastAyah: Int
    public var lastReadDate: Date
    public var totalAyahsRead: Int
    public var readingMode: QuranReadingMode = .withTranslation
    
    public init(lastSurah: Int, lastAyah: Int, lastReadDate: Date, totalAyahsRead: Int, readingMode: QuranReadingMode = .withTranslation) {
        self.lastSurah = lastSurah
        self.lastAyah = lastAyah
        self.lastReadDate = lastReadDate
        self.totalAyahsRead = totalAyahsRead
        self.readingMode = readingMode
    }
    
    public static func load() -> ReadingProgress {
        PersistenceService.shared.load(key: "reading_progress", as: ReadingProgress.self) ?? 
        ReadingProgress(lastSurah: 1, lastAyah: 1, lastReadDate: Date(), totalAyahsRead: 0, readingMode: .withTranslation)
    }
    
    public func save() {
        PersistenceService.shared.save(self, key: "reading_progress")
    }
}

public struct HatimProgress: Codable {
    public var currentPage: Int // 1-604
    public var completedCount: Int
    public var lastUpdated: Date
    
    public init(currentPage: Int, completedCount: Int, lastUpdated: Date) {
        self.currentPage = currentPage
        self.completedCount = completedCount
        self.lastUpdated = lastUpdated
    }
    
    public static func load() -> HatimProgress {
        PersistenceService.shared.load(key: "hatim_progress", as: HatimProgress.self) ??
        HatimProgress(currentPage: 1, completedCount: 0, lastUpdated: Date())
    }
    
    public func save() {
        PersistenceService.shared.save(self, key: "hatim_progress")
    }
}

extension QuranBookmark {
    static func loadAll() -> [QuranBookmark] {
        PersistenceService.shared.load(key: "quran_bookmarks", as: [QuranBookmark].self) ?? []
    }
    
    func save() {
        var all = QuranBookmark.loadAll()
        all.append(self)
        PersistenceService.shared.save(all, key: "quran_bookmarks")
    }
}
