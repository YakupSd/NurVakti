import Foundation

public struct PrayerDua: Identifiable, Codable {
    public let id: String
    public let audioFileName: String? // e.g. "033056"
    public let audioURL: String?      // Direct URL for non-Quranic prayers
    public let arabicText: String
    public let transliteration: String   // Static Turkish phonetic
    
    public let titles: [String: String]       // dua title in 5 languages
    public let meanings: [String: String]     // dua meaning in 5 languages
    public let virtues: [String: String]?      // dua virtues in 5 languages
    public var libraryCategory: LibraryCategory? = .daily // Used by DuaLibraryService
    
    public init(id: String, audioFileName: String? = nil, audioURL: String? = nil, arabicText: String, transliteration: String, titles: [String: String], meanings: [String: String], virtues: [String: String]? = nil, category: LibraryCategory? = .daily) {
        self.id = id
        self.audioFileName = audioFileName
        self.audioURL = audioURL
        self.arabicText = arabicText
        self.transliteration = transliteration
        self.titles = titles
        self.meanings = meanings
        self.virtues = virtues
        self.libraryCategory = category
    }
    
    public func title(for language: LanguageCode) -> String {
        titles[language.rawValue] ?? titles["tr"] ?? ""
    }
    
    public func meaning(for language: LanguageCode) -> String {
        meanings[language.rawValue] ?? meanings["tr"] ?? ""
    }
    
    // Always returns the normalized 6-digit string for display/debug
    public var normalizedAudioID: String {
        guard let audio = audioFileName else { return "" }
        let digits = audio.trimmingCharacters(in: .whitespaces)
        let isNumeric = digits.allSatisfy { $0.isNumber } && !digits.isEmpty
        
        guard isNumeric, digits.count >= 4, digits.count <= 6 else {
            return digits
        }
        return String(repeating: "0", count: max(0, 6 - digits.count)) + digits
    }
}

public struct PrayerStep: Identifiable, Codable {
    public let id: String
    public let imageName: String?
    
    public let titles: [String: String]
    public let descriptions: [String: String]
    
    public init(id: String, imageName: String?, titles: [String: String], descriptions: [String: String]) {
        self.id = id
        self.imageName = imageName
        self.titles = titles
        self.descriptions = descriptions
    }
    
    public func title(for language: LanguageCode) -> String {
        titles[language.rawValue] ?? titles["tr"] ?? ""
    }
    
    public func description(for language: LanguageCode) -> String {
        descriptions[language.rawValue] ?? descriptions["tr"] ?? ""
    }
}

public struct TesbihItem: Identifiable, Codable {
    public let id: String
    public let text: String
    public let targetCount: Int
    public let meanings: [String: String]
    
    public init(id: String, text: String, targetCount: Int, meanings: [String: String]) {
        self.id = id
        self.text = text
        self.targetCount = targetCount
        self.meanings = meanings
    }
    
    public func meaning(for language: LanguageCode) -> String {
        meanings[language.rawValue] ?? meanings["tr"] ?? ""
    }
}
