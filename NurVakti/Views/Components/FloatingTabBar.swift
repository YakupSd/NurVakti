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

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: NurTab
    @EnvironmentObject var loc: LocalizationManager
    @Namespace private var tabNamespace

    // Dimensions
    private let centerBtnSize: CGFloat  = 60
    private let barHeight: CGFloat      = 62
    private let cornerRadius: CGFloat   = 26

    // Light Green Theme Palette
    private let barBg      = Color.white.opacity(0.95) // Pure light glass
    private let barBorder  = Color.nurLightGreenBorder
    private let inactiveColor = Color.nurLightGreenPrimary.opacity(0.4)
    private let activeColor   = Color.nurLightGreenPrimary
    private let pillBg     = Color.nurLightGreenSecondary.opacity(0.12)

    private let leftTabs:  [NurTab] = [.home,   .dhikr]
    private let rightTabs: [NurTab] = [.alarms, .vakitler]

    var body: some View {
        ZStack(alignment: .bottom) {

            // ─── Dark glass pill ───────────────────────────────
            HStack(spacing: 0) {
                ForEach(leftTabs, id: \.rawValue)  { tabButton($0) }

                // Gap for center button
                Spacer().frame(width: centerBtnSize + 20)

                ForEach(rightTabs, id: \.rawValue) { tabButton($0) }
            }
            .frame(height: barHeight)
            .background(
                ZStack {
                    // Base dark fill
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(barBg)

                    // Thin shimmer gradient top-to-bottom
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.07),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // Border
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(barBorder, lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
                .shadow(color: Color.nurLightGreenSecondary.opacity(0.04), radius: 10, x: 0, y: -2)
            )
            .padding(.horizontal, 16)

            // ─── Raised center button ──────────────────────────
            centerButton
                .offset(y: -(barHeight / 2 + 4))  // float above bar centre

        }
        .frame(maxWidth: .infinity)
        .frame(height: barHeight + centerBtnSize / 2)
    }

    // MARK: - Regular Tab Button
    @ViewBuilder
    private func tabButton(_ tab: NurTab) -> some View {
        let isActive = selectedTab == tab

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                selectedTab = tab
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 3) {

                // Icon container
                ZStack {
                    if isActive {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(pillBg)
                            .frame(width: 44, height: 30)
                            .matchedGeometryEffect(id: "pill", in: tabNamespace)
                    }

                    Image(tab.icon)
                        .resizable()
                        .frame(width: 28, height: 28, alignment: .center)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            isActive
                                ? LinearGradient(
                                    colors: [Color.nurLightGreenPrimary, Color.nurLightGreenSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                  )
                                : LinearGradient(
                                    colors: [inactiveColor, inactiveColor],
                                    startPoint: .top,
                                    endPoint: .bottom
                                  )
                        )
                        .scaleEffect(isActive ? 1.08 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isActive)
                }
                .frame(height: 32)

                // Label
                Text(tab.label(for: loc))
                    .font(.system(size: 10, weight: isActive ? .bold : .regular))
                    .foregroundColor(isActive ? activeColor : inactiveColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Center Raised Button
    private var centerButton: some View {
        let isActive = selectedTab == .quran

        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.68)) {
                selectedTab = .quran
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            ZStack {
                // Outer soft glow (always visible, stronger when active)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#C9A84C").opacity(isActive ? 0.35 : 0.18),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: centerBtnSize * 0.9
                        )
                    )
                    .frame(width: centerBtnSize + 18, height: centerBtnSize + 18)
                    .blur(radius: isActive ? 8 : 4)

                // Main circle — gold gradient matching nurGold theme
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#E8C46A"),
                                Color(hex: "#C9A84C"),
                                Color(hex: "#A07A28")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: centerBtnSize, height: centerBtnSize)
                    .overlay(
                        // Inner highlight ring
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                            .padding(3)
                    )
                    .shadow(color: Color(hex: "#C9A84C").opacity(0.55), radius: 14, x: 0, y: 6)
                    .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
                    .scaleEffect(isActive ? 1.07 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isActive)

                // Icon
                Image(NurTab.quran.icon)
                    .resizable()
                    .frame(width: 28, height: 28, alignment: .center)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)  // White icon on gold bg
                    .scaleEffect(isActive ? 1.12 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isActive)
            }
        }
        .buttonStyle(.plain)
    }
}
