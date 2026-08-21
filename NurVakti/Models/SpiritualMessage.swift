import Foundation
import SwiftUI

// MARK: - Message Category
public enum SpiritualCategory: String, CaseIterable, Codable, Identifiable {
    case all = "all"
    case friday = "friday"
    case kandil = "kandil"
    case bayram = "bayram"
    case specialDays = "specialDays"
    case dailyWisdom = "dailyWisdom"
    case favorites = "favorites"
    
    public var id: String { rawValue }
    
    public func title(for lang: LanguageCode) -> String {
        switch self {
        case .all:
            switch lang {
            case .tr: return "Tümü"
            case .en: return "All"
            case .ar: return "الكل"
            case .de: return "Alle"
            case .pt: return "Todos"
            }
        case .friday:
            switch lang {
            case .tr: return "Cuma Mesajları"
            case .en: return "Friday Greetings"
            case .ar: return "رسائل الجمعة"
            case .de: return "Freitagsgrüße"
            case .pt: return "Mensagens de Sexta"
            }
        case .kandil:
            switch lang {
            case .tr: return "Kandil Mesajları"
            case .en: return "Kandil Nights"
            case .ar: return "رسائل الليالي المباركة"
            case .de: return "Kandil-Nächte"
            case .pt: return "Noites Sagradas"
            }
        case .bayram:
            switch lang {
            case .tr: return "Bayram Tebrikleri"
            case .en: return "Eid Greetings"
            case .ar: return "تهاني العيد"
            case .de: return "Eid-Grüße"
            case .pt: return "Mensagens de Eid"
            }
        case .specialDays:
            switch lang {
            case .tr: return "Özel Günler"
            case .en: return "Special Days"
            case .ar: return "أيام خاصة"
            case .de: return "Besondere Tage"
            case .pt: return "Dias Especiais"
            }
        case .dailyWisdom:
            switch lang {
            case .tr: return "Günün Sözü"
            case .en: return "Daily Wisdom"
            case .ar: return "حكمة اليوم"
            case .de: return "Wort des Tages"
            case .pt: return "Sabedoria Diária"
            }
        case .favorites:
            switch lang {
            case .tr: return "Favorilerim"
            case .en: return "Favorites"
            case .ar: return "المفضلة"
            case .de: return "Favoriten"
            case .pt: return "Favoritos"
            }
        }
    }
    
    public var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .friday: return "sparkles"
        case .kandil: return "moon.stars.fill"
        case .bayram: return "sun.max.fill"
        case .specialDays: return "calendar.badge.clock"
        case .dailyWisdom: return "quote.opening"
        case .favorites: return "heart.fill"
        }
    }
}

// MARK: - Kandil Sub-Type
public enum KandilSubType: String, CaseIterable, Codable, Identifiable {
    case mevlid = "mevlid"
    case regaip = "regaip"
    case mirac = "mirac"
    case berat = "berat"
    case kadir = "kadir"
    
    public var id: String { rawValue }
    
    public func title(for lang: LanguageCode) -> String {
        switch self {
        case .mevlid:
            switch lang {
            case .tr: return "Mevlid Kandili"
            case .en: return "Mawlid al-Nabi"
            case .ar: return "المولد النبوي"
            case .de: return "Mawlid an-Nabi"
            case .pt: return "Mawlid an-Nabi"
            }
        case .regaip:
            switch lang {
            case .tr: return "Regaip Kandili"
            case .en: return "Raghaib Night"
            case .ar: return "ليلة الرغائب"
            case .de: return "Regaib-Nacht"
            case .pt: return "Noite de Raghaib"
            }
        case .mirac:
            switch lang {
            case .tr: return "Miraç Kandili"
            case .en: return "Isra & Mi'raj"
            case .ar: return "الإسراء والمعراج"
            case .de: return "Isra und Miradsch"
            case .pt: return "Isra e Miraj"
            }
        case .berat:
            switch lang {
            case .tr: return "Berat Kandili"
            case .en: return "Laylat al-Bara'ah"
            case .ar: return "ليلة البراءة"
            case .de: return "Laylat al-Baraat"
            case .pt: return "Noite da Absolvição"
            }
        case .kadir:
            switch lang {
            case .tr: return "Kadir Gecesi"
            case .en: return "Laylat al-Qadr"
            case .ar: return "ليلة القدر"
            case .de: return "Laylat al-Qadr"
            case .pt: return "Laylat al-Qadr"
            }
        }
    }
}

