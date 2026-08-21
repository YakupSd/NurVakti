import SwiftUI

struct SectionHeader: View {
    let title: String
    var icon: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.nurGold)
            }
            
            Text(title.uppercased())
                .nurFont(12, weight: .bold)
                .kerning(1.2)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.55))
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: {
                    HapticManager.shared.light()
                    action()
                }) {
                    Text(actionTitle)
                        .nurFont(12, weight: .semibold)
                        .foregroundColor(.nurGold)
                }
                .buttonStyle(BouncyButtonStyle())
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }
}

#Preview {
    ZStack {
        Color(hex: "F8F6F0").ignoresSafeArea()
        VStack(spacing: 20) {
            SectionHeader(title: "Günün Vakitleri", icon: "clock.fill", actionTitle: "Tümünü Gör") {}
            SectionHeader(title: "Özel Zikirler", icon: "sparkles")
        }
        .padding()
    }
}
