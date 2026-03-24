import SwiftUI

enum NurButtonStyle { 
    case primary    // Altın gradient dolgu
    case secondary  // Saydam, altın border
    case destructive // Kırmızı
    case ghost      // Sadece metin, ikon opsiyonel
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
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .tint(style == .primary ? .black : .nurGold)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .nurFont(fontSize.body)
                    }
                    
                    Text(title)
                        .nurFont(fontSize.body, weight: .bold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56) // Yaşlı kullanıcı için büyük alan
            .background(backgroundView)
            .foregroundColor(foregroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
        .scaleEffect(0.96)
        // ── Accessibility ──────────────────────────────────────────
        .accessibilityLabel(isLoading ? "\(title), yükleniyor" : title)
        .accessibilityHint(isDisabled ? "Şu an kullanılamaz" : "Çift dokunarak etkinleştir")
        .accessibilityAddTraits(.isButton)
        .accessibilityRemoveTraits(isDisabled ? [] : [])
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            LinearGradient(colors: [Color.nurGold, Color(hex: "FFD700")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .secondary, .ghost:
            Color.clear
        case .destructive:
            Color.red
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return .black
        case .secondary, .ghost: return .nurGold
        case .destructive: return .white
        }
    }
    
    private var borderColor: Color {
        style == .secondary ? .nurGold : .clear
    }
}

#Preview {
    VStack(spacing: 20) {
        NurButton(title: "Devam Et", style: .primary, fontSize: .large) {}
        NurButton(title: "İptal", style: .secondary, fontSize: .medium) {}
        NurButton(title: "Sil", icon: "trash", style: .destructive, fontSize: .small) {}
        NurButton(title: "Detaylar", style: .ghost, fontSize: .xlarge) {}
    }
    .padding()
}
