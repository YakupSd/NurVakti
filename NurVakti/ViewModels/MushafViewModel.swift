import SwiftUI
import Combine

@MainActor
class MushafViewModel: ObservableObject {
    @Published var pages: [MushafPageModel] = []
    @Published var currentPageIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var pageNumber: Int?
    
    let surah: SurahInfo?
    private let baseURL = "https://api.alquran.cloud/v1"
    
    init(surah: SurahInfo) {
        self.surah = surah
        self.pageNumber = nil
        loadSurahData()
    }
    
    init(page: Int) {
        self.surah = nil
        self.pageNumber = page
        loadPageData(page)
    }
    
    func loadPageData(_ page: Int) {
        isLoading = true
        Task {
            do {
                let url = URL(string: "\(baseURL)/page/\(page)/quran-uthmani")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(SurahDetailResponse.self, from: data)
                
                // Process as a SINGLE page if loading by page number
                self.processAyahs(response.data.ayahs, asSinglePage: true, forcedPageNumber: page)
                self.isLoading = false
            } catch {
                print("Mushaf page load error: \(error)")
                self.isLoading = false
            }
        }
    }
    
    private func processAyahs(_ ayahs: [AyahDTO], asSinglePage: Bool = false, forcedPageNumber: Int? = nil) {
        var ayahModels: [AyahModel] = []
        for ayah in ayahs {
            var text = ayah.text
            let standardBesmele = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
            if text.contains(standardBesmele) {
                text = text.replacingOccurrences(of: standardBesmele, with: "").trimmingCharacters(in: .whitespaces)
            }
            let uthmaniBesmele = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"
            if text.contains(uthmaniBesmele) {
                text = text.replacingOccurrences(of: uthmaniBesmele, with: "").trimmingCharacters(in: .whitespaces)
            }
            
            ayahModels.append(AyahModel(
                id: ayah.number,
                surahNumber: ayah.surah?.number ?? (surah?.id ?? 0),
                ayahNumber: ayah.numberInSurah,
                arabicText: text,
                tajweedRanges: []
            ))
        }
        
        if asSinglePage {
            // If we're loading a specific Mushaf page, treat it as one PageModel
            self.pages = [MushafPageModel(
                pageNumber: forcedPageNumber ?? (pageNumber ?? 1),
                surahNumber: ayahModels.first?.surahNumber ?? 0,
                surahName: ayahs.first?.surah?.name ?? "Mushaf",
                isMakki: false, // Could be determined from surah info if needed
                ayahs: ayahModels,
                lineCount: 15
            )]
            self.currentPageIndex = 0
            return
        }
        
        // Paging Logic: Split surah ayahs into pages
        let ayahsPerPage = 10
        var newPages: [MushafPageModel] = []
        let totalPagesCount = (ayahModels.count + ayahsPerPage - 1) / ayahsPerPage
        
        for i in 0..<totalPagesCount {
            let start = i * ayahsPerPage
            let end = min(start + ayahsPerPage, ayahModels.count)
            let pageAyahs = Array(ayahModels[start..<end])
            
            newPages.append(MushafPageModel(
                pageNumber: i + 1,
                surahNumber: pageAyahs.first?.surahNumber ?? 0,
                surahName: surah?.nameArabic ?? "Mushaf",
                isMakki: surah?.revelationType == .makkah,
                ayahs: pageAyahs,
                lineCount: 15
            ))
        }
        
        self.pages = newPages
    }
    
    func nextPage() {
        if currentPageIndex < pages.count - 1 {
            currentPageIndex += 1
            saveHatimProgressIfNeeded()
        } else {
            // End of current data set
            if let pn = pageNumber, pn < 604 {
                // Page mode: Load next Mushaf page
                self.loadPageData(pn + 1)
                self.updatePageNumber(pn + 1)
            } else if let currentSurahId = surah?.id, currentSurahId < 114 {
                // Surah mode: Load next Surah
                loadNextSurah(id: currentSurahId + 1)
            }
        }
    }
    
    func previousPage() {
        if currentPageIndex > 0 {
            currentPageIndex -= 1
            saveHatimProgressIfNeeded()
        } else {
            // Beginning of current data set
            if let pn = pageNumber, pn > 1 {
                // Page mode: Load previous Mushaf page
                self.loadPageData(pn - 1)
                self.updatePageNumber(pn - 1)
            } else if let currentSurahId = surah?.id, currentSurahId > 1 {
                // Surah mode: Load previous Surah
                loadPreviousSurah(id: currentSurahId - 1)
            }
        }
    }
    
    private func updatePageNumber(_ newPage: Int) {
        self.pageNumber = newPage
        // Persistence:
        let progress = HatimProgress(currentPage: newPage, completedCount: 0, lastUpdated: Date())
        progress.save()
    }
    
    private func saveHatimProgressIfNeeded() {
        if let pn = pageNumber {
            let progress = HatimProgress(currentPage: pn, completedCount: 0, lastUpdated: Date())
            progress.save()
        } else if !pages.isEmpty {
            // If in surah mode, we don't necessarily update "Hatim" unless desired.
            // But if we want Hatim to track ANY reading:
            // let currentPage = pages[currentPageIndex].pageNumber (Real page number needed here)
        }
    }
    
    private func loadNextSurah(id: Int) {
        isLoading = true
        Task {
            do {
                let url = URL(string: "\(baseURL)/surah/\(id)/quran-uthmani")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(SurahDetailResponse.self, from: data)
                
                processAyahs(response.data.ayahs)
                self.currentPageIndex = 0
                self.isLoading = false
            } catch {
                self.isLoading = false
            }
        }
    }
    
    private func loadPreviousSurah(id: Int) {
        isLoading = true
        Task {
            do {
                let url = URL(string: "\(baseURL)/surah/\(id)/quran-uthmani")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(SurahDetailResponse.self, from: data)
                processAyahs(response.data.ayahs)
                self.currentPageIndex = pages.count - 1
                self.isLoading = false
            } catch {
                self.isLoading = false
            }
        }
    }
    
    func loadSurahData() {
        guard let surah = surah else { return }
        isLoading = true
        Task {
            do {
                let url = URL(string: "\(baseURL)/surah/\(surah.id)/quran-uthmani")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(SurahDetailResponse.self, from: data)
                processAyahs(response.data.ayahs)
                self.isLoading = false
            } catch {
                print("Mushaf load error: \(error)")
                self.isLoading = false
            }
        }
    }
    
    private func parseTajweedBrackets(_ raw: String) -> (cleanText: String, ranges: [MushafRange]) {
        return (raw, [])
    }
}
