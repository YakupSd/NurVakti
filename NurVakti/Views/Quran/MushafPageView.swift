import SwiftUI

struct MushafPageView: View {
    let page: MushafPageModel
    @State private var fontSize: CGFloat = 28
    @State private var zoomScale: CGFloat = 1.0
    @State private var textHeight: CGFloat = 500 // Initial estimate
    
    var body: some View {
        ZStack {
            // Background Layer
            Color.mushafBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (If first page of Surah)
                if page.ayahs.first?.ayahNumber == 1 {
                    SurahHeaderView(
                        surahId: page.surahNumber,
                        surahName: page.surahName,
                        ayahCount: page.ayahs.count,
                        isMakki: page.isMakki
                    )
                    .padding(.top, 20)
                    
                    BesmeleView()
                }
                
                // Body (Text Content)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Concatenate all ayahs into one flow for Mushaf feel
                        let fullText = page.ayahs.map { $0.arabicText + " " + $0.displayId }.joined(separator: " ")
                        
                        AyahTextView(
                            text: fullText,
                            tajweedRanges: [],
                            fontSize: fontSize * zoomScale,
                            dynamicHeight: $textHeight
                        )
                        .padding(.horizontal, 28)
                        .padding(.vertical, 10)
                        .frame(minHeight: textHeight)
                        .frame(maxWidth: .infinity)
                    }
                }
                
                // Footer (Page Info)
                HStack {
                    Text("\(page.pageNumber). Sayfa")
                    Spacer()
                    Text(page.surahName)
                }
                .nurFont(14, weight: .bold)
                .foregroundColor(Color.nurGoldPremium)
                .padding(.horizontal, 30)
                .padding(.bottom, 25)
                .background(Color.mushafBackground)
            }
            .scaleEffect(zoomScale)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        zoomScale = value.magnitude
                    }
                    .onEnded { _ in
                        withAnimation { zoomScale = 1.0 }
                    }
            )
            
            // Decorative Double Border
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.nurGoldPremium.opacity(0.3), lineWidth: 1.5)
                .padding(8)
                .allowsHitTesting(false)
        }
        // Navigation bar visible via AppRouter settings
    }
    
    // Range calculation removed as tajweed is disabled
    private func calculateAdjustedRanges(_ ayahs: [AyahModel]) -> [MushafRange] {
        return []
    }
}

#Preview {
    MushafPageView(page: MushafPageModel.mock)
}
