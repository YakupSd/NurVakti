import AVFoundation
import UIKit

// MARK: - SoundService
// Ezan ve sistem sesi oynatma.
// Ezan ses dosyaları Bundle'dan yüklenir (bkz. not).
//
// Ses Dosyası Kararı:
//   → Bundle'a dahil edilecek. Toplam dosya boyutu ~3MB.
//   → Dosya adı: "ezan.mp3" (varsayılan) ve "ezan_fajr.mp3" (sabah ezanı, farklı makam)
//   → Xcode'da "NurVakti" target'ına eklenmeleri gerekir.
//
// Desteklenen AlarmSound case'leri:
//   .ezan   → Bundle'daki ezan.mp3
//   .fajr   → Bundle'daki ezan_fajr.mp3 (sabah için daha yavaş)
//   .system → Sistem sesleri (UINotificationFeedbackGenerator)
//   .silent → Sadece haptic, ses yok

final class SoundService: NSObject {
    static let shared = SoundService()
    private override init() {
        super.init()
        configureAudioSession()
    }

    private var player: AVAudioPlayer?
    private var isPlaying: Bool { player?.isPlaying ?? false }

    // MARK: - Audio Session
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("SoundService: Audio session error — \(error)")
        }
    }

    // MARK: - Play
    func play(sound: AlarmSound) {
        switch sound {
        case .ezan:
            playBundleAudio(named: "ezan", ext: "mp3")
        case .fajr:
            playBundleAudio(named: "ezan_fajr", ext: "mp3")
        case .system:
            AudioServicesPlaySystemSound(1005) // SMS alındı sesi
            HapticManager.shared.prayerAlert()
        case .silent:
            HapticManager.shared.prayerAlert()
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }

    // MARK: - Bundle Audio
    private func playBundleAudio(named name: String, ext: String) {
        // Ezan dosyası henüz Bundle'da yoksa haptic ile fallback yap
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("SoundService: '\(name).\(ext)' Bundle'da bulunamadı — haptic fallback")
            HapticManager.shared.prayerAlert()
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("SoundService: Oynatma hatası — \(error)")
            HapticManager.shared.prayerAlert()
        }
    }

    // MARK: - Preview / Test
    func previewSound(_ sound: AlarmSound) {
        if isPlaying { stop() }
        play(sound: sound)
        // 3 saniye sonra durdur (preview amaçlı)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.stop()
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension SoundService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
    }
}

// MARK: - AlarmSound Extension (SoundService entegrasyonu)
extension AlarmSound {
    /// AlarmView'da ses seçimi için kullanıcı dostu ad
    func displayName(language: LanguageCode) -> String {
        switch (self, language) {
        case (.ezan,   .tr): return "Ezan"
        case (.ezan,   .en): return "Adhan"
        case (.ezan,   .ar): return "الأذان"
        case (.ezan,   .de): return "Adhan"
        case (.ezan,   .pt): return "Adhan"

        case (.fajr,   .tr): return "Sabah Ezanı"
        case (.fajr,   .en): return "Fajr Adhan"
        case (.fajr,   .ar): return "أذان الفجر"
        case (.fajr,   .de): return "Fajr-Adhan"
        case (.fajr,   .pt): return "Adhan do Fajr"

        case (.system, .tr): return "Sistem Sesi"
        case (.system, .en): return "System Sound"
        case (.system, .ar): return "صوت النظام"

        case (.silent, .tr): return "Titreşim"
        case (.silent, .en): return "Vibrate Only"
        case (.silent, .ar): return "اهتزاز فقط"

        default: return self.rawValue.capitalized
        }
    }

    var sfSymbol: String {
        switch self {
        case .ezan:   return "speaker.wave.3.fill"
        case .fajr:   return "sunrise.fill"
        case .system: return "bell.fill"
        case .silent: return "iphone.radiowaves.left.and.right"
        }
    }
}
