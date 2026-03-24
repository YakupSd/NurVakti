import UIKit

// MARK: - NurVakti Haptic Strategy
// Merkezi dokunsal geri bildirim yöneticisi.
// Tüm componentlar bu sınıfı kullanır — dağılmış UIImpactFeedbackGenerator yok.
//
// Kullanım haritası:
//   .tap       → Genel buton dokunuşu (NurButton)
//   .dhikrCount → Zikirmatik her sayımda
//   .dhikrDone  → Zikir hedefine ulaşıldı
//   .prayerAlert → Vakit girişi bildirimi
//   .success    → İzin verildi, kayıt tamamlandı
//   .warning    → Sayaç sıfırlama gibi geri alınamaz işlem
//   .error      → Ağ hatası, hesaplama hatası

final class HapticManager {
    static let shared = HapticManager()
    private init() {}

    // Cached generators — her seferinde yeni nesne yaratmak performansı düşürür
    private let lightGen   = UIImpactFeedbackGenerator(style: .light)
    private let mediumGen  = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGen   = UIImpactFeedbackGenerator(style: .heavy)
    private let notifGen   = UINotificationFeedbackGenerator()
    private let selectionGen = UISelectionFeedbackGenerator()

    // MARK: - Public API

    /// Hafif dokunuş — dil seçimi, sekme geçişi, küçük toggle
    func tap() {
        lightGen.impactOccurred()
    }
    
    func light() {
        lightGen.impactOccurred()
    }

    /// Zikir sayımı — her artışta orta darbe
    func dhikrCount() {
        mediumGen.impactOccurred(intensity: 0.7)
    }

    /// Zikir hedefine ulaşıldı — çift darbe hissi
    func dhikrDone() {
        mediumGen.impactOccurred(intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            self?.mediumGen.impactOccurred(intensity: 0.6)
        }
    }

    /// Vakit girişi / ezan zamanı — güçlü tek darbe
    func prayerAlert() {
        heavyGen.impactOccurred()
    }

    /// Başarı — izin verildi, kayıt tamamlandı, onboarding bitti
    func success() {
        notifGen.notificationOccurred(.success)
    }

    /// Uyarı — sıfırlama, geri alınamaz işlem
    func warning() {
        notifGen.notificationOccurred(.warning)
    }

    /// Hata — ağ hatası, konum hatası, hesaplama hatası
    func error() {
        notifGen.notificationOccurred(.error)
    }

    /// Seçim değişimi — picker, segment control
    func selectionChanged() {
        selectionGen.selectionChanged()
    }

    // MARK: - Prepare (performans için önceden ısıt)
    func prepareAll() {
        lightGen.prepare()
        mediumGen.prepare()
        heavyGen.prepare()
        notifGen.prepare()
        selectionGen.prepare()
    }
}
