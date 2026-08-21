import SwiftUI

struct SurahHeaderView: View {
    let surahId: Int
    let surahName: String
    let ayahCount: Int
    let isMakki: Bool
    
    var body: some View {
        ZStack {
            // Background Banner (Luxury Gold Gradient)
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#D4AF37"), Color(hex: "#C9A84C"), Color(hex: "#B8860B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 84)
                .shadow(color: Color.nurGold.opacity(0.3), radius: 10, x: 0, y: 4)
            
            // Decorative Inner Border
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                .padding(5)
                .frame(height: 84)
            
            HStack(spacing: 16) {
                // Surah Number Left Badge
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 38, height: 38)
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        .frame(width: 38, height: 38)
                    Text("\(surahId)")
                        .nurFont(14, weight: .heavy, design: .rounded)
                        .foregroundColor(.white)
                }
                
                // Info Left
                VStack(alignment: .leading, spacing: 2) {
                    if ayahCount > 0 {
                        Text("\(ayahCount) \(LocalizationManager.shared.localizedString("quran.ayahs"))")
                    }
                    Text(isMakki ? LocalizationManager.shared.localizedString("quran.makki") : LocalizationManager.shared.localizedString("quran.madani"))
                }
                .nurFont(11, weight: .bold)
                .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                // Name Arabic
                Text("سُورَةُ \(surahName)")
                    .font(.custom("ScheherazadeNew-Bold", size: 28))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

#Preview {
    ZStack {
        Color(hex: "F8F6F0").ignoresSafeArea()
        SurahHeaderView(surahId: 1, surahName: "الْفَاتِحَةِ", ayahCount: 7, isMakki: true)
    }
}
