import SwiftUI

struct QuickAccessCard: View {
    let icon: String
    let iconBg: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBg)
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: icon)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(Color(hex: "1A1A2E"))
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .nurFont(13, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    
                    Text(subtitle)
                        .nurFont(11)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 114, maxHeight: 114, alignment: .leading)
            .background(Color.white)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.025), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(CardPressableButtonStyle(scale: 0.96))
    }
}

#Preview {
    ZStack {
        Color(hex: "F8F6F0").ignoresSafeArea()
        HStack(spacing: 12) {
            QuickAccessCard(icon: "hands.sparkles.fill", iconBg: Color.nurGold.opacity(0.15), title: "Namaz Duaları", subtitle: "Okunan dualar") {}
            QuickAccessCard(icon: "location.north.fill", iconBg: Color.blue.opacity(0.12), title: "Kıble Bulucu", subtitle: "158° SE") {}
        }
        .padding()
    }
}
