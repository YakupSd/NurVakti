import Foundation

struct GuidanceItem: Identifiable, Codable {
    let id: UUID
    let type: GuidanceType
    let text: String
    let source: String?
    let translation: String?
    
    enum GuidanceType: String, Codable {
        case ayat
        case hadith
    }
}

class GuidanceService {
    static let shared = GuidanceService()
    
    private let ayats: [String: [GuidanceItem]] = [
        "tr": [
            GuidanceItem(id: UUID(), type: .ayat, text: "Allah size yardım ederse, artık size galip gelecek hiç kimse yoktur.", source: "Âl-i İmrân, 160", translation: nil),
            GuidanceItem(id: UUID(), type: .ayat, text: "Şüphesiz güçlükle beraber bir kolaylık vardır.", source: "İnşirah, 5", translation: nil),
            GuidanceItem(id: UUID(), type: .ayat, text: "Benim rahmetim her şeyi kuşatmıştır.", source: "A'râf, 156", translation: nil)
        ],
        "en": [
            GuidanceItem(id: UUID(), type: .ayat, text: "If Allah helps you, none can overcome you.", source: "Al-Imran, 160", translation: nil),
            GuidanceItem(id: UUID(), type: .ayat, text: "Indeed, with hardship [will be] ease.", source: "Ash-Sharh, 5", translation: nil),
            GuidanceItem(id: UUID(), type: .ayat, text: "My mercy encompasses all things.", source: "Al-A'raf, 156", translation: nil)
        ]
        // Diğer diller eklenecek...
    ]
    
    private let hadiths: [String: [GuidanceItem]] = [
        "tr": [
            GuidanceItem(id: UUID(), type: .hadith, text: "Kolaylaştırın, zorlaştırmayın; müjdeleyin, nefret ettirmeyin.", source: "Buhârî, İlim, 11", translation: nil),
            GuidanceItem(id: UUID(), type: .hadith, text: "Sizin en hayırlınız, Kur'an'ı öğrenen ve öğretendir.", source: "Buhârî, Fezâilü’l-Kur’ân, 21", translation: nil)
        ],
        "en": [
            GuidanceItem(id: UUID(), type: .hadith, text: "Make things easy and do not make them difficult, cheer the people up and do not acknowledge them with aversion.", source: "Bukhari", translation: nil),
            GuidanceItem(id: UUID(), type: .hadith, text: "The best among you are those who learn the Quran and teach it.", source: "Bukhari", translation: nil)
        ]
    ]
    
    func getDailyGuidance(for language: LanguageCode) -> GuidanceItem {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
        
        let langCode = language.rawValue
        let languageAyats = ayats[langCode] ?? ayats["en"]!
        let languageHadiths = hadiths[langCode] ?? hadiths["en"]!
        
        // Gün aşırı Değiştir: Çift günler Ayet, Tek günler Hadis
        if dayOfYear % 2 == 0 {
            let index = dayOfYear % languageAyats.count
            return languageAyats[index]
        } else {
            let index = dayOfYear % languageHadiths.count
            return languageHadiths[index]
        }
    }
}
