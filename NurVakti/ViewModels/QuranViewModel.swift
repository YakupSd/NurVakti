import Foundation
import Combine

@MainActor
final class QuranViewModel: ObservableObject {
    @Published var surahs: [SurahInfo] = []
    @Published var filteredSurahs: [SurahInfo] = []
    @Published var selectedSurah: SurahInfo?
    @Published var ayahs: [AyahItem] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoadingAyahs: Bool = false
    @Published var loadError: NurError? = nil
    @Published var ayahLoadError: NurError? = nil
    @Published var bookmarks: [QuranBookmark] = []
    @Published var readingProgress: ReadingProgress?
    @Published var hatimProgress: HatimProgress?
    @Published var readingMode: QuranReadingMode = .withTranslation
    @Published var arabicFontSize: CGFloat = 26
    @Published var viewStyle: QuranViewStyle = .mushaf // Varsayılan geleneksel olsun
    
    private let persistence = PersistenceService.shared
    private let baseURL = "https://api.alquran.cloud/v1"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.bookmarks = QuranBookmark.loadAll()
        let progress = ReadingProgress.load()
        self.readingProgress = progress
        self.readingMode = progress.readingMode
        self.hatimProgress = HatimProgress.load()
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.search(text)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - API Calls
    
    func loadSurahList() async {
        // Önce cache kontrol
        if let cachedData = UserDefaults.standard.data(forKey: "cached_surah_list"),
           let cachedList = try? JSONDecoder().decode([SurahInfo].self, from: cachedData) {
            self.surahs = cachedList
            self.filteredSurahs = cachedList
            // cache olsa bile arka planda güncelleme yapılabilir (isteğe bağlı)
            if !cachedList.isEmpty { return }
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let url = URL(string: "\(baseURL)/surah") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(SurahListResponse.self, from: data)
            
            let mappedSurahs = response.data.map { dto in
                SurahInfo(id: dto.number,
                          nameArabic: dto.name,
                          nameLocalized: [.tr: dto.englishName], // Örnek, gerçekte çeviri gerekebilir
                          englishName: dto.englishName,
                          ayahCount: dto.numberOfAyahs,
                          revelationType: RevelationType(rawValue: dto.revelationType) ?? .makkah)
            }
            
            self.surahs = mappedSurahs
            self.filteredSurahs = mappedSurahs
            
            // Cache'le
            if let encoded = try? JSONEncoder().encode(mappedSurahs) {
                UserDefaults.standard.set(encoded, forKey: "cached_surah_list")
            }
        } catch {
            self.loadError = .quranLoadFailed
            print("Surah list error: \(error)")
        }
    }
    
    func loadAyahs(surah: SurahInfo, language: LanguageCode) async {
        isLoadingAyahs = true
        defer { isLoadingAyahs = false }
        
        let edition = getEdition(for: language)
        let arabicURL = "\(baseURL)/surah/\(surah.id)/quran-uthmani"
        let translationURL = "\(baseURL)/surah/\(surah.id)/\(edition)"
        
        do {
            async let (arabicData, _) = URLSession.shared.data(from: URL(string: arabicURL)!)
            async let (translationData, _) = URLSession.shared.data(from: URL(string: translationURL)!)
            
            let arabicRes = try await JSONDecoder().decode(SurahDetailResponse.self, from: arabicData)
            let translationRes = try await JSONDecoder().decode(SurahDetailResponse.self, from: translationData)
            
            var items: [AyahItem] = []
            for i in 0..<arabicRes.data.ayahs.count {
                let arabic = arabicRes.data.ayahs[i]
                let translation = translationRes.data.ayahs[i]
                items.append(AyahItem(id: arabic.numberInSurah,
                                     arabicText: arabic.text,
                                     translation: translation.text,
                                     surahNumber: surah.id))
            }
            self.ayahs = items
        } catch {
            self.ayahLoadError = .quranLoadFailed
        }
    }
    
    func loadHatimPage(page: Int, language: LanguageCode) async {
        isLoadingAyahs = true
        defer { isLoadingAyahs = false }
        
        let edition = getEdition(for: language)
        let arabicURL = "\(baseURL)/page/\(page)/quran-uthmani"
        let translationURL = "\(baseURL)/page/\(page)/\(edition)"
        
        do {
            async let (arabicData, _) = URLSession.shared.data(from: URL(string: arabicURL)!)
            async let (translationData, _) = URLSession.shared.data(from: URL(string: translationURL)!)
            
            let arabicRes = try await JSONDecoder().decode(SurahDetailResponse.self, from: arabicData)
            let translationRes = try await JSONDecoder().decode(SurahDetailResponse.self, from: translationData)
            
            var items: [AyahItem] = []
            for i in 0..<arabicRes.data.ayahs.count {
                let arabic = arabicRes.data.ayahs[i]
                let translation = translationRes.data.ayahs[i]
                items.append(AyahItem(id: arabic.numberInSurah,
                                     arabicText: arabic.text,
                                     translation: translation.text,
                                     surahNumber: arabic.surah?.number ?? 0))
            }
            self.ayahs = items
            saveHatimProgress(page: page)
        } catch {
            self.ayahLoadError = .quranLoadFailed
        }
    }
    
    // MARK: - Logic
    
    func search(_ text: String) {
        if text.isEmpty {
            filteredSurahs = surahs
        } else {
            filteredSurahs = surahs.filter { 
                $0.englishName.localizedCaseInsensitiveContains(text) ||
                String($0.id).contains(text)
            }
        }
    }
    
    func addBookmark(surah: SurahInfo, ayah: AyahItem) {
        let bookmark = QuranBookmark(id: UUID(),
                                     surahNumber: surah.id,
                                     ayahNumber: ayah.id,
                                     surahNameArabic: surah.nameArabic,
                                     surahNameLocalized: surah.nameLocalized,
                                     createdAt: Date(),
                                     note: nil)
        bookmark.save()
        self.bookmarks = QuranBookmark.loadAll()
    }
    
    func removeBookmark(id: UUID) {
        PersistenceService.shared.removeBookmark(id: id)
        self.bookmarks = QuranBookmark.loadAll()
    }
    
    func isBookmarked(surah: Int, ayah: Int) -> Bool {
        bookmarks.contains { $0.surahNumber == surah && $0.ayahNumber == ayah }
    }
    
    func saveProgress(surah: Int, ayah: Int) {
        let progress = ReadingProgress(lastSurah: surah, lastAyah: ayah, lastReadDate: Date(), totalAyahsRead: 0, readingMode: self.readingMode)
        progress.save()
        self.readingProgress = progress
    }
    
    func saveHatimProgress(page: Int) {
        let newProgress = HatimProgress(currentPage: page, completedCount: hatimProgress?.completedCount ?? 0, lastUpdated: Date())
        newProgress.save()
        self.hatimProgress = newProgress
    }
    
    func toggleReadingMode() {
        readingMode = (readingMode == .arabicOnly) ? .withTranslation : .arabicOnly
        if var progress = readingProgress {
            progress.readingMode = readingMode
            progress.save()
            self.readingProgress = progress
        }
    }
    
    func toggleViewStyle() {
        viewStyle = (viewStyle == .list) ? .mushaf : .list
        // Gelişmiş: Modu kaydet
    }
    
    func languageDidChange(_ code: LanguageCode) {
        if let surah = selectedSurah {
            Task { await loadAyahs(surah: surah, language: code) }
        }
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
