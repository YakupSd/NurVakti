import SwiftUI
import UIKit

// MARK: - Mushaf Range (Formerly TajweedRange)
struct MushafRange: Codable, Equatable {
    let start: Int
    let length: Int
    let rule: String // Generic rule type
}

// MARK: - Ayah Model
struct AyahModel: Identifiable, Codable, Equatable {
    let id: Int
    let surahNumber: Int
    let ayahNumber: Int
    let arabicText: String
    let tajweedRanges: [MushafRange] // Kept for future non-color highlights
    
    var displayId: String {
        "﴿\(String(ayahNumber).toArabicNumerals())﴾"
    }
}

// MARK: - Mushaf Page Model
struct MushafPageModel: Codable, Equatable {
    let pageNumber: Int
    let surahNumber: Int
    let surahName: String
    let isMakki: Bool
    let ayahs: [AyahModel]
    let lineCount: Int
    
    static var mock: MushafPageModel {
        MushafPageModel(
            pageNumber: 1,
            surahNumber: 1,
            surahName: "Fâtiha",
            isMakki: true,
            ayahs: [
                AyahModel(id: 1, surahNumber: 1, ayahNumber: 1, arabicText: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", tajweedRanges: [])
            ],
            lineCount: 15
        )
    }
}

// MARK: - Numeric Extension
extension String {
    func toArabicNumerals() -> String {
        let arabicMap = [
            "0": "٠", "1": "١", "2": "٢", "3": "٣", "4": "٤",
            "5": "٥", "6": "٦", "7": "٧", "8": "٨", "9": "٩"
        ]
        return self.map { arabicMap[String($0)] ?? String($0) }.joined()
    }
}

// MARK: - Color Extension for Mushaf
extension Color {
    static let mushafBackground = Color(hex: "#FDF6E3") // Premium Ivory
    static let nurGoldPremium = Color(hex: "#C9A84C")
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
