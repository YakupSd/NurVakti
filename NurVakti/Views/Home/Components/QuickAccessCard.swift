import SwiftUI

struct QuickAccessCard: View {
    let icon: String
    let iconBg: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.tap()
            action()
        }) {
            VStack(alignment: .leading, spacing: 6) {
                // Icon circle
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconBg)
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "1A1A2E"))
                }
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.nurLightGreenPrimary)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.nurLightGreenPrimary.opacity(0.5))
                    .lineLimit(1)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 110, maxHeight: 110, alignment: .leading)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.nurLightGreenBorder, lineWidth: 1)
            )
            .cornerRadius(16)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
