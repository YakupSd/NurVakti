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
                // Circular Icon Container
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 68, height: 68)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    
                    Circle()
                        .stroke(Color.nurLightGreenBorder, lineWidth: 1)
                        .frame(width: 68, height: 68)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.nurLightGreenSecondary)
                }
                
                // Title
                Text(title)
                    .nurFont(11, weight: .bold)
                    .foregroundColor(.nurLightGreenPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85) // Allow scaling to fit
                    .frame(width: 90) // Increased width
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
