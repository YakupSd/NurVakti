import Foundation

public struct EsmaulHusna: Identifiable, Codable {
    public let id: Int
    public let name: String                              // Arabic (Original)
    public let title: String                             // Transliterated Title (Universal)
    public let meanings: [LanguageCode: String]        // Localized Meanings in 5 languages
    public let virtue: String?                          // Virtue (Fazileti)
    public let audioURL: String?                        // Audio URL
    
    public init(id: Int, name: String, title: String, meanings: [LanguageCode: String], virtue: String? = nil, audioURL: String? = nil) {
        self.id = id
        self.name = name
        self.title = title
        self.meanings = meanings
        self.virtue = virtue
        self.audioURL = audioURL
    }
    
    public func meaning(for language: LanguageCode) -> String {
        return meanings[language] ?? meanings[.tr] ?? ""
    }
    
    public func copyText(for language: LanguageCode) -> String {
        let m = meaning(for: language)
        return "\(name) (\(title)) - \(m)"
    }
}
