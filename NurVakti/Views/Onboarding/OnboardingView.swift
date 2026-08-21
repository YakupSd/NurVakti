import SwiftUI

struct OnboardingView: View {
    @StateObject private var vm: OnboardingViewModel
    @EnvironmentObject var localization: LocalizationManager

    init(locationService: LocationService? = nil) {
        _vm = StateObject(wrappedValue: OnboardingViewModel(locationService: locationService ?? LocationService()))
    }

    var body: some View {
        ZStack {
            // Background — Warm Ivory & Subtle Gold Ambient Glow
            LinearGradient(
                colors: [
                    Color(hex: "FCFAF7"),
                    Color(hex: "F8F4EC"),
                    Color(hex: "F2ECE0")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Ambient background lighting
            GeometryReader { proxy in
                ZStack {
                    Circle()
                        .fill(Color.nurGold.opacity(0.12))
                        .frame(width: 280, height: 280)
                        .blur(radius: 60)
                        .offset(x: proxy.size.width * 0.45, y: -proxy.size.height * 0.1)

                    Circle()
                        .fill(Color(hex: "5B8FB9").opacity(0.08))
                        .frame(width: 240, height: 240)
                        .blur(radius: 50)
                        .offset(x: -proxy.size.width * 0.4, y: proxy.size.height * 0.35)
                }
            }
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                // ─── Top Progress Indicator ───
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(
                                vm.currentPage == index
                                    ? LinearGradient(
                                        colors: [Color.nurGoldLight, Color.nurGold, Color(hex: "A37719")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        colors: [Color(hex: "1A1A2E").opacity(0.1), Color(hex: "1A1A2E").opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                            )
                            .frame(width: vm.currentPage == index ? 32 : 8, height: 6)
                            .shadow(
                                color: vm.currentPage == index ? Color.nurGold.opacity(0.4) : Color.clear,
                                radius: 4,
                                y: 1
                            )
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: vm.currentPage)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 12)

                Spacer(minLength: 12)

                // ─── Active Page ───
                Group {
                    switch vm.currentPage {
                    case 0: OnboardingLanguagePage(vm: vm)
                    case 1: OnboardingLocationPage(vm: vm)
                    default: OnboardingNotificationPage(vm: vm)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
                .id(vm.currentPage)

                Spacer(minLength: 12)

                // ─── Bottom Back Button ───
                if vm.currentPage > 0 {
                    Button(action: {
                        HapticManager.shared.light()
                        vm.goBack()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .semibold))
                            Text(localization.localizedString("onboarding.back"))
                                .nurFont(14, weight: .medium)
                        }
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.55))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.6))
                                .overlay(
                                    Capsule()
                                        .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.bottom, 16)
                } else {
                    // Placeholder for vertical alignment stability
                    Color.clear
                        .frame(height: 36)
                        .padding(.bottom, 16)
                }
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SAYFA 1 — Dil Seçimi
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct OnboardingLanguagePage: View {
    @ObservedObject var vm: OnboardingViewModel
    @EnvironmentObject var localization: LocalizationManager

    private let languages: [(LanguageCode, String, String)] = [
        (.tr, "🇹🇷", "Türkçe"),
        (.ar, "🇸🇦", "العربية"),
        (.en, "🇬🇧", "English"),
        (.de, "🇩🇪", "Deutsch"),
        (.pt, "🇧🇷", "Português"),
    ]

    var body: some View {
        VStack(spacing: 24) {
            // Hero Badge
            VStack(spacing: 14) {
                ZStack {
                    // Outer Ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.nurGold.opacity(0.4), Color.nurGold.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 96, height: 96)

                    // Inner Soft Glow
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color(hex: "FAF3E3")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.nurGold.opacity(0.2), radius: 14, y: 6)

                    Image(systemName: "globe.europe.africa.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.nurGoldLight, Color.nurGold, Color(hex: "A37719")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 6) {
                    Text(localization.localizedString("onboarding.language.title"))
                        .nurFont(26, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E"))
                        .multilineTextAlignment(.center)

                    Text(localization.localizedString("onboarding.language.subtitle"))
                        .nurFont(14)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }

            // Language Options
            VStack(spacing: 10) {
                ForEach(languages, id: \.0) { code, flag, name in
                    let isSelected = vm.selectedLanguage == code
                    Button(action: {
                        HapticManager.shared.selectionChanged()
                        vm.selectLanguage(code)
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(isSelected ? Color.nurGold.opacity(0.12) : Color(hex: "1A1A2E").opacity(0.04))
                                    .frame(width: 36, height: 36)
                                Text(flag)
                                    .font(.system(size: 20))
                            }

                            Text(name)
                                .nurFont(16, weight: isSelected ? .bold : .medium)
                                .foregroundColor(Color(hex: "1A1A2E"))

                            Spacer()

                            if isSelected {
                                ZStack {
                                    Circle()
                                        .fill(Color.nurGold)
                                        .frame(width: 22, height: 22)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .background(isSelected ? Color.white : Color.white.opacity(0.85))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    isSelected
                                        ? LinearGradient(
                                            colors: [Color.nurGold, Color.nurGoldLight],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        : LinearGradient(
                                            colors: [Color(hex: "1A1A2E").opacity(0.06), Color(hex: "1A1A2E").opacity(0.04)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                    lineWidth: isSelected ? 1.8 : 1
                                )
                        )
                        .shadow(
                            color: isSelected ? Color.nurGold.opacity(0.15) : Color(hex: "1A1A2E").opacity(0.03),
                            radius: isSelected ? 8 : 4,
                            y: isSelected ? 3 : 2
                        )
                    }
                    .buttonStyle(CardPressableButtonStyle(scale: 0.98))
                }
            }
            .padding(.horizontal, 24)

            // Continue Button
            Button(action: {
                HapticManager.shared.tap()
                vm.goNext()
            }) {
                HStack(spacing: 8) {
                    Text(localization.localizedString("general.continue"))
                        .nurFont(16, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E"))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "1A1A2E"))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "F2D679"),
                            Color.nurGold,
                            Color(hex: "C29B27")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: Color.nurGold.opacity(0.35), radius: 12, y: 5)
            }
            .buttonStyle(BouncyButtonStyle())
            .padding(.horizontal, 24)
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SAYFA 2 — Konum İzni
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct OnboardingLocationPage: View {
    @ObservedObject var vm: OnboardingViewModel
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        VStack(spacing: 24) {
            // Hero Badge
            VStack(spacing: 14) {
                ZStack {
                    // Outer Ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "3B82F6").opacity(0.35), Color(hex: "3B82F6").opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 96, height: 96)

                    // Inner Soft Glow
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color(hex: "EFF6FF")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: "3B82F6").opacity(0.18), radius: 14, y: 6)

                    Image(systemName: "location.north.circle.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "60A5FA"), Color(hex: "2563EB")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 6) {
                    Text(localization.localizedString("onboarding.location.title"))
                        .nurFont(26, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E"))
                        .multilineTextAlignment(.center)

                    Text(localization.localizedString("onboarding.location.subtitle"))
                        .nurFont(14)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 24)
                }
            }

            // Benefits Inset Card
            VStack(spacing: 14) {
                benefitRow(
                    icon: "clock.badge.checkmark.fill",
                    iconColor: Color.nurGold,
                    bgColor: Color.nurGold.opacity(0.12),
                    text: localization.localizedString("onboarding.location.benefit1")
                )

                Divider()
                    .background(Color(hex: "1A1A2E").opacity(0.06))

                benefitRow(
                    icon: "safari.fill",
                    iconColor: Color(hex: "2563EB"),
                    bgColor: Color(hex: "3B82F6").opacity(0.12),
                    text: localization.localizedString("onboarding.location.benefit2")
                )
            }
            .padding(18)
            .background(Color.white)
            .cornerRadius(22)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        LinearGradient(
                            colors: [Color.nurGold.opacity(0.2), Color(hex: "1A1A2E").opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color(hex: "1A1A2E").opacity(0.04), radius: 12, y: 4)
            .padding(.horizontal, 24)

            // Action Buttons
            VStack(spacing: 10) {
                Button(action: {
                    HapticManager.shared.tap()
                    Task { await vm.requestLocation() }
                }) {
                    HStack(spacing: 8) {
                        if vm.isRequestingLocation {
                            ProgressView()
                                .tint(Color(hex: "1A1A2E"))
                        } else {
                            Image(systemName: "location.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A2E"))
                            Text(localization.localizedString("onboarding.location.button"))
                                .nurFont(16, weight: .bold)
                                .foregroundColor(Color(hex: "1A1A2E"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: "F2D679"),
                                Color.nurGold,
                                Color(hex: "C29B27")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: Color.nurGold.opacity(0.35), radius: 12, y: 5)
                }
                .buttonStyle(BouncyButtonStyle())
                .disabled(vm.isRequestingLocation)

                Button(action: {
                    HapticManager.shared.light()
                    vm.skipLocation()
                }) {
                    Text(localization.localizedString("onboarding.skip"))
                        .nurFont(14, weight: .medium)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                        .frame(height: 34)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func benefitRow(icon: String, iconColor: Color, bgColor: Color, text: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(bgColor)
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            Text(text)
                .nurFont(14, weight: .medium)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SAYFA 3 — Bildirim İzni
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct OnboardingNotificationPage: View {
    @ObservedObject var vm: OnboardingViewModel
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        VStack(spacing: 24) {
            // Hero Badge
            VStack(spacing: 14) {
                ZStack {
                    // Outer Ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "F59E0B").opacity(0.35), Color(hex: "F59E0B").opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 96, height: 96)

                    // Inner Soft Glow
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color(hex: "FFFBEB")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: "F59E0B").opacity(0.18), radius: 14, y: 6)

                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FBBF24"), Color(hex: "D97706")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 6) {
                    Text(localization.localizedString("onboarding.notification.title"))
                        .nurFont(26, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E"))
                        .multilineTextAlignment(.center)

                    Text(localization.localizedString("onboarding.notification.subtitle"))
                        .nurFont(14)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 24)
                }
            }

            // Benefits Inset Card
            VStack(spacing: 14) {
                benefitRow(
                    icon: "speaker.wave.2.fill",
                    iconColor: Color(hex: "D97706"),
                    bgColor: Color(hex: "F59E0B").opacity(0.12),
                    text: localization.localizedString("onboarding.notification.benefit1")
                )

                Divider()
                    .background(Color(hex: "1A1A2E").opacity(0.06))

                benefitRow(
                    icon: "timer",
                    iconColor: Color.nurGold,
                    bgColor: Color.nurGold.opacity(0.12),
                    text: localization.localizedString("onboarding.notification.benefit2")
                )
            }
            .padding(18)
            .background(Color.white)
            .cornerRadius(22)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        LinearGradient(
                            colors: [Color.nurGold.opacity(0.2), Color(hex: "1A1A2E").opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color(hex: "1A1A2E").opacity(0.04), radius: 12, y: 4)
            .padding(.horizontal, 24)

            // Action Buttons
            VStack(spacing: 10) {
                Button(action: {
                    HapticManager.shared.success()
                    Task { await vm.requestNotification() }
                }) {
                    HStack(spacing: 8) {
                        if vm.isRequestingNotif {
                            ProgressView()
                                .tint(Color(hex: "1A1A2E"))
                        } else {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A2E"))
                            Text(localization.localizedString("onboarding.notification.button"))
                                .nurFont(16, weight: .bold)
                                .foregroundColor(Color(hex: "1A1A2E"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: "F2D679"),
                                Color.nurGold,
                                Color(hex: "C29B27")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: Color.nurGold.opacity(0.35), radius: 12, y: 5)
                }
                .buttonStyle(BouncyButtonStyle())
                .disabled(vm.isRequestingNotif)

                Button(action: {
                    HapticManager.shared.light()
                    vm.skipNotification()
                }) {
                    Text(localization.localizedString("onboarding.skip"))
                        .nurFont(14, weight: .medium)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                        .frame(height: 34)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func benefitRow(icon: String, iconColor: Color, bgColor: Color, text: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(bgColor)
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            Text(text)
                .nurFont(14, weight: .medium)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(LocalizationManager.shared)
        .environmentObject(PersistenceService.shared)
}
