import SwiftUI

struct SurahHeaderView: View {
    let surahId: Int
    let surahName: String
    let ayahCount: Int
    let isMakki: Bool
    
    var body: some View {
        ZStack {
            // Background Banner (Gold Gradient)
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#C9A84C"), Color(hex: "#E5C87E")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 80)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
            
            // Decorative Inner Border
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                .padding(4)
                .frame(height: 80)
            
            HStack(spacing: 20) {
                // Info Left
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(ayahCount) Ayet")
                    Text(isMakki ? "Mekki" : "Medeni")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                // Name Arabic
                Text("سُورَةُ \(surahName)")
                    .font(.custom("AmiriQuran", size: 28))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                
                Spacer()
                
                // Surah Number Right
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        .frame(width: 32, height: 32)
                    Text("\(surahId)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ZStack {
        Color.mushafBackground.ignoresSafeArea()
        SurahHeaderView(surahId: 1, surahName: "الْفَاتِحَةِ", ayahCount: 7, isMakki: true)
    }
}
