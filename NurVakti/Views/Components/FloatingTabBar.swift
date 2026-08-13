import SwiftUI

// MARK: - Tab Item Model
enum NurTab: Int, CaseIterable {
    case home     = 0
    case quran    = 1
    case dhikr    = 2  // Center/raised button
    case alarms   = 3
    case vakitler = 4

    var icon: String {
        switch self {
        case .home:     return "homePage"
        case .quran:    return "Quran"
        case .dhikr:    return "Dhikr"
        case .alarms:   return "Alarms"
        case .vakitler: return "Times"
        }
    }
    
    /// SF Symbol fallback for the active glow ring
    var sfSymbol: String {
        switch self {
        case .home:     return "house.fill"
        case .quran:    return "book.fill"
        case .dhikr:    return "hands.sparkles.fill"
        case .alarms:   return "bell.fill"
        case .vakitler: return "clock.fill"
        }
    }

    func label(for lang: LocalizationManager) -> String {
        switch self {
        case .home:
            switch lang.currentLanguage {
            case .tr: return "Ana Sayfa"
            case .ar: return "الرئيسية"
            case .en: return "Home"
            case .de: return "Start"
            case .pt: return "Início"
            }
        case .quran:
            switch lang.currentLanguage {
            case .tr: return "Kur'an"
            case .ar: return "القرآن"
            case .en: return "Quran"
            case .de: return "Koran"
            case .pt: return "Alcorão"
            }
        case .dhikr:
            switch lang.currentLanguage {
            case .tr: return "Zikir"
            case .ar: return "الذكر"
            case .en: return "Dhikr"
            case .de: return "Dhikr"
            case .pt: return "Dhikr"
            }
        case .alarms:
            switch lang.currentLanguage {
            case .tr: return "Alarmlar"
            case .ar: return "المنبهات"
            case .en: return "Alarms"
            case .de: return "Alarme"
            case .pt: return "Alarmes"
            }
        case .vakitler:
            switch lang.currentLanguage {
            case .tr: return "Vakitler"
            case .ar: return "المواقيت"
            case .en: return "Times"
            case .de: return "Zeiten"
            case .pt: return "Horários"
            }
        }
    }

    var isCenter: Bool { self == .quran }
}

// MARK: - Premium Fixed Bottom Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: NurTab
    @EnvironmentObject var loc: LocalizationManager
    @Namespace private var indicatorNS

    // Layout
    private let barHeight: CGFloat = 82
    private let indicatorHeight: CGFloat = 3
    
    // Colors — consistent dark premium palette
    private let barBgPrimary   = Color(hex: "0A0E17")
    private let barBgSecondary = Color(hex: "111827")
    private let activeGold     = Color.nurGold
    private let inactiveColor  = ColorColor(hex: "1A1A2E").opacity(0.35)

    var body: some View {
        VStack(spacing: 0) {
            // ─── Top separator line ────────────────────────────
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            ColorColor(hex: "1A1A2E").opacity(0.03),
                            Color.nurGold.opacity(0.15),
                            ColorColor(hex: "1A1A2E").opacity(0.03)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)

            // ─── Tab Items ─────────────────────────────────────
            HStack(spacing: 0) {
                ForEach(NurTab.allCases, id: \.rawValue) { tab in
                    tabItem(tab)
                }
            }
            .frame(height: barHeight)
            .padding(.bottom, safeAreaBottom > 0 ? 0 : 8)
        }
        .background(
            ZStack {
                // Base dark fill
                barBgPrimary
                
                // Subtle gradient overlay for depth
                LinearGradient(
                    colors: [
                        barBgSecondary.opacity(0.5),
                        barBgPrimary
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Ultra-thin blur material layer
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.12)
            }
        )
    }
    
    // MARK: - Individual Tab Item
    @ViewBuilder
    private func tabItem(_ tab: NurTab) -> some View {
        let isActive = selectedTab == tab
        let isCenter = tab == .quran
        
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                selectedTab = tab
            }
            UIImpactFeedbackGenerator(style: isCenter ? .medium : .light).impactOccurred()
        } label: {
            VStack(spacing: 0) {
                // ── Active indicator line ──
                ZStack {
                    if isActive {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [activeGold.opacity(0.6), activeGold, activeGold.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: isCenter ? 36 : 28, height: indicatorHeight)
                            .shadow(color: activeGold.opacity(0.6), radius: 6, y: 2)
                            .matchedGeometryEffect(id: "indicator", in: indicatorNS)
                    }
                }
                .frame(height: indicatorHeight + 2)
                
                Spacer().frame(height: 8)
                
                // ── Icon ──
                ZStack {
                    // Glow effect for center (Quran) button
                    if isCenter {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        activeGold.opacity(isActive ? 0.25 : 0.08),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 52, height: 52)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: isActive
                                        ? [Color(hex: "E8C46A"), Color(hex: "C9A84C"), Color(hex: "A07A28")]
                                        : [Color(hex: "1A2035"), Color(hex: "141B2D")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(
                                        isActive
                                            ? ColorColor(hex: "1A1A2E").opacity(0.25)
                                            : Color.nurGold.opacity(0.3),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: activeGold.opacity(isActive ? 0.5 : 0.15), radius: isActive ? 12 : 4, y: 2)
                    }
                    
                    Image(tab.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: isCenter ? 22 : 24, height: isCenter ? 22 : 24)
                        .foregroundStyle(
                            isActive
                                ? (isCenter
                                    ? AnyShapeStyle(Color.white)
                                    : AnyShapeStyle(
                                        LinearGradient(
                                            colors: [activeGold, Color(hex: "FFD700")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                      ))
                                : AnyShapeStyle(inactiveColor)
                        )
                        .scaleEffect(isActive ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isActive)
                }
                .frame(height: isCenter ? 44 : 28)
                
                Spacer().frame(height: isCenter ? 2 : 6)
                
                // ── Label ──
                Text(tab.label(for: loc))
                    .font(.system(size: 10, weight: isActive ? .bold : .medium))
                    .foregroundColor(
                        isActive
                            ? (isCenter ? activeGold : activeGold)
                            : inactiveColor
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Safe Area Helper
    private var safeAreaBottom: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .safeAreaInsets.bottom ?? 0
    }
}
