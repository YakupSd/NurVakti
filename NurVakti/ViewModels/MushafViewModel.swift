import SwiftUI
import Combine

@MainActor
class MushafViewModel: ObservableObject {
    @Published var pages: [MushafPageModel] = []
    @Published var currentPageIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var pageNumber: Int?
    
    let surah: SurahInfo?
    private let quranManager = QuranManager()
    
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
        quranManager.getPageDetail(page: page, edition: "quran-uthmani") { response in
            DispatchQueue.main.async {
                self.processAyahs(response.data.ayahs, asSinglePage: true, forcedPageNumber: page)
                self.isLoading = false
            }
        } onFailure: { _ in
            DispatchQueue.main.async {
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
            self.pages = [MushafPageModel(
                pageNumber: forcedPageNumber ?? (pageNumber ?? 1),
                surahNumber: ayahModels.first?.surahNumber ?? 0,
                surahName: ayahs.first?.surah?.name ?? "Mushaf",
                isMakki: false,
                ayahs: ayahModels,
                lineCount: 15
            )]
            self.currentPageIndex = 0
            return
        }
        
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
            if let pn = pageNumber, pn < 604 {
                self.loadPageData(pn + 1)
                self.updatePageNumber(pn + 1)
            } else if let currentSurahId = surah?.id, currentSurahId < 114 {
                loadNextSurah(id: currentSurahId + 1)
            }
        }
    }
    
    func previousPage() {
        if currentPageIndex > 0 {
            currentPageIndex -= 1
            saveHatimProgressIfNeeded()
        } else {
            if let pn = pageNumber, pn > 1 {
                self.loadPageData(pn - 1)
                self.updatePageNumber(pn - 1)
            } else if let currentSurahId = surah?.id, currentSurahId > 1 {
                loadPreviousSurah(id: currentSurahId - 1)
            }
        }
    }
    
    private func updatePageNumber(_ newPage: Int) {
        self.pageNumber = newPage
        let progress = HatimProgress(currentPage: newPage, completedCount: 0, lastUpdated: Date())
        progress.save()
    }
    
    private func saveHatimProgressIfNeeded() {
        if let pn = pageNumber {
            let progress = HatimProgress(currentPage: pn, completedCount: 0, lastUpdated: Date())
            progress.save()
        }
    }
    
    private func loadNextSurah(id: Int) {
        isLoading = true
        quranManager.getSurahDetail(number: id, edition: "quran-uthmani") { response in
            DispatchQueue.main.async {
                self.processAyahs(response.data.ayahs)
                self.currentPageIndex = 0
                self.isLoading = false
            }
        } onFailure: { _ in
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func loadPreviousSurah(id: Int) {
        isLoading = true
        quranManager.getSurahDetail(number: id, edition: "quran-uthmani") { response in
            DispatchQueue.main.async {
                self.processAyahs(response.data.ayahs)
                self.currentPageIndex = self.pages.count - 1
                self.isLoading = false
            }
        } onFailure: { _ in
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func loadSurahData() {
        guard let surah = surah else { return }
        isLoading = true
        quranManager.getSurahDetail(number: surah.id, edition: "quran-uthmani") { response in
            DispatchQueue.main.async {
                self.processAyahs(response.data.ayahs)
                self.isLoading = false
            }
        } onFailure: { _ in
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func parseTajweedBrackets(_ raw: String) -> (cleanText: String, ranges: [MushafRange]) {
        return (raw, [])
    }
}