// MARK: - Bayram Sub-Type
public enum BayramSubType: String, CaseIterable, Codable, Identifiable {
    case ramadan = "ramadan"
    case eidAlAdha = "eidAlAdha"
    case arafah = "arafah"
    
    public var id: String { rawValue }
    
    public func title(for lang: LanguageCode) -> String {
        switch self {
        case .ramadan:
            switch lang {
            case .tr: return "Ramazan Bayramı"
            case .en: return "Eid al-Fitr"
            case .ar: return "عيد الفطر"
            case .de: return "Eid al-Fitr"
            case .pt: return "Eid al-Fitr"
            }
        case .eidAlAdha:
            switch lang {
            case .tr: return "Kurban Bayramı"
            case .en: return "Eid al-Adha"
            case .ar: return "عيد الأضحى"
            case .de: return "Eid al-Adha"
            case .pt: return "Eid al-Adha"
            }
        case .arafah:
            switch lang {
            case .tr: return "Arefe Günü"
            case .en: return "Day of Arafah"
            case .ar: return "يوم عرفة"
            case .de: return "Tag von Arafah"
            case .pt: return "Dia de Arafá"
            }
        }
    }
}

// MARK: - Spiritual Story Card Theme
public enum StoryTheme: String, CaseIterable, Identifiable {
    case midnight = "midnight"    // Koyu Gece & Altın
    case emerald = "emerald"      // Zümrüt Yeşili & Altın
    case ivory = "ivory"          // Fildişi Sedef & Altın
    case kaabaNoir = "kaabaNoir"  // Kabe Asaleti & Kiswa Altın
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .midnight: return "Gece Kadifesi"
        case .emerald: return "Zümrüt Yeşili"
        case .ivory: return "Fildişi Sedef"
        case .kaabaNoir: return "Kabe Asaleti"
        }
    }
    
    public var icon: String {
        switch self {
        case .midnight: return "moon.fill"
        case .emerald: return "leaf.fill"
        case .ivory: return "sparkles"
        case .kaabaNoir: return "seal.fill"
        }
    }
    
    public var backgroundColors: [Color] {
        switch self {
        case .midnight:
            return [Color(hex: "#0E1626"), Color(hex: "#070B14"), Color(hex: "#020408")]
        case .emerald:
            return [Color(hex: "#0A2818"), Color(hex: "#051A0F"), Color(hex: "#020D07")]
        case .ivory:
            return [Color(hex: "#FAF8F5"), Color(hex: "#F2EDE4"), Color(hex: "#E8E0D2")]
        case .kaabaNoir:
            return [Color(hex: "#161616"), Color(hex: "#0A0A0A"), Color(hex: "#000000")]
        }
    }
    
    public var isLight: Bool {
        return self == .ivory
    }
    
    public var primaryTextColor: Color {
        return isLight ? Color(hex: "#1A1A2E") : Color.white
    }
    
    public var secondaryTextColor: Color {
        return isLight ? Color(hex: "#1A1A2E").opacity(0.75) : Color.white.opacity(0.85)
    }
    
    public var goldAccent: Color {
        return isLight ? Color(hex: "#996515") : Color(hex: "#E5C158")
    }
    
    public var cardBackground: Color {
        return isLight ? Color.white.opacity(0.88) : Color.white.opacity(0.08)
    }
    
    public var cardBorder: Color {
        return isLight ? Color(hex: "#D4AF37").opacity(0.4) : Color(hex: "#D4AF37").opacity(0.6)
    }
}

// MARK: - Spiritual Message Model
public struct SpiritualMessage: Identifiable, Codable, Equatable {
    public let id: String
    public let title: String
    public let arabicText: String?
    public let text: String
    public let authorOrSource: String?
    public let category: SpiritualCategory
    public let subCategory: String? // e.g. "mevlid", "ramadan"
    public let tags: [String]
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        arabicText: String? = nil,
        text: String,
        authorOrSource: String? = nil,
        category: SpiritualCategory,
        subCategory: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.arabicText = arabicText
        self.text = text
        self.authorOrSource = authorOrSource
        self.category = category
        self.subCategory = subCategory
        self.tags = tags
    }
    
    /// Formatted text ready for clipboard or sharing
    public var formattedShareText: String {
        var result = ""
        if !title.isEmpty {
            result += "✨ \(title) ✨\n\n"
        }
        if let arabic = arabicText, !arabic.isEmpty {
            result += "\(arabic)\n\n"
        }
        result += "\(text)\n"
        if let source = authorOrSource, !source.isEmpty {
            result += "\n— \(source)\n"
        }
        result += "\n🤲 NurVakti ile Hayırlı Vakitler"
        return result
    }
}
