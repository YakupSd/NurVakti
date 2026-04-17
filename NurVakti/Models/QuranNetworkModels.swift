import Foundation

// MARK: - API Response DTOs


// MARK: - Domain Models for Quran
public struct SurahInfo: Identifiable, Codable {
    public let id: Int
    public let nameArabic: String
    public var nameLocalized: [LanguageCode: String]
    public let englishName: String
    public let ayahCount: Int
    public let revelationType: RevelationType
    
    public init(id: Int, nameArabic: String, nameLocalized: [LanguageCode : String], englishName: String, ayahCount: Int, revelationType: RevelationType) {
        self.id = id
        self.nameArabic = nameArabic
        self.nameLocalized = nameLocalized
        self.englishName = englishName
        self.ayahCount = ayahCount
        self.revelationType = revelationType
    }
    
    public static var fatihaMock: SurahInfo {
        SurahInfo(id: 1, nameArabic: "الفاتحة", nameLocalized: [.tr: "Fatiha"], englishName: "Al-Fatiha", ayahCount: 7, revelationType: .makkah)
    }
}

public enum RevelationType: String, Codable {
    case makkah = "Meccan"
    case madinah = "Medinan"
    
    public func localizedName(for language: LanguageCode) -> String {
        switch (self, language) {
        case (.makkah, .tr): return "Mekkî"
        case (.madinah, .tr): return "Medenî"
        case (.makkah, .ar): return "مكية"
        case (.madinah, .ar): return "مدنية"
        // ... Diğer diller
        default: return self.rawValue
        }
    }
}

public struct AyahItem: Identifiable, Codable {
    public let id: Int
    public let arabicText: String
    public let translation: String
    public let surahNumber: Int
    public var tajweedText: String? = nil
    
    public init(id: Int, arabicText: String, translation: String, surahNumber: Int, tajweedText: String? = nil) {
        self.id = id
        self.arabicText = arabicText
        self.translation = translation
        self.surahNumber = surahNumber
        self.tajweedText = tajweedText
    }
}

public enum QuranReadingMode: String, Codable {
    case arabicOnly = "arabicOnly"
    case withTranslation = "withTranslation"
}

public enum QuranViewStyle: String, Codable {
    case list    // Mevcut kart görünümü
    case mushaf  // Geleneksel sayfa akışı
}
