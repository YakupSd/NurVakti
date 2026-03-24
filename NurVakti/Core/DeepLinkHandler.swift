import Foundation
import Combine

// MARK: - Deep Link Routes
// Supported schemes:
//   nurvakti://prayer           → Ana sayfa (tab 0)
//   nurvakti://quran            → Kuran listesi (tab 1)
//   nurvakti://quran/18         → Kehf suresi (tab 1 + navigate)
//   nurvakti://dhikr            → Zikirmatik (tab 2)
//   nurvakti://alarms           → Alarmlar (tab 3)
//   nurvakti://settings         → Ayarlar (tab 4)

enum DeepLink {
    case prayer
    case quranList
    case quranSurah(Int)
    case dhikr
    case alarms
    case settings

    /// Tab index for ContentView
    var tabIndex: Int {
        switch self {
        case .prayer:              return 0
        case .quranList, .quranSurah: return 1
        case .dhikr:               return 2
        case .alarms:              return 3
        case .settings:            return 4
        }
    }

    /// Surah number if this is a quranSurah deep link
    var surahNumber: Int? {
        if case .quranSurah(let n) = self { return n }
        return nil
    }
}

// MARK: - DeepLinkHandler
final class DeepLinkHandler: ObservableObject {
    static let shared = DeepLinkHandler()
    private init() {}

    @Published var pendingDeepLink: DeepLink? = nil

    /// Called from AppDelegate or NurVaktiApp.onOpenURL
    func handle(url: URL) {
        guard url.scheme == "nurvakti" else { return }

        let host = url.host ?? ""
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        let link: DeepLink? = {
            switch host.lowercased() {
            case "prayer":   return .prayer
            case "dhikr":    return .dhikr
            case "alarms":   return .alarms
            case "settings": return .settings
            case "quran":
                if let first = pathComponents.first, let surah = Int(first) {
                    return .quranSurah(surah)
                }
                return .quranList
            default:         return nil
            }
        }()

        guard let link else { return }

        DispatchQueue.main.async {
            self.pendingDeepLink = link
            // Tab geçişi ContentView'da NotificationCenter ile trigger edilir
            NotificationCenter.default.post(
                name: .init("NavigateToTab"),
                object: link.tabIndex
            )
            // Surah açma gerekirse ayrı notification
            if let surahNumber = link.surahNumber {
                NotificationCenter.default.post(
                    name: .init("OpenSurah"),
                    object: surahNumber
                )
            }
        }
    }
}
