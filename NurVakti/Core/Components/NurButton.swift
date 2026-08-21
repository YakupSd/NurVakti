import SwiftUI

enum NurButtonStyle { 
    case primary      // Altın lüks gradient dolgu
    case secondary    // Krem zemin, altın kenarlık
    case destructive  // Kırmızı uyarı
    case ghost        // Şeffaf, hafif dokunuş
}

struct NurButton: View {
    let title: String
    var icon: String? = nil
    let style: NurButtonStyle
    let fontSize: FontSize
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.tap()
            action()
        }) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(style == .primary ? .black : .nurGold)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: iconSize, weight: .semibold))
                    }
                    
                    Text(title)
                        .nurFont(fontSize.body, weight: .bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54) // Standart VIP 54px form yüksekliği
            .background(backgroundView)
            .foregroundColor(foregroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .shadow(color: shadowColor, radius: 8, x: 0, y: 3)
        }
        .buttonStyle(BouncyButtonStyle())
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.55 : 1.0)
        .accessibilityLabel(isLoading ? "\(title), yükleniyor" : title)
        .accessibilityAddTraits(.isButton)
    }
    
    private var iconSize: CGFloat {
        switch fontSize {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        case .xlarge: return 20
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            LinearGradient(
                colors: [Color(hex: "#D4AF37"), Color(hex: "#C9A84C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            Color.white
        case .ghost:
            Color(hex: "1A1A2E").opacity(0.05)
        case .destructive:
            Color.red.opacity(0.9)
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return Color(hex: "1A1A2E")
        case .secondary: return Color(hex: "1A1A2E")
        case .ghost: return Color(hex: "1A1A2E").opacity(0.8)
        case .destructive: return .white
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary: return Color.clear
        case .secondary: return Color.nurGold.opacity(0.4)
        case .ghost: return Color(hex: "1A1A2E").opacity(0.08)
        case .destructive: return Color.clear
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary: return Color.nurGold.opacity(0.25)
        case .secondary, .ghost: return Color.black.opacity(0.02)
        case .destructive: return Color.red.opacity(0.2)
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "F8F6F0").ignoresSafeArea()
        VStack(spacing: 16) {
            NurButton(title: "Devam Et", icon: "arrow.right", style: .primary, fontSize: .medium) {}
            NurButton(title: "İptal", style: .secondary, fontSize: .medium) {}
            NurButton(title: "Sil", icon: "trash", style: .destructive, fontSize: .medium) {}
            NurButton(title: "Daha Fazla Bilgi", style: .ghost, fontSize: .medium) {}
        }
        .padding(20)
    }
}
