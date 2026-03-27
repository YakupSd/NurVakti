import SwiftUI

struct BesmeleView: View {
    var body: some View {
        HStack(spacing: 16) {
            // Left Ornament
            decorationLine
            
            Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                .font(.custom("AmiriQuran", size: 30))
                .foregroundColor(.black.opacity(0.9))
            
            // Right Ornament
            decorationLine
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var decorationLine: some View {
        HStack(spacing: 4) {
            Circle().fill(Color.nurGoldPremium).frame(width: 4, height: 4)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.nurGoldPremium, Color.nurGoldPremium.opacity(0)],
                        startPoint: .trailing,
                        endPoint: .leading
                    )
                )
                .frame(height: 1)
                .frame(width: 40)
        }
    }
}

#Preview {
    ZStack {
        Color.mushafBackground.ignoresSafeArea()
        BesmeleView()
    }
}
