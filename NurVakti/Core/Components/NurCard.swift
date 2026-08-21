import SwiftUI

struct NurCard<Content: View>: View {
    var title: String? = nil
    var subtitle: String? = nil
    var icon: String? = nil
    var iconColor: Color = .nurGold
    var padding: CGFloat = 20
    var isPressable: Bool = false
    var action: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        Group {
            if isPressable, let action = action {
                Button(action: {
                    HapticManager.shared.light()
                    action()
                }) {
                    cardContent
                }
                .buttonStyle(CardPressableButtonStyle())
            } else {
                cardContent
            }
        }
    }
    
    private var cardContent: some View {
        VStack(spacing: 0) {
            if title != nil || icon != nil || subtitle != nil {
                HStack(alignment: .center, spacing: 12) {
                    if let icon = icon {
                        ZStack {
                            Circle()
                                .fill(iconColor.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(iconColor)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if let title = title {
                            Text(title)
                                .nurFont(17, weight: .bold)
                                .foregroundColor(Color(hex: "1A1A2E"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .nurFont(12)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    if isPressable {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.25))
                    }
                }
                .padding(.horizontal, padding)
                .padding(.top, padding)
                .padding(.bottom, 12)
            }
            
            content()
                .padding(.horizontal, padding)
                .padding(.bottom, padding)
                .padding(.top, (title != nil || icon != nil || subtitle != nil) ? 0 : padding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title ?? "")
    }
}

#Preview {
    ZStack {
        Color(hex: "F8F6F0").ignoresSafeArea()
        VStack(spacing: 20) {
            NurCard(title: "Namaz Vakitleri", subtitle: "Bugünün kalan vakitleri", icon: "clock.fill", isPressable: true) {
                Text("Örnek İçerik")
                    .foregroundColor(Color(hex: "1A1A2E"))
            }
        }
        .padding()
    }
}
