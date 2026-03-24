import SwiftUI

struct PrayerTheme: Equatable {
    let prayerName: PrayerName
    let topColor: Color
    let bottomColor: Color
    let starOpacity: Double      // Gece vakitlerinde yıldız göster
    let sunPosition: Double      // Güneş ikonunun dikey pozisyonu (0-1)
    let auraColor: Color         // Hareketli ışık hüzmesi rengi
    let ambientLabel: String     // "Seher vakti", "Gün ortası" vb. (lokalize)
    
    // MARK: - Static Factory Metotları
    
    static let imsakTheme = PrayerTheme(
        prayerName: .imsak,
        topColor: Color(hex: "020111"),
        bottomColor: Color(hex: "1a2a6c"),
        starOpacity: 0.9,
        sunPosition: -0.2,
        auraColor: Color(hex: "4b6cb7").opacity(0.3),
        ambientLabel: "Seher Vakti"
    )
    
    static let fajrTheme = PrayerTheme(
        prayerName: .fajr,
        topColor: Color(hex: "0d1b2a"),
        bottomColor: Color(hex: "000000"),
        starOpacity: 0.6,
        sunPosition: -0.1,
        auraColor: Color(hex: "6a11cb").opacity(0.2),
        ambientLabel: "Tan Yeri"
    )
    
    static let sunriseTheme = PrayerTheme(
        prayerName: .sunrise,
        topColor: Color(hex: "0f2027"),
        bottomColor: Color(hex: "2c5364"),
        starOpacity: 0.0,
        sunPosition: 0.1,
        auraColor: Color(hex: "ffb347").opacity(0.4),
        ambientLabel: "Gün Doğumu"
    )
    
    static let dhuhrTheme = PrayerTheme(
        prayerName: .dhuhr,
        topColor: Color(hex: "0D1B2A"),
        bottomColor: Color(hex: "1B263B"),
        starOpacity: 0.0,
        sunPosition: 0.9,
        auraColor: Color(hex: "4facfe").opacity(0.3),
        ambientLabel: "Öğle Güneşi"
    )
    
    static let asrTheme = PrayerTheme(
        prayerName: .asr,
        topColor: Color(hex: "0f0c29"),
        bottomColor: Color(hex: "302b63"),
        starOpacity: 0.0,
        sunPosition: 0.5,
        auraColor: Color(hex: "f093fb").opacity(0.2),
        ambientLabel: "İkindi Vakti"
    )
    
    static let maghribTheme = PrayerTheme(
        prayerName: .maghrib,
        topColor: Color(hex: "141e30"),
        bottomColor: Color(hex: "243b55"),
        starOpacity: 0.3,
        sunPosition: 0.0,
        auraColor: Color(hex: "f83600").opacity(0.3),
        ambientLabel: "Akşam Sefası"
    )
    
    static let ishaTheme = PrayerTheme(
        prayerName: .isha,
        topColor: Color(hex: "000000"),
        bottomColor: Color(hex: "0f2027"),
        starOpacity: 1.0,
        sunPosition: -0.5,
        auraColor: Color(hex: "7f7fd5").opacity(0.2),
        ambientLabel: "Yatsı Huzuru"
    )
}

// Helpers for PrayerTheme selection
extension PrayerTheme {
    static func theme(for prayer: PrayerName) -> PrayerTheme {
        switch prayer {
        case .imsak: return imsakTheme
        case .fajr: return fajrTheme
        case .sunrise: return sunriseTheme
        case .dhuhr: return dhuhrTheme
        case .asr: return asrTheme
        case .maghrib: return maghribTheme
        case .isha: return ishaTheme
        }
    }
}
