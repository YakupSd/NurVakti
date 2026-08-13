import SwiftUI

struct FeatureCircleButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.tap()
            action()
        }) {
            VStack(spacing: 12) {
                // Circular Icon Container — Dark Glass
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.nurGold.opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 40
                            )
                        )
                        .frame(width: 72, height: 72)
                    
                    // Main circle
                    Circle()
                        .fill(ColorColor(hex: "1A1A2E").opacity(0.06))
                        .frame(width: 68, height: 68)
                        .overlay(
                            Circle()
                                .stroke(ColorColor(hex: "1A1A2E").opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.nurGold, Color(hex: "FFD700")],
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
                    .minimumScaleFactor(0.85) // Allow scaling to fit
                    .frame(width: 90) // Increased width
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
