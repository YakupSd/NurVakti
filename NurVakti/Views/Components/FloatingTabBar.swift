import SwiftUI

// MARK: - Tab Item Model
public enum NurTab: Int, CaseIterable {
    case home     = 0
    case quran    = 1
    case dhikr    = 2
    case alarms   = 3
    case vakitler = 4

    var activeIcon: String {
        switch self {
        case .home:     return "house.fill"
        case .quran:    return "book.closed.fill"
        case .dhikr:    return "hands.sparkles.fill"
        case .alarms:   return "bell.badge.fill"
        case .vakitler: return "clock.fill"
        }
    }
    
    var inactiveIcon: String {
        switch self {
        case .home:     return "house"
        case .quran:    return "book.closed"
        case .dhikr:    return "hands.sparkles"
        case .alarms:   return "bell"
        case .vakitler: return "clock"
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
}

// MARK: - Luxury Floating Island Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: NurTab
    @EnvironmentObject var loc: LocalizationManager
    @Namespace private var tabAnimationNS

    var body: some View {
        HStack(spacing: 4) {
            ForEach(NurTab.allCases, id: \.rawValue) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(
            ZStack {
                // Glassmorphism blur
                BlurView(style: .systemUltraThinMaterialLight)
                
                // Warm Ivory Luxury Tint
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.94),
                        Color(hex: "FCFAF6").opacity(0.88)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color.nurGold.opacity(0.35),
                            Color.white.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Color(hex: "1A1A2E").opacity(0.08), radius: 24, x: 0, y: 8)
        .shadow(color: Color.nurGold.opacity(0.08), radius: 10, x: 0, y: 2)
        .padding(.horizontal, 20)
        .padding(.bottom, safeAreaBottom > 0 ? safeAreaBottom : 16)
    }

    // MARK: - Tab Item Button
    private func tabButton(for tab: NurTab) -> some View {
        let isActive = selectedTab == tab

        return Button {
            if selectedTab != tab {
                HapticManager.shared.selectionChanged()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                    selectedTab = tab
                }
            }
        } label: {
            ZStack {
                // Active Animated Pill Indicator
                if isActive {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.nurGold.opacity(0.18),
                                    Color.nurGold.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.nurGold.opacity(0.32), lineWidth: 1)
                        )
                        .matchedGeometryEffect(id: "activeTabIndicator", in: tabAnimationNS)
                }

                VStack(spacing: 3) {
                    Image(systemName: isActive ? tab.activeIcon : tab.inactiveIcon)
                        .font(.system(size: isActive ? 18 : 17, weight: isActive ? .bold : .medium))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(
                            isActive
                                ? LinearGradient(
                                    colors: [Color(hex: "C9A84C"), Color(hex: "E5C158")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                  )
                                : LinearGradient(
                                    colors: [Color(hex: "1A1A2E").opacity(0.42), Color(hex: "1A1A2E").opacity(0.42)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                  )
                        )
                        .scaleEffect(isActive ? 1.08 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isActive)

                    Text(tab.label(for: loc))
                        .nurFont(10, weight: isActive ? .bold : .medium)
                        .foregroundColor(
                            isActive
                                ? Color(hex: "A37D1D")
                                : Color(hex: "1A1A2E").opacity(0.45)
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .contentShape(Rectangle())
            }
            .frame(height: 50)
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

#Preview {
    ZStack(alignment: .bottom) {
        Color(hex: "F8F6F0").ignoresSafeArea()
        FloatingTabBar(selectedTab: .constant(.home))
            .environmentObject(LocalizationManager.shared)
    }
}
