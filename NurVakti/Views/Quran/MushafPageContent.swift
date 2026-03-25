import SwiftUI

struct MushafPageContent: View {
    let ayahs: [AyahItem]
    let arabicFontSize: CGFloat
    let readingMode: QuranReadingMode
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // MARK: - Mushaf Paper
                VStack(spacing: 0) {
                    if let firstAyah = ayahs.first {
                        let surahId = firstAyah.surahNumber
                        VStack(spacing: 16) {
                            
                            // Surah Header
                            if firstAyah.id == 1 {
                                surahHeader(id: surahId)
                            }
                            
                            if readingMode == .arabicOnly {
                                arabicFlowView
                            } else {
                                translationListView
                            }
                        }
                    }
                }
                .padding(32)
                .background(Color(hex: "FDFBF0")) // Daha sıcak Premium Mushaf Kağıdı
                .cornerRadius(4)
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.nurGold.opacity(0.2), lineWidth: 1)
                )
            }
            .padding()
        }
        .background(Color(hex: "1a1a1a")) // Arka planla kontrast
    }
    
    private func surahHeader(id: Int) -> some View {
        VStack(spacing: 12) {
            Text("\(id). \(LocalizationManager.shared.localizedString("quran.surahLabel"))")
                .nurFont(14, weight: .bold)
                .foregroundColor(.nurGold)
            
            if id != 1 && id != 9 {
                Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                    .font(.custom("Traditional Arabic", size: 36))
                    .foregroundColor(.black)
                    .padding(.vertical, 8)
            }
            
            Divider()
                .background(Color.nurGold.opacity(0.3))
        }
        .padding(.bottom, 20)
    }

    // Geleneksel Akışkan Metin (Tajweed Destekli)
    private var arabicFlowView: some View {
        var combinedText = AttributedString("")
        
        for ayah in ayahs {
            let tajweed = TajweedFormatter.shared.format(ayah.tajweedText ?? ayah.arabicText, defaultColor: .black)
            combinedText.append(tajweed)
            
            var marker = AttributedString(" ﴿\(ayah.id)﴾ ")
            marker.foregroundColor = .nurGold
            marker.font = .system(size: arabicFontSize * 0.6)
            combinedText.append(marker)
        }
        
        return Text(combinedText)
            .font(.custom("Traditional Arabic", size: arabicFontSize))
            .multilineTextAlignment(.trailing)
            .lineSpacing(15)
    }
    
    private var translationListView: some View {
        VStack(spacing: 32) {
            ForEach(ayahs) { ayah in
                VStack(alignment: .trailing, spacing: 12) {
                    Text(TajweedFormatter.shared.format(ayah.tajweedText ?? ayah.arabicText, defaultColor: .black))
                        .font(.custom("Traditional Arabic", size: arabicFontSize))
                        .multilineTextAlignment(.trailing)
                        .lineSpacing(10)
                    
                    Text(ayah.translation)
                        .nurFont(16)
                        .foregroundColor(.black.opacity(0.6))
                        .multilineTextAlignment(.trailing)
                        .italic()
                        .padding(.trailing, 8)
                }
                .padding(.bottom, 8)
                Divider()
                    .background(Color.black.opacity(0.1))
            }
        }
    }
}

#Preview {
    MushafPageContent(ayahs: [
        AyahItem(id: 1, arabicText: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", translation: "Rahman ve Rahim olan Allah'ın adıyla", surahNumber: 1, tajweedText: "[h:2255[بِ][s:1044[سْمِ] اللَّهِ الرَّحْمَ[n:1033[نِ] الرَّحِي[n:1033[مِ]"),
        AyahItem(id: 2, arabicText: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ", translation: "Hamd alemlerin rabbi olan Allah'adır", surahNumber: 1, tajweedText: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِي[n:1033[نَ]")
    ], arabicFontSize: 28, readingMode: .arabicOnly)
}
