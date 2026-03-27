import SwiftUI

// Minimal version of MushafPageCard for UI usage if needed
// Uses the new MushafPageModel
struct MushafPageCard: View {
    let page: MushafPageModel
    let fontSize: CGFloat
    @State private var cardHeight: CGFloat = 300
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            SurahHeaderView(
                surahId: page.surahNumber,
                surahName: page.surahName,
                ayahCount: page.ayahs.count,
                isMakki: page.isMakki
            )
            
            // Text
            AyahTextView(
                text: page.ayahs.map { $0.arabicText }.joined(separator: " "),
                tajweedRanges: [], // Simplified for basic card
                fontSize: fontSize,
                dynamicHeight: $cardHeight
            )
            .frame(height: cardHeight)
            .padding()
        }
        .background(Color.mushafBackground)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}
