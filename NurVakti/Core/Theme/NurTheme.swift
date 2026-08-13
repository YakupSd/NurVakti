import SwiftUI

// MARK: - NurVakti Beyaz Tema Sistemi
/// Tüm uygulamada kullanılacak merkezi renk ve stil sabitleri.
/// Koyu temadan beyaz temaya geçiş için oluşturuldu.

struct NurTheme {
    
    // MARK: - Arka Plan Renkleri
    /// Ana sayfa arka plan — sıcak krem
    static let background = Color(hex: "F8F6F0")
    /// Kart arka planı — saf beyaz
    static let cardBackground = Color.white
    /// İkincil arka plan — hafif gri
    static let secondaryBackground = Color(hex: "F0EDE6")
    
    // MARK: - Metin Renkleri
    /// Birincil metin — koyu lacivert
    static let textPrimary = Color(hex: "1A1A2E")
    /// İkincil metin
    static let textSecondary = Color(hex: "1A1A2E").opacity(0.55)
    /// Üçüncül metin
    static let textTertiary = Color(hex: "1A1A2E").opacity(0.35)
    /// Arapça metin — Mushaf kahverengisi
    static let textArabic = Color(hex: "2C1E11")
    
    // MARK: - Aksan Renkleri
    /// Altın aksan
    static let gold = Color(hex: "C9A84C")
    /// Altın hafif
    static let goldLight = Color(hex: "C9A84C").opacity(0.12)
    /// Yeşil aksan (Kıble, İslami takvim)
    static let green = Color(hex: "2D8B56")
    /// Yeşil hafif
    static let greenLight = Color(hex: "2D8B56").opacity(0.1)
    
    // MARK: - Ayırıcılar / Kenarlıklar
    static let separator = Color(hex: "1A1A2E").opacity(0.08)
    static let border = Color(hex: "1A1A2E").opacity(0.06)
    
    // MARK: - Gölge
    static let cardShadow = Color.black.opacity(0.04)
    static let cardShadowRadius: CGFloat = 8
}
