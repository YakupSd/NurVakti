import Foundation

struct DuaItem: Identifiable, Codable {
    let id: UUID
    let title: [LanguageCode: String]
    let arabicText: String
    let transliteration: [LanguageCode: String]
    let translation: [LanguageCode: String]
    let category: DuaCategory
    var audioArabicURL: String? = nil
    var audioTranslationURL: String? = nil
}

enum DuaCategory: String, Codable {
    case morning
    case evening
    case afterPrayer
    case general
}
