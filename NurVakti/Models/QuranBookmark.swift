import Foundation

struct QuranBookmark: Codable, Identifiable {
    let id: UUID
    let surahNumber: Int
    let ayahNumber: Int
    let surahNameArabic: String
    let surahNameLocalized: [LanguageCode: String]
    let createdAt: Date
    var note: String?
}

struct ReadingProgress: Codable {
    var lastSurah: Int
    var lastAyah: Int
    var lastReadDate: Date
    var totalAyahsRead: Int
    var readingMode: QuranReadingMode = .withTranslation
    
    static func load() -> ReadingProgress {
        PersistenceService.shared.load(key: "reading_progress", as: ReadingProgress.self) ?? 
        ReadingProgress(lastSurah: 1, lastAyah: 1, lastReadDate: Date(), totalAyahsRead: 0, readingMode: .withTranslation)
    }
    
    func save() {
        PersistenceService.shared.save(self, key: "reading_progress")
    }
}

struct HatimProgress: Codable {
    var currentPage: Int // 1-604
    var completedCount: Int
    var lastUpdated: Date
    
    static func load() -> HatimProgress {
        PersistenceService.shared.load(key: "hatim_progress", as: HatimProgress.self) ??
        HatimProgress(currentPage: 1, completedCount: 0, lastUpdated: Date())
    }
    
    func save() {
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
