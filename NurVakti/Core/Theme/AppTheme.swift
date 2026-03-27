import SwiftUI

// MARK: - App Colors
extension Color {
    static let nurGold       = Color(hex: "#C9A84C")
    static let nurGoldLight  = Color(hex: "#FFD700")
    static let nurNight      = Color(hex: "#0D1B2A")
    static let nurDawnTop    = Color(hex: "#FF6B6B")
    static let nurDawnBot    = Color(hex: "#FFE66D")
    static let nurDayTop     = Color(hex: "#74B9FF")
    static let nurDayBot     = Color(hex: "#0984E3")
    static let nurSunsetTop  = Color(hex: "#FD79A8")
    static let nurSunsetBot  = Color(hex: "#6C5CE7")
    static let nurMidTop     = Color(hex: "#2C3E50")
    static let nurMidBot     = Color(hex: "#000000")
}

// MARK: - Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - View Modifiers
struct NurCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(BlurView(style: .systemUltraThinMaterialDark))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct NurTitleModifier: ViewModifier {
    let size: FontSize
    func body(content: Content) -> some View {
        content
            .font(size.titleFont)
            .foregroundColor(.white)
    }
}

struct NurBodyModifier: ViewModifier {
    let size: FontSize
    func body(content: Content) -> some View {
        content
            .font(size.bodyFont)
            .foregroundColor(.white.opacity(0.9))
    }
}

extension View {
    func nurCardStyle() -> some View {
        self.modifier(NurCardModifier())
    }
    
    func nurTitleStyle(size: FontSize) -> some View {
        self.modifier(NurTitleModifier(size: size))
    }
    
    func nurBodyStyle(size: FontSize) -> some View {
        self.modifier(NurBodyModifier(size: size))
    }
}

// MARK: - Font Helpers
extension FontSize {
    var titleFont: Font {
        switch self {
        case .small: return .system(size: 20, weight: .bold)
        case .medium: return .system(size: 24, weight: .bold)
        case .large: return .system(size: 28, weight: .bold)
        case .xlarge: return .system(size: 34, weight: .bold)
        }
    }
    
    var bodyFont: Font {
        switch self {
        case .small: return .system(size: 14)
        case .medium: return .system(size: 16)
        case .large: return .system(size: 18)
        case .xlarge: return .system(size: 22)
        }
    }
    
    var captionFont: Font {
        switch self {
        case .small: return .system(size: 12)
        case .medium: return .system(size: 13)
        case .large: return .system(size: 14)
        case .xlarge: return .system(size: 16)
        }
    }
}

// MARK: - Blur View Helper
private struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
