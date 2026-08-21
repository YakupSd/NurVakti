import Foundation
import UIKit
import Combine

@MainActor
public enum AudioIDType: Equatable {
    case ayahID(surah: Int, ayah: Int)   // e.g. "002255" → surah 2, ayah 255
    case surahID(surah: Int)             // e.g. "112"    → play all ayahs sequentially
    case directURL(URL)                  // explicit https:// URL
    case localFile(String)               // bundle resource file
}

@MainActor
public class AudioManager: ObservableObject {
    public static let shared = AudioManager()

    @Published public var isPlaying = false
    @Published public var isBuffering = false
    @Published public var currentPlayingID: String? = nil

    // Sequential playback queue (for multi-ayah surahs like İhlâs, Felak, Nas)
    private var ayahQueue: [URL] = []
    private var currentQueueIndex = 0
    private var isSequentialMode = false

    private let audioService = AudioService.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupBindings()
    }

    private func setupBindings() {
        audioService.onPlaybackStatusChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playing in
                guard let self else { return }
                if !playing && self.isSequentialMode {
                    self.playNextInQueue()
                } else {
                    self.isPlaying = playing
                }
            }
            .store(in: &cancellables)

        audioService.onBufferingStatusChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isBuffering in
                self?.isBuffering = isBuffering
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API

    /// Main entry: play a PrayerDua.
    /// Priority: audioURL (only everyayah CDN trusted) → audioFileName → error
    public func playPrayerDua(_ dua: PrayerDua) {
        let lang = LocalizationManager.shared.currentLanguage.rawValue
        let title = dua.titles[lang] ?? dua.titles["tr"] ?? "Dua 🤲"
        if let urlStr = dua.audioURL, isReliableURL(urlStr), let url = URL(string: urlStr) {
            stopQueue()
            audioService.play(url: url, title: title)
            return
        }

        guard let fileName = dua.audioFileName, !fileName.isEmpty else {
            showServiceError()
            return
        }

        play(idType: parseAudioID(fileName), title: title)
    }

    /// Play by resolved IDType — handles single ayah, surah sequence, direct URL.
    public func play(idType: AudioIDType, title: String? = nil) {
        let displayTitle = title ?? "Kur'an-ı Kerim 📖"
        switch idType {
        case .ayahID(let surah, let ayah):
            guard let url = URL(string: AudioAPI.getAyahAudioURL(surah: surah, ayah: ayah)) else {
                showServiceError(); return
            }
            stopQueue()
            let t = title ?? "Sure \(surah), Ayet \(ayah)"
            currentPlayingID = "ayah_\(surah)_\(ayah)"
            audioService.play(url: url, title: t)

        case .surahID(let surah):
            let ayahCount = AudioAPI.surahAyahCounts[surah] ?? 1
            let urls = AudioAPI.getAyahURLs(surah: surah, from: 1, to: ayahCount)
            let t = title ?? "Sure \(surah)"
            startQueue(urls, title: t)

        case .directURL(let url):
            stopQueue()
            audioService.play(url: url, title: displayTitle)

        case .localFile(let name):
            let normalizedName = name.decomposedStringWithCanonicalMapping
            
            // 1. Try root bundle
            var url = Bundle.main.url(forResource: normalizedName, withExtension: "mp3")
            
            // 2. Try 'prayers' subdirectory
            if url == nil {
                url = Bundle.main.url(forResource: normalizedName, withExtension: "mp3", subdirectory: "prayers")
            }
            
            // 3. Try 'Zikir' subdirectory
            if url == nil {
                url = Bundle.main.url(forResource: normalizedName, withExtension: "mp3", subdirectory: "Zikir")
            }
            
            guard let finalUrl = url else {
                print("AudioManager: Local file not found: \(normalizedName)")
                showServiceError(); return
            }
            
            stopQueue()
            audioService.play(url: finalUrl, title: displayTitle)
        }
    }

    /// Play a specific surah+ayah range sequentially.
    /// Example: playAyahRange(surah: 2, from: 255, to: 255)  → Ayetel Kürsi
    /// Example: playAyahRange(surah: 112, from: 1, to: 4)    → Tam İhlâs Suresi
    public func playAyahRange(surah: Int, from startAyah: Int, to endAyah: Int) {
        let urls = AudioAPI.getAyahURLs(surah: surah, from: startAyah, to: endAyah)
        if urls.isEmpty { showServiceError(); return }
        startQueue(urls)
    }

    public func stop() {
        stopQueue()
        audioService.stop()
        currentPlayingID = nil
    }

    // MARK: - Sequential Queue
    private var currentQueueTitle: String? = nil

    private func startQueue(_ urls: [URL], title: String? = nil) {
        guard !urls.isEmpty else { showServiceError(); return }
        ayahQueue = urls
        currentQueueIndex = 0
        currentQueueTitle = title
        isSequentialMode = true
        isPlaying = true
        let t = title ?? "Kur'an-ı Kerim 📖"
        audioService.play(url: urls[0], title: t)
    }

    private func playNextInQueue() {
        currentQueueIndex += 1
        if currentQueueIndex < ayahQueue.count {
            let t = currentQueueTitle ?? "Kur'an-ı Kerim 📖"
            audioService.play(url: ayahQueue[currentQueueIndex], title: "\(t) (\(currentQueueIndex + 1)/\(ayahQueue.count))")
        } else {
            isSequentialMode = false
            isPlaying = false
            ayahQueue = []
            currentQueueTitle = nil
        }
    }

    private func stopQueue() {
        isSequentialMode = false
        ayahQueue = []
        currentQueueIndex = 0
    }

    // MARK: - ID Parsing

    /// "002255" → .ayahID(2, 255) | "112" → .surahID(112) | "https://..." → .directURL
    public func parseAudioID(_ raw: String) -> AudioIDType {
        if raw.lowercased().hasPrefix("http"), let url = URL(string: raw) {
            return .directURL(url)
        }

        let digits = raw.trimmingCharacters(in: .whitespaces)
        guard digits.allSatisfy({ $0.isNumber }), !digits.isEmpty else {
            return .localFile(digits)
        }

        switch digits.count {
        case 1, 2, 3:
            let surahNum = Int(digits) ?? 0
            guard surahNum >= 1, surahNum <= 114 else { return .localFile(raw) }
            return .surahID(surah: surahNum)

        case 4, 5, 6:
            let padded = String(repeating: "0", count: max(0, 6 - digits.count)) + digits
            let surahNum = Int(padded.prefix(3)) ?? 0
            let ayahNum  = Int(padded.suffix(3)) ?? 0
            guard surahNum >= 1, surahNum <= 114, ayahNum >= 1 else {
                return .localFile(raw)
            }
            return .ayahID(surah: surahNum, ayah: ayahNum)

        default:
            return .localFile(raw)
        }
    }

    // MARK: - Legacy Support (DuaItem)

    public func playDua(item: DuaItem) {
        if let surah = item.surahNumber {
            if let ayah = item.ayahNumber {
                play(idType: .ayahID(surah: surah, ayah: ayah))
            } else {
                play(idType: .surahID(surah: surah))
            }
        } else if let manualURLStr = item.audioArabicURL, let url = URL(string: manualURLStr) {
            play(idType: .directURL(url))
        } else if let id = item.audioFileName {
            play(idType: parseAudioID(id))
        } else {
            showServiceError()
        }
    }

    // MARK: - Helpers

    /// Only trust everyayah.com URLs. namazzamani.net and similar are unreliable.
    private func isReliableURL(_ urlStr: String) -> Bool {
        urlStr.hasPrefix("https://everyayah.com") ||
        urlStr.hasPrefix("https://cdn.islamic.network")
    }

    private func showServiceError() {
        currentPlayingID = nil
        let lang = LocalizationManager.shared.currentLanguage
        let message: String
        let buttonText: String
        switch lang {
        case .tr:
            message = "Hizmetimiz şu an çalışmıyor"
            buttonText = "Tamam"
        case .en:
            message = "Service is currently unavailable"
            buttonText = "OK"
        case .ar:
            message = "الخدمة غير متوفرة حالياً"
            buttonText = "حسناً"
        case .de:
            message = "Der Dienst ist derzeit nicht verfügbar"
            buttonText = "OK"
        case .pt:
            message = "Serviço indisponível no momento"
            buttonText = "OK"
        }
        let popup = ServerErrorPopup(message: message, buttonText: buttonText)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(popup, animated: true)
        }
    }
}
