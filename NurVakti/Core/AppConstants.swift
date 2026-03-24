import SwiftUI

enum LanguageCode: String, CaseIterable, Codable {
    case tr, ar, en, de, pt
    
    var displayName: String {
        switch self {
        case .tr: return "Türkçe"
        case .ar: return "العربية"
        case .en: return "English"
        case .de: return "Deutsch"
        case .pt: return "Português"
        }
    }
    
    var flag: String {
        switch self {
        case .tr: return "🇹🇷"
        case .ar: return "🇸🇦"
        case .en: return "🇺🇸"
        case .de: return "🇩🇪"
        case .pt: return "🇵🇹"
        }
    }
    
    var isRTL: Bool {
        return self == .ar
    }
    
    var locale: Locale {
        return Locale(identifier: self.rawValue)
    }
    
    var languageName_pt: String {
        switch self {
        case .tr: return "Turco"
        case .ar: return "Árabe"
        case .en: return "Inglês"
        case .de: return "Alemão"
        case .pt: return "Português"
        }
    }
}

enum PrayerName: String, CaseIterable, Codable {
    case imsak, fajr, sunrise, dhuhr, asr, maghrib, isha
    
    func localizedName(for language: LanguageCode) -> String {
        switch self {
        case .imsak:   return NSLocalizedString("prayer.imsak", comment: "")
        case .fajr:    return NSLocalizedString("prayer.fajr", comment: "")
        case .sunrise: return NSLocalizedString("prayer.sunrise", comment: "")
        case .dhuhr:   return NSLocalizedString("prayer.dhuhr", comment: "")
        case .asr:     return NSLocalizedString("prayer.asr", comment: "")
        case .maghrib: return NSLocalizedString("prayer.maghrib", comment: "")
        case .isha:    return NSLocalizedString("prayer.isha", comment: "")
        }
    }
    
    var startColor: Color {
        switch self {
        case .imsak: return Color(hex: "0F2027")
        case .fajr: return Color(hex: "2C3E50")
        case .sunrise: return Color(hex: "FF8C00")
        case .dhuhr: return Color(hex: "4FA8F8")
        case .asr: return Color(hex: "F39C12")
        case .maghrib: return Color(hex: "E67E22")
        case .isha: return Color(hex: "2C3E50")
        }
    }
    
    var symbol: String {
        switch self {
        case .imsak: return "moon.stars.fill"
        case .fajr: return "sunrise.fill"
        case .sunrise: return "sun.max.fill"
        case .dhuhr: return "sun.max.fill"
        case .asr: return "sun.horizon.fill"
        case .maghrib: return "sunset.fill"
        case .isha: return "moon.fill"
        }
    }
}

enum FontSize: String, CaseIterable, Codable {
    case small, medium, large, xlarge
    
    var title: CGFloat {
        switch self {
        case .small: return 24
        case .medium: return 28
        case .large: return 30
        case .xlarge: return 34
        }
    }
    
    var body: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        case .xlarge: return 22
        }
    }
    
    var caption: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 12
        case .large: return 14
        case .xlarge: return 16
        }
    }
    var scaleFactor: CGFloat {
        switch self {
        case .small: return 0.85
        case .medium: return 1.0
        case .large: return 1.2
        case .xlarge: return 1.4
        }
    }
}

enum ZikirType: String, CaseIterable, Codable {
    case subhanallah, elhamdulillah, allahuekber, lailaheillallah, salavat, custom
    
    var arabicText: String {
        switch self {
        case .subhanallah: return "سبحان الله"
        case .elhamdulillah: return "الحمد لله"
        case .allahuekber: return "الله أكبر"
        case .lailaheillallah: return "لا إله إلا الله"
        case .salavat: return "اللهم صل على محمد"
        case .custom: return ""
        }
    }
    
    func meaning(for language: LanguageCode) -> String {
        switch (self, language) {
        case (.subhanallah, .tr): return "Allah noksan sıfatlardan uzaktır"
        case (.subhanallah, .en): return "Glory be to Allah"
        case (.elhamdulillah, .tr): return "Hamd ve övgü Allah'adır"
        case (.elhamdulillah, .en): return "Praise be to Allah"
        case (.allahuekber, .tr): return "Allah en büyüktür"
        case (.allahuekber, .en): return "Allah is the Greatest"
        case (.lailaheillallah, .tr): return "Allah'tan başka ilah yoktur"
        case (.lailaheillallah, .en): return "There is no god but Allah"
        case (.salavat, .tr): return "Allah Muhammed'e rahmet eylesin"
        case (.salavat, .en): return "O Allah, bless Muhammad"
        case (.custom, _): return ""
        default: return ""
        }
    }
    
    var defaultTarget: Int {
        switch self {
        case .custom: return 100
        default: return 33
        }
    }
}

struct AppConstants {
    static let defaultPrayerMethod = "Diyanet"
    static let supportedCalcMethods = [
        "Diyanet", "Muslim World League", 
        "ISNA", "Egypt", "Karachi", "Tehran"
    ]
}
