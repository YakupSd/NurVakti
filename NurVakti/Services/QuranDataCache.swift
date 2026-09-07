import Foundation
import Combine

// MARK: - Ultra-Fast 2-Tier Quran Cache (Memory + Disk)
@MainActor
final class QuranDataCache {
    static let shared = QuranDataCache()
    
    // Level 1: In-Memory Cache (0ms Instant Lookup)
    private let memoryAyahCache = NSCache<NSString, NSArray>()
    private let memoryPageCache = NSCache<NSNumber, NSData>()
    
    // Level 2: Persistent Disk Cache Directory
    private let diskCacheURL: URL
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.nurvakti.qurandatacache", qos: .userInitiated)
    
    private init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let baseDir = paths.first ?? fileManager.temporaryDirectory
        diskCacheURL = baseDir.appendingPathComponent("QuranCache", isDirectory: true)
        
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        memoryAyahCache.countLimit = 60 // Cache up to 60 surahs in active memory
    }
    
    // MARK: - Surah Ayahs Cache API
    
    func getAyahs(surahNumber: Int, language: LanguageCode) -> [AyahItem]? {
        let key = cacheKey(surahNumber: surahNumber, language: language)
        
        // 1. Check Level 1: In-Memory
        if let cached = memoryAyahCache.object(forKey: key as NSString) as? [AyahItem], !cached.isEmpty {
            return cached
        }
        
        // 2. Check Level 2: Disk Cache
        let fileURL = diskCacheURL.appendingPathComponent("surah_\(surahNumber)_\(language.rawValue).json")
        if fileManager.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([AyahItem].self, from: data),
           !decoded.isEmpty {
            // Re-populate memory cache
            memoryAyahCache.setObject(decoded as NSArray, forKey: key as NSString)
            return decoded
        }
        
        return nil
    }
    
    func saveAyahs(surahNumber: Int, language: LanguageCode, ayahs: [AyahItem]) {
        guard !ayahs.isEmpty else { return }
        let key = cacheKey(surahNumber: surahNumber, language: language)
        
        // Save to Level 1
        memoryAyahCache.setObject(ayahs as NSArray, forKey: key as NSString)
        
        // Save to Level 2 (Disk async on background queue)
        let fileURL = diskCacheURL.appendingPathComponent("surah_\(surahNumber)_\(language.rawValue).json")
        queue.async {
            if let encoded = try? JSONEncoder().encode(ayahs) {
                try? encoded.write(to: fileURL, options: .atomic)
            }
        }
    }
    
    // MARK: - Mushaf Pages Cache API
    
    func getMushafPage(pageNumber: Int) -> MushafPageModel? {
        let key = NSNumber(value: pageNumber)
        if let data = memoryPageCache.object(forKey: key),
           let decoded = try? JSONDecoder().decode(MushafPageModel.self, from: data as Data) {
            return decoded
        }
        
        let fileURL = diskCacheURL.appendingPathComponent("mushaf_page_\(pageNumber).json")
        if fileManager.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(MushafPageModel.self, from: data) {
            memoryPageCache.setObject(data as NSData, forKey: key)
            return decoded
        }
        
        return nil
    }
    
    func saveMushafPage(pageNumber: Int, page: MushafPageModel) {
        let key = NSNumber(value: pageNumber)
        guard let data = try? JSONEncoder().encode(page) else { return }
        
        memoryPageCache.setObject(data as NSData, forKey: key)
        
        let fileURL = diskCacheURL.appendingPathComponent("mushaf_page_\(pageNumber).json")
        queue.async {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
    
    // MARK: - Background Pre-fetching Engine
    
    func prefetchAdjacentSurahs(currentSurah: Int, language: LanguageCode, quranManager: QuranManager) {
        let adjacentSurahs = [currentSurah + 1, currentSurah - 1].filter { $0 >= 1 && $0 <= 114 }
        
        for surahId in adjacentSurahs {
            if self.getAyahs(surahNumber: surahId, language: language) != nil {
                continue
            }
            
            Task {
                let edition = self.getEdition(for: language)
                do {
                    async let arabicRes = try await quranManager.getSurahDetailAsync(number: surahId, edition: "quran-uthmani")
                    async let transRes = try await quranManager.getSurahDetailAsync(number: surahId, edition: edition)
                    let (arabic, trans) = try await (arabicRes, transRes)
                    
                    var items: [AyahItem] = []
                    let count = min(arabic.data.ayahs.count, trans.data.ayahs.count)
                    for i in 0..<count {
                        items.append(AyahItem(
                            id: arabic.data.ayahs[i].numberInSurah,
                            arabicText: arabic.data.ayahs[i].text,
                            translation: trans.data.ayahs[i].text,
                            surahNumber: surahId
                        ))
                    }
                    self.saveAyahs(surahNumber: surahId, language: language, ayahs: items)
                } catch {
                    // Silently ignore background prefetch error
                }
            }
        }
    }
    
    func prefetchAdjacentPages(currentPage: Int, quranManager: QuranManager) {
        let adjacentPages = [currentPage + 1, currentPage - 1].filter { $0 >= 1 && $0 <= 604 }
        
        for page in adjacentPages {
            if self.getMushafPage(pageNumber: page) != nil {
                continue
            }
            
            Task {
                do {
                    let response = try await quranManager.getPageDetailAsync(page: page, edition: "quran-uthmani")
                    var ayahModels: [AyahModel] = []
                    for ayah in response.data.ayahs {
                        var text = ayah.text
                        let standardBesmele = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
                        let uthmaniBesmele = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"
                        text = text.replacingOccurrences(of: standardBesmele, with: "")
                            .replacingOccurrences(of: uthmaniBesmele, with: "")
                            .trimmingCharacters(in: .whitespaces)
                        
                        ayahModels.append(AyahModel(
                            id: ayah.number,
                            surahNumber: ayah.surah?.number ?? 1,
                            ayahNumber: ayah.numberInSurah,
                            arabicText: text,
                            tajweedRanges: []
                        ))
                    }
                    
                    let pageModel = MushafPageModel(
                        pageNumber: page,
                        surahNumber: ayahModels.first?.surahNumber ?? 1,
                        surahName: response.data.ayahs.first?.surah?.name ?? "Mushaf",
                        isMakki: false,
                        ayahs: ayahModels,
                        lineCount: 15
                    )
                    self.saveMushafPage(pageNumber: page, page: pageModel)
                } catch {
                    // Silently ignore background prefetch error
                }
            }
        }
    }
    
    private func cacheKey(surahNumber: Int, language: LanguageCode) -> String {
        "\(surahNumber)_\(language.rawValue)"
    }
    
    private func getEdition(for language: LanguageCode) -> String {
        switch language {
        case .tr: return "tr.diyanet"
        case .en: return "en.sahih"
        case .de: return "de.aburida"
        case .pt: return "pt.elhayek"
        case .ar: return "quran-uthmani"
        }
    }
}
