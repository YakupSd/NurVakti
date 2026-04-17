import Foundation

public struct DuaItem: Identifiable, Codable {
    public let id: UUID
    public let title: [LanguageCode: String]
    public let arabicText: String
    public let transliteration: [LanguageCode: String]
    public let translation: [LanguageCode: String]
    public let category: DuaCategory
    public var audioArabicURL: String? = nil
    public var audioTranslationURL: String? = nil
    public var audioFileName: String? = nil
    public var surahNumber: Int? = nil
    public var ayahNumber: Int? = nil
    public var virtue: [LanguageCode: String]? = nil
    
    public var hasAudio: Bool {
        return audioArabicURL != nil || audioFileName != nil || surahNumber != nil
    }
}

public enum DuaCategory: String, Codable {
    case morning
    case evening
    case afterPrayer
    case general
}
