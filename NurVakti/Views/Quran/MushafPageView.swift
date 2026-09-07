import SwiftUI

// MARK: - Pixel-Perfect Mushaf Page View (No Jitter, Pure SwiftUI)
struct MushafPageView: View {
    let pageNumber: Int
    @State private var pageModel: MushafPageModel?
    @State private var isLoading: Bool = true
    @State private var loadFailed: Bool = false
    
    private let quranManager = QuranManager()
    
    init(pageNumber: Int) {
        self.pageNumber = max(1, min(604, pageNumber))
    }
    
    var body: some View {
        ZStack {
            // Background Ivory / Parchment
            Color.mushafBackground.ignoresSafeArea()
            
            if let page = pageModel {
                VStack(spacing: 0) {
                    // Top Header Frame (If Surah starts on this page)
                    if page.ayahs.first?.ayahNumber == 1 {
                        SurahHeaderView(
                            surahId: page.surahNumber,
                            surahName: page.surahName,
                            ayahCount: 0,
                            isMakki: page.isMakki
                        )
                        .padding(.top, 8)
                        
                        if page.surahNumber != 9 {
                            BesmeleView()
                                .padding(.vertical, 4)
                        }
                    }
                    
                    Spacer(minLength: 4)
                    
                    // Main Quran Text Block (Formatted Uthmani Script with Gold Ayah Badges)
                    quranTextFlow(ayahs: page.ayahs)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    
                    Spacer(minLength: 4)
                    
                    // Bottom Page Footer Bar
                    pageFooter(page: page)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            } else if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(Color.nurGoldPremium)
                    Text("Sayfa \(pageNumber) yükleniyor...")
                        .nurFont(12)
                        .foregroundColor(Color.nurGoldPremium.opacity(0.8))
                }
            } else if loadFailed {
                VStack(spacing: 10) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 28))
                        .foregroundColor(.nurGoldPremium)
                    Text("Sayfa yüklenemedi")
                        .nurFont(13, weight: .bold)
                    Button("Tekrar Dene") {
                        loadPage()
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
            
            // Traditional Mushaf Double Golden Border
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.nurGoldPremium.opacity(0.35), lineWidth: 1.5)
                .padding(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.nurGoldPremium.opacity(0.15), lineWidth: 0.8)
                        .padding(9)
                )
                .allowsHitTesting(false)
        }
        .onAppear {
            loadPage()
        }
    }
    
    // MARK: - Quran Text Flow (Pure SwiftUI Layout — 100% Stability)
    private func quranTextFlow(ayahs: [AyahModel]) -> some View {
        let fullText = buildCombinedText(ayahs: ayahs)
        
        return Text(fullText)
            .font(.custom("ScheherazadeNew-Bold", size: dynamicFontSize(for: ayahs.count)))
            .lineSpacing(12)
            .multilineTextAlignment(.center)
            .foregroundColor(Color(hex: "#2C1E11")) // Classic Mushaf ink color
            .environment(\.layoutDirection, .rightToLeft)
            .frame(maxWidth: .infinity)
    }
    
    private func buildCombinedText(ayahs: [AyahModel]) -> AttributedString {
        var combined = AttributedString("")
        
        for ayah in ayahs {
            var ayahText = AttributedString(ayah.arabicText + " ")
            ayahText.foregroundColor = Color(hex: "#2C1E11")
            
            // Ayah End Badge Ornament (e.g. ﴿١﴾)
            var ornament = AttributedString(" ﴿\(ayah.ayahNumber.toArabicNumerals())﴾ ")
            ornament.foregroundColor = Color.nurGoldPremium
            ornament.font = .custom("ScheherazadeNew-Bold", size: dynamicFontSize(for: ayahs.count) - 2)
            
            combined.append(ayahText)
            combined.append(ornament)
        }
        
        return combined
    }
    
    // Auto-scale font slightly for dense vs short pages (keeps page on single screen)
    private func dynamicFontSize(for ayahCount: Int) -> CGFloat {
        if ayahCount > 15 {
            return 21
        } else if ayahCount > 8 {
            return 23
        } else {
            return 25
        }
    }
    
    // MARK: - Page Footer
    private func pageFooter(page: MushafPageModel) -> some View {
        let juzNumber = calculateJuz(for: page.pageNumber)
        
        return HStack {
            Text("\(juzNumber). Cüz")
                .nurFont(11, weight: .semibold)
                .foregroundColor(Color.nurGoldPremium.opacity(0.9))
            
            Spacer()
            
            Text("\(page.pageNumber)")
                .nurFont(13, weight: .bold, design: .rounded)
                .foregroundColor(Color.nurGoldPremium)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color.nurGoldPremium.opacity(0.12))
                .clipShape(Capsule())
            
            Spacer()
            
            Text(page.surahName)
                .nurFont(11, weight: .semibold)
                .foregroundColor(Color.nurGoldPremium.opacity(0.9))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .background(Color.mushafBackground)
    }
    
    private func calculateJuz(for page: Int) -> Int {
        if page <= 1 { return 1 }
        return min(30, max(1, ((page - 2) / 20) + 1))
    }
    
    // MARK: - Fast Loader
    private func loadPage() {
        // 1. Check Fast Cache (0ms)
        if let cached = QuranDataCache.shared.getMushafPage(pageNumber: pageNumber) {
            self.pageModel = cached
            self.isLoading = false
            self.loadFailed = false
            return
        }
        
        // 2. Fetch from API
        isLoading = true
        loadFailed = false
        
        Task {
            do {
                let response = try await quranManager.getPageDetailAsync(page: pageNumber, edition: "quran-uthmani")
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
                
                let model = MushafPageModel(
                    pageNumber: pageNumber,
                    surahNumber: ayahModels.first?.surahNumber ?? 1,
                    surahName: response.data.ayahs.first?.surah?.name ?? "Mushaf",
                    isMakki: false,
                    ayahs: ayahModels,
                    lineCount: 15
                )
                
                await MainActor.run {
                    self.pageModel = model
                    self.isLoading = false
                    self.loadFailed = false
                    QuranDataCache.shared.saveMushafPage(pageNumber: pageNumber, page: model)
                    QuranDataCache.shared.prefetchAdjacentPages(currentPage: pageNumber, quranManager: quranManager)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.loadFailed = true
                }
            }
        }
    }
}

extension Int {
    func toArabicNumerals() -> String {
        String(self).toArabicNumerals()
    }
}
