import SwiftUI

struct NurCard<Content: View>: View {
    var title: String? = nil
    var icon: String? = nil
    var iconColor: Color = .nurGold
    var padding: CGFloat = 20
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            if title != nil || icon != nil {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .foregroundColor(iconColor)
                    }
                    if let title = title {
                        Text(title)
                            .nurFont(18, weight: .bold)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, padding)
                .padding(.top, padding)
                .padding(.bottom, 12)
            }
            
            content()
                .padding(padding)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
        )
        // ── Accessibility ──────────────────────────────────────────
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title ?? "")
    }
}

#Preview {
    NurCard(title: "Vakitler", icon: "clock.fill") {
        Text("Kart İçeriği Örneği")
            .foregroundColor(.white)
    }
    .padding()
    .background(Color.blue)
}
