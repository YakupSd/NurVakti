import SwiftUI

struct OnboardingView: View {
    @StateObject private var vm: OnboardingViewModel
    @EnvironmentObject var localization: LocalizationManager

    init(locationService: LocationService = LocationService()) {
        _vm = StateObject(wrappedValue: OnboardingViewModel(locationService: locationService))
    }

    var body: some View {
        ZStack {
            // Ortak Arka Plan
            LinearGradient(
                colors: [Color(hex: "#0D1B2A"), Color(hex: "#1a2a4a")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            StarFieldView(opacity: 0.6)

            VStack(spacing: 0) {
                // ─── Page Indicator ───
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(vm.currentPage == index ? Color.nurGold : Color.white.opacity(0.25))
                            .frame(width: vm.currentPage == index ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.4), value: vm.currentPage)
                    }
                }
                .padding(.top, 60)

                Spacer()

                // ─── Aktif Sayfa ───
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

                Spacer()

                // ─── Geri Butonu ───
                if vm.currentPage > 0 {
                    Button(action: vm.goBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text(localization.localizedString("onboarding.back"))
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.bottom, 8)
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
        VStack(spacing: 40) {
            // İkon
            VStack(spacing: 20) {
                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(
                        LinearGradient(colors: [.nurGold, .nurGoldLight], startPoint: .top, endPoint: .bottom)
                    )

                VStack(spacing: 8) {
                    Text(localization.localizedString("onboarding.language.title"))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text(localization.localizedString("onboarding.language.subtitle"))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            // Dil Listesi
            VStack(spacing: 12) {
                ForEach(languages, id: \.0) { code, flag, name in
                    Button(action: { vm.selectLanguage(code) }) {
                        HStack(spacing: 16) {
                            Text(flag).font(.title)
                            Text(name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                            if vm.selectedLanguage == code {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.nurGold)
                                    .font(.title2)
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 60)
                        .background(vm.selectedLanguage == code
                                    ? Color.nurGold.opacity(0.15)
                                    : Color.white.opacity(0.07))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(vm.selectedLanguage == code ? Color.nurGold : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .accessibilityLabel(name)
                    .accessibilityAddTraits(vm.selectedLanguage == code ? [.isSelected] : [])
                }
            }
            .padding(.horizontal, 24)

            // İleri Butonu
            NurButton(title: localization.localizedString("onboarding.next"), icon: "arrow.right", style: .primary, fontSize: .large) {
                vm.goNext()
            }
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
        VStack(spacing: 44) {
            // İkon
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.nurGold.opacity(0.12))
                        .frame(width: 140, height: 140)
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(
                            LinearGradient(colors: [.nurGold, .nurGoldLight], startPoint: .top, endPoint: .bottom)
                        )
                }

                VStack(spacing: 10) {
                    Text(localization.localizedString("onboarding.location.title"))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(localization.localizedString("onboarding.location.body"))
                        .font(.body)
                        .foregroundColor(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }

            // Özellik Maddeleri
            VStack(spacing: 16) {
                featureRow(icon: "moon.stars", text: localization.localizedString("onboarding.feature.prayerTimes"))
                featureRow(icon: "arrow.triangle.2.circlepath", text: localization.localizedString("onboarding.feature.autoUpdate"))
                featureRow(icon: "location",   text: localization.localizedString("onboarding.feature.noUpload"))
            }
            .padding(.horizontal, 28)

            // İzin / Atla Butonları
            VStack(spacing: 12) {
                if vm.isRequestingLocation {
                    ProgressView().tint(.white)
                } else {
                    NurButton(title: localization.localizedString("onboarding.location.allow"),
                              icon: "location.fill",
                              style: .primary, fontSize: .large) {
                        Task { await vm.requestLocation() }
                    }

                    Button(localization.localizedString("onboarding.location.skip")) { vm.skipLocation() }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.45))
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .frame(width: 32, height: 32)
                .foregroundColor(.nurGold)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
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
        VStack(spacing: 44) {
            // İkon
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.nurGold.opacity(0.12))
                        .frame(width: 140, height: 140)
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 68))
                        .foregroundStyle(
                            LinearGradient(colors: [.nurGold, .nurGoldLight], startPoint: .top, endPoint: .bottom)
                        )
                }

                VStack(spacing: 10) {
                    Text(localization.localizedString("onboarding.notif.title"))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(localization.localizedString("onboarding.notif.body"))
                        .font(.body)
                        .foregroundColor(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }

            // Özellik Maddeleri
            VStack(spacing: 16) {
                featureRow(icon: "bell",         text: localization.localizedString("onboarding.feature.customAlert"))
                featureRow(icon: "speaker.wave.2", text: localization.localizedString("onboarding.feature.adhan"))
                featureRow(icon: "gearshape",    text: localization.localizedString("onboarding.feature.customEach"))
            }
            .padding(.horizontal, 28)

            // İzin / Atla
            VStack(spacing: 12) {
                if vm.isRequestingNotif {
                    ProgressView().tint(.white)
                } else {
                    NurButton(title: localization.localizedString("onboarding.notif.allow"),
                              icon: "bell.fill",
                              style: .primary, fontSize: .large) {
                        Task { await vm.requestNotification() }
                    }

                    Button(localization.localizedString("onboarding.notif.skip")) { vm.skipNotification() }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.45))
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .frame(width: 32, height: 32)
                .foregroundColor(.nurGold)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(LocalizationManager.shared)
}
