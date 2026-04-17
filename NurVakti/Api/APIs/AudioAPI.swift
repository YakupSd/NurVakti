import Foundation

open class AudioAPI {
    
    /// Reciter name — must match exactly what everyayah.com uses in their URL paths.
    /// Default: Alafasy_128kbps (Mishary Rashid Alafasy, 128kbps)
    public static var reciter = "Alafasy_128kbps"
    
    /// Base URL — always HTTPS to satisfy iOS App Transport Security (ATS).
    public static var basePath = "https://everyayah.com/data"

    // MARK: - URL Resolution

    static func url(for idType: AudioIDType) -> URL? {
        switch idType {
        case .ayahID(let surah, let ayah):
            return URL(string: getAyahAudioURL(surah: surah, ayah: ayah))

        case .surahID(let surah):
            // Play from the first ayah — sequential playing handled by AudioManager
            return URL(string: getAyahAudioURL(surah: surah, ayah: 1))

        case .directURL(let url):
            return url

        case .localFile(let name):
            return Bundle.main.url(forResource: name, withExtension: "mp3")
        }
    }

    // MARK: - URL Builders

    /// Builds a single-ayah URL.
    /// Format: https://everyayah.com/data/{reciter}/{surah:003d}{ayah:003d}.mp3
    /// Example: https://everyayah.com/data/Alafasy_128kbps/002255.mp3  (Ayetel Kürsi)
    open class func getAyahAudioURL(surah: Int, ayah: Int) -> String {
        let surahStr = String(format: "%03d", surah)
        let ayahStr  = String(format: "%03d", ayah)
        return "\(basePath)/\(reciter)/\(surahStr)\(ayahStr).mp3"
    }

    /// Returns all ayah URLs for a surah range (used for sequential playback).
    /// Example: getAyahURLs(surah: 112, from: 1, to: 4) → 4 URLs for Surah İhlâs
    open class func getAyahURLs(surah: Int, from startAyah: Int, to endAyah: Int) -> [URL] {
        return (startAyah...endAyah).compactMap { ayah in
            URL(string: getAyahAudioURL(surah: surah, ayah: ayah))
        }
    }

    // MARK: - Known Surah Ayah Counts (for sequential playback)

    /// Maps surah number → total ayah count for surahs used in this app.
    static let surahAyahCounts: [Int: Int] = [
        1:   7,   // Fatiha
        2:   286, // Bakara (Ayetel Kürsi = 2:255)
        36:  83,  // Yasin
        67:  30,  // Mülk
        112: 4,   // İhlâs
        113: 5,   // Felak
        114: 6,   // Nas
    ]
}
