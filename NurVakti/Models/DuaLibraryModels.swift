import Foundation
import SwiftUI

// MARK: - Library Category (separate from DuaItem.DuaCategory)
public enum LibraryCategory: String, Codable, CaseIterable {
    case morningEvening = "morning_evening"
    case prayer         = "prayer"
    case quranAyah      = "quran_ayah"
    case rabbena        = "rabbena"
    case daily          = "daily"
    case protection     = "protection"
    
    public func localizedName(for lang: LanguageCode) -> String {
        switch self {
        case .morningEvening:
            return ["tr":"Sabah & Akşam", "ar":"الأذكار", "en":"Morning & Evening", "de":"Morgen & Abend", "pt":"Manhã & Tarde"][lang.rawValue] ?? rawValue
        case .prayer:
            return ["tr":"Namaz Duaları", "ar":"أدعية الصلاة", "en":"Prayer Duas", "de":"Gebetsbitten", "pt":"Duas de Oração"][lang.rawValue] ?? rawValue
        case .quranAyah:
            return ["tr":"Kur'an Ayetleri", "ar":"آيات قرآنية", "en":"Quranic Verses", "de":"Koranverse", "pt":"Versículos do Alcorão"][lang.rawValue] ?? rawValue
        case .rabbena:
            return ["tr":"Rabbenâ Duaları", "ar":"أدعية ربنا", "en":"Rabbana Duas", "de":"Rabbana-Bittgebete", "pt":"Duas Rabbana"][lang.rawValue] ?? rawValue
        case .daily:
            return ["tr":"Günlük Dualar", "ar":"أدعية يومية", "en":"Daily Duas", "de":"Tägliche Bitten", "pt":"Duas Diárias"][lang.rawValue] ?? rawValue
        case .protection:
            return ["tr":"Koruma & Şifa", "ar":"الحماية والشفاء", "en":"Protection & Healing", "de":"Schutz & Heilung", "pt":"Proteção e Cura"][lang.rawValue] ?? rawValue
        }
    }
    
    public var icon: String {
        switch self {
        case .morningEvening: return "sunrise.fill"
        case .prayer:         return "figure.stand"
        case .quranAyah:      return "book.fill"
        case .rabbena:        return "hands.sparkles.fill"
        case .daily:          return "clock.fill"
        case .protection:     return "shield.fill"
        }
    }
    
    public var accentColor: Color {
        switch self {
        case .morningEvening: return Color(hex: "#C9A84C")
        case .prayer:         return Color(hex: "#378ADD")
        case .quranAyah:      return Color(hex: "#639922")
        case .rabbena:        return Color(hex: "#7F77DD")
        case .daily:          return Color(hex: "#1D9E75")
        case .protection:     return Color(hex: "#D4537E")
        }
    }
}

// MARK: - Routine Slot
public enum RoutineSlot: String, Codable {
    case morning = "morning"
    case evening = "evening"
    case both    = "both"
    case none    = "none"
}

// MARK: - Dua User State
public struct DuaUserState: Codable, Identifiable {
    public let id: String                    // matches PrayerDua.id
    public var isFavourite: Bool = false
    public var routineSlot: RoutineSlot = .none
    public var isReadToday: Bool = false   // reset daily at midnight
    public var lastReadDate: Date?
    public var personalNote: String = ""
    public var routineOrder: Int = 999     // sort order within routine
    
    public init(id: String, isFavourite: Bool = false, routineSlot: RoutineSlot = .none, isReadToday: Bool = false, lastReadDate: Date? = nil, personalNote: String = "", routineOrder: Int = 999) {
        self.id = id
        self.isFavourite = isFavourite
        self.routineSlot = routineSlot
        self.isReadToday = isReadToday
        self.lastReadDate = lastReadDate
        self.personalNote = personalNote
        self.routineOrder = routineOrder
    }
}

// MARK: - Dua Library Item
public struct DuaLibraryItem: Identifiable {
    public let dua: PrayerDua
    public var userState: DuaUserState
    public var id: String { dua.id }
    
    public init(dua: PrayerDua, userState: DuaUserState) {
        self.dua = dua
        self.userState = userState
    }
    
    public var isFavourite: Bool {
        get { userState.isFavourite }
        set { userState.isFavourite = newValue }
    }
}
