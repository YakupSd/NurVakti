import SwiftUI

struct MushafPageContent: View {
    let ayahs: [AyahItem]
    let arabicFontSize: CGFloat
    let readingMode: QuranReadingMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Mushaf Alanı
                VStack(spacing: 0) {
                    // Sayfa içeriği - Akışkan Metin
                    Group {
                        if let firstAyah = ayahs.first {
                            let surahId = firstAyah.surahNumber
                            VStack(spacing: 16) {
                                // Surah Header (Opsiyonel: Eğer sayfa başıysa)
                                if firstAyah.id == 1 {
                                    Text("\(LocalizationManager.shared.localizedString("quran.surahLabel")) \(surahName(for: surahId))")
                                        .font(.custom("Traditional Arabic", size: 32))
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.nurGold.opacity(0.5), lineWidth: 1)
                                        )
                                    
                                    if surahId != 1 && surahId != 9 {
                                        Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                                            .font(.custom("Traditional Arabic", size: 28))
                                            .padding(.vertical, 8)
                                    }
                                }
                                
                                if readingMode == .arabicOnly {
                                    arabicFlowView
                                } else {
                                    translationListView
                                }
                            }
                        }
                    }
                    .padding(24)
                }
                .background(Color(hex: "F4ECD8")) // Kağıt rengi
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.nurGold.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.1), radius: 10)
            }
            .padding()
        }
    }
    
    // Geleneksel Akışkan Metin
    private var arabicFlowView: some View {
        var combinedText = Text("")
        
        for ayah in ayahs {
            let ayahText = Text(ayah.arabicText + " ")
                .font(.custom("Traditional Arabic", size: arabicFontSize))
            
            let marker = Text(" ﴿\(ayah.id)﴾ ")
                .font(.system(size: arabicFontSize * 0.6))
                .foregroundColor(.nurGold)
            
            combinedText = combinedText + ayahText + marker
        }
        
        return combinedText
            .multilineTextAlignment(.trailing)
            .lineSpacing(12)
            .foregroundColor(.black)
    }
    
    private var translationListView: some View {
        VStack(spacing: 24) {
            ForEach(ayahs) { ayah in
                VStack(alignment: .trailing, spacing: 8) {
                    Text(ayah.arabicText)
                        .font(.custom("Traditional Arabic", size: arabicFontSize))
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.black)
                    
                    Text(ayah.translation)
                        .nurFont(14)
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.trailing)
                        .italic()
                }
                .padding(.bottom, 8)
                Divider()
                    .background(Color.black.opacity(0.1))
            }
        }
    }
    
    private func surahName(for id: Int) -> String {
        // Bu normalde bir data'dan gelmeli ama basitçe mocklayalım veya ID döndürelim
        // Uygulamanın kalanında SurahInfo kullanılıyor.
        return "\(id)" 
    }
}

#Preview {
    MushafPageContent(ayahs: [
        AyahItem(id: 1, arabicText: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", translation: "Rahman ve Rahim olan Allah'ın adıyla", surahNumber: 1),
        AyahItem(id: 2, arabicText: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ", translation: "Hamd alemlerin rabbi olan Allah'adır", surahNumber: 1)
    ], arabicFontSize: 28, readingMode: .arabicOnly)
}
