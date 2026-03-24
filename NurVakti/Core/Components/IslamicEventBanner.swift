import SwiftUI

// MARK: - İslami Özel Gün Banner Bileşeni
// HomeView üzerinde bugün bir kandil/bayram varsa gösterilir.
// Kaydırılarak kapatılabilir. Tıklanınca genişleyebilir (opsiyonel).

struct IslamicEventBanner: View {
    let event: IslamicEvent
    let language: LanguageCode
    var onDismiss: (() -> Void)? = nil

    @State private var appeared = false
    @State private var offset: CGFloat = -80

    var body: some View {
        HStack(spacing: 14) {
            // Emoji ikonu
            Text(event.key.emoji)
                .font(.system(size: 36))

            // Metin
            VStack(alignment: .leading, spacing: 3) {
                Text(bannerTitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(0.5)

                Text(event.key.name(for: language))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()

            // Kapat butonu
            if let onDismiss = onDismiss {
                Button(action: {
                    HapticManager.shared.tap()
                    withAnimation(.easeIn(duration: 0.25)) {
                        offset = -80
                        appeared = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Banner'ı kapat")
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(bannerBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(bannerBorderColor.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: bannerBorderColor.opacity(0.3), radius: 12, x: 0, y: 6)
        .offset(y: offset)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) {
                offset = 0
                appeared = true
            }
        }
        // ── Accessibility ──────────────────────────────────────────
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(event.key.name(for: language)) — \(bannerTitle)")
    }

    // MARK: - Computed

    private var bannerTitle: String {
        switch language {
        case .tr: return event.key.isSpecialNight ? "Mübarek Bir Gece" : "Bugün"
        case .en: return event.key.isSpecialNight ? "Blessed Night" : "Today"
        case .ar: return event.key.isSpecialNight ? "ليلة مباركة" : "اليوم"
        case .de: return event.key.isSpecialNight ? "Gesegnete Nacht" : "Heute"
        case .pt: return event.key.isSpecialNight ? "Noite Abençoada" : "Hoje"
        }
    }

    private var bannerBackground: some View {
        Group {
            switch event.key {
            case .laylatalQadr:
                LinearGradient(colors: [Color(hex: "#4A0E8F"), Color(hex: "#1A0A3D")],
                               startPoint: .leading, endPoint: .trailing)
            case .eidAlFitr, .eidAlAdha:
                LinearGradient(colors: [Color(hex: "#1D5016"), Color(hex: "#0A2410")],
                               startPoint: .leading, endPoint: .trailing)
            case .ramadanStart:
                LinearGradient(colors: [Color(hex: "#1A3A5C"), Color(hex: "#0D1B2A")],
                               startPoint: .leading, endPoint: .trailing)
            default:
                LinearGradient(colors: [Color.nurGold.opacity(0.25), Color(hex: "#1a2030")],
                               startPoint: .leading, endPoint: .trailing)
            }
        }
    }

    private var bannerBorderColor: Color {
        switch event.key {
        case .laylatalQadr:                    return .purple
        case .eidAlFitr, .eidAlAdha:           return .green
        case .ramadanStart:                    return Color(hex: "#74B9FF")
        default:                               return .nurGold
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "0D1B2A").ignoresSafeArea()
        VStack(spacing: 16) {
            IslamicEventBanner(
                event: IslamicEvent(key: .laylatalQadr, hijriMonth: 9, hijriDay: 27, durationDays: 1),
                language: .tr
            ) {}
            IslamicEventBanner(
                event: IslamicEvent(key: .eidAlFitr, hijriMonth: 10, hijriDay: 1, durationDays: 3),
                language: .en
            ) {}
            IslamicEventBanner(
                event: IslamicEvent(key: .ramadanStart, hijriMonth: 9, hijriDay: 1, durationDays: 30),
                language: .ar
            ) {}
        }
        .padding()
    }
}
