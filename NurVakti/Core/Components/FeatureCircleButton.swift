import SwiftUI

struct FeatureCircleButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            VStack(spacing: 10) {
                // Circular Icon Container — Apple VIP Glass
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                        )
                    
                    Circle()
                        .fill(Color.nurGold.opacity(0.1))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.nurGold, Color(hex: "B8860B")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Title
                Text(title)
                    .nurFont(11, weight: .bold)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .frame(width: 84)
            }
        }
        .buttonStyle(BouncyButtonStyle())
    }
}

#Preview {
    ZStack {
        Color(hex: "F8F6F0").ignoresSafeArea()
        HStack(spacing: 16) {
            FeatureCircleButton(icon: "book.fill", title: "Kur'an-ı Kerim") {}
            FeatureCircleButton(icon: "circle.circle.fill", title: "Zikirmatik") {}
            FeatureCircleButton(icon: "location.north.line.fill", title: "Kıble Bulucu") {}
        }
    }
}
