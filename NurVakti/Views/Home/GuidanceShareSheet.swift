import SwiftUI

public struct GuidanceShareSheet: View {
    public let content: DailyContent
    @EnvironmentObject var localization: LocalizationManager
    
    public init(content: DailyContent) {
        self.content = content
    }
    
    public var body: some View {
        let title: String = {
            switch content.type {
            case .ayat:
                switch localization.currentLanguage {
                case .tr: return "GÜNÜN AYET-İ KERİMESİ"
                case .en: return "VERSE OF THE DAY"
                case .ar: return "آية اليوم"
                case .de: return "VERS DES TAGES"
                case .pt: return "VERSÍCULO DO DIA"
                }
            case .hadith:
                switch localization.currentLanguage {
                case .tr: return "GÜNÜN HADİS-İ ŞERİFİ"
                case .en: return "HADITH OF THE DAY"
                case .ar: return "حديث اليوم"
                case .de: return "HADITH DES TAGES"
                case .pt: return "HADITH DO DIA"
                }
            case .dua:
                switch localization.currentLanguage {
                case .tr: return "GÜNÜN DUASI"
                case .en: return "PRAYER OF THE DAY"
                case .ar: return "دعاء اليوم"
                case .de: return "GEBET DES TAGES"
                case .pt: return "ORAÇÃO DO DIA"
                }
            }
        }()
        
        let message = SpiritualMessage(
            id: content.id.uuidString,
            title: title,
            arabicText: content.arabicText,
            text: content.translation(for: localization.currentLanguage),
            authorOrSource: content.source,
            category: .dailyWisdom,
            tags: ["günlük", "ayet", "hadis"]
        )
        
        SpiritualShareSheet(message: message)
    }
}
