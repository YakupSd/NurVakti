import Foundation

// MARK: - API Response DTOs
struct SurahListResponse: Codable {
    let code: Int
    let status: String
    let data: [SurahDTO]
}

struct SurahDTO: Codable {
    let number: Int
    let name: String
    let englishName: String
    let numberOfAyahs: Int
    let revelationType: String
}

struct SurahDetailResponse: Codable {
    let code: Int
    let status: String
    let data: SurahDetailData
}

struct SurahDetailData: Codable {
    let number: Int
    let ayahs: [AyahDTO]
}

struct AyahDTO: Codable {
    let number: Int
    let text: String
    let numberInSurah: Int
    let surah: SurahDTO?
}

// MARK: - Aladhan Prayer Times API DTOs
struct AladhanResponse: Codable {
    let code: Int
    let status: String
    let data: [AladhanDayData]
}

struct AladhanDayData: Codable {
    let timings: [String: String]
    let date: AladhanDate
}

struct AladhanDate: Codable {
    let readable: String
    let timestamp: String
    let hijri: AladhanHijri
}

struct AladhanHijri: Codable {
    let date: String
    let day: String
    let weekday: AladhanWeekday
    let month: AladhanMonth
    let year: String
}

struct AladhanWeekday: Codable {
    let en: String
    let ar: String?
}

struct AladhanMonth: Codable {
    let number: Int
    let en: String
    let ar: String?
}

// MARK: - Domain Models for Quran
struct SurahInfo: Identifiable, Codable {
    let id: Int
    let nameArabic: String
    var nameLocalized: [LanguageCode: String]
    let englishName: String
    let ayahCount: Int
    let revelationType: RevelationType
}

enum RevelationType: String, Codable {
    case makkah = "Meccan"
    case madinah = "Medinan"
    
    func localizedName(for language: LanguageCode) -> String {
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

struct AyahItem: Identifiable, Codable {
    let id: Int
    let arabicText: String
    let translation: String
    let surahNumber: Int
    var tajweedText: String? = nil
}

enum QuranReadingMode: String, Codable {
    case arabicOnly = "arabicOnly"
    case withTranslation = "withTranslation"
}

enum QuranViewStyle: String, Codable {
    case list    // Mevcut kart görünümü
    case mushaf  // Geleneksel sayfa akışı
}
