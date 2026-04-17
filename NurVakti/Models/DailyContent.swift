import Foundation

public enum DailyContentType: String, Codable {
    case ayat
    case hadith
    case dua
}

public struct DailyContent: Codable, Identifiable {
    public let id: UUID
    public let arabicText: String
    public let source: String       // e.g. "A'râf, 156" — same across languages
    public let type: DailyContentType
    
    // Dictionary for all 5 languages
    public let translations: [String: String]  // key = LanguageCode.rawValue
    
    public init(id: UUID = UUID(), arabicText: String, source: String, type: DailyContentType, translations: [String: String]) {
        self.id = id
        self.arabicText = arabicText
        self.source = source
        self.type = type
        self.translations = translations
    }
    
    // Computed: returns correct translation for current language
    public func translation(for language: LanguageCode) -> String {
        return translations[language.rawValue] 
            ?? translations["en"]          // English fallback
            ?? translations.values.first  // Any fallback
            ?? arabicText                  // Last resort
    }
    
    // Convenience for current app language
    public func currentTranslation(using manager: LocalizationManager) -> String {
        return translation(for: manager.currentLanguage)
    }
    
    // Share text (arabic + current translation + source)
    public func shareText(language: LanguageCode) -> String {
        """
        \(arabicText)
        
        \(translation(for: language))
        
        — \(source)
        """
    }
    
    public static let placeholder = DailyContent(
        id: UUID(),
        arabicText: "بِسْمِ اللَّهِ",
        source: "...",
        type: .ayat,
        translations: [
            "tr": "Yükleniyor...",
            "ar": "جارٍ التحميل...",
            "en": "Loading...",
            "de": "Wird geladen...",
            "pt": "Carregando..."
        ]
    )
}

public struct DailyAyahProvider {
    public static func ayah(for dayIndex: Int, language: LanguageCode) -> DailyContent {
        let ayahs: [(String, String, [String: String])] = [
            ("إِنَّ رَحْمَتِي وَسِعَتْ كُلَّ شَيْءٍ", "A'râf Suresi · 156. Ayet", [
                "tr": "Şüphesiz rahmetim her şeyi kuşatmıştır.",
                "en": "Indeed, My mercy encompasses all things.",
                "ar": "إن رحمتي وسعت كل شيء",
                "de": "Wahrlich, Meine Barmherzigkeit umfaßt alle Dinge.",
                "pt": "Na verdade, a Minha misericórdia abrange todas as coisas."
            ]),
            ("فَاصْبِرْ صَبْرًا جَمِيلًا", "Meâric Suresi · 5. Ayet", [
                "tr": "Öyleyse güzel bir sabırla sabret.",
                "en": "So be patient with gracious patience.",
                "ar": "فاصبر صبرا جميلا",
                "de": "So sei geduldig mit schöner Geduld.",
                "pt": "Sê pois paciente com bela paciência."
            ]),
            ("وَقُل رَّبِّ زِدْنِي عِلْمًا", "Tâhâ Suresi · 114. Ayet", [
                "tr": "De ki: 'Rabbim, benim ilmimi artır.'",
                "en": "And say, 'My Lord, increase me in knowledge.'",
                "ar": "وقل رب زدني علما",
                "de": "Und sag: 'Mein Herr, mehre mein Wissen.'",
                "pt": "Dize: 'Senhor meu, aumenta-me o conhecimento.'"
            ])
        ]
        
        let index = abs(dayIndex) % ayahs.count
        let (arabic, source, translations) = ayahs[index]
        
        return DailyContent(
            id: UUID(),
            arabicText: arabic,
            source: source,
            type: .ayat,
            translations: translations
        )
    }
}

public struct DailyDuaProvider {
    public static func dua(for dayIndex: Int, language: LanguageCode) -> DailyContent {
        let duas: [(String, String, [String: String])] = [
            ("رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً", "Bakara Suresi · 201. Ayet", [
                "tr": "Rabbimiz! Bize dünyada da iyilik ver...",
                "en": "Our Lord, give us in this world [that which is] good...",
                "ar": "ربنا آتنا في الدنيا حسنة",
                "de": "Unser Herr, gib uns in dieser Welt Gutes...",
                "pt": "Ó Senhor nosso, concede-nos o bem neste mundo..."
            ]),
            ("رَبِّ اشْرَحْ لِي صَدْرِي", "Tâhâ Suresi · 25. Ayet", [
                "tr": "Rabbim! Göğsümü genişlet...",
                "en": "My Lord, expand for me my chest [with assurance]...",
                "ar": "رب اشرح لي صدري",
                "de": "Mein Herr, veweite mir meine Brust...",
                "pt": "Senhor meu, dilata-me o peito..."
            ])
        ]
        
        let index = abs(dayIndex) % duas.count
        let (arabic, source, translations) = duas[index]
        
        return DailyContent(
            id: UUID(),
            arabicText: arabic,
            source: source,
            type: .dua,
            translations: translations
        )
    }
}
