import SwiftUI

struct ContentView: View {
    @State private var selectedTab: NurTab = .home
    @State private var showSplash: Bool = true
    @State private var showOnboarding: Bool = !PersistenceService.shared.settings.hasCompletedOnboarding
    @EnvironmentObject var localization: LocalizationManager
    
    // ViewModel'ları bir kez oluştur, tab geçişlerinde yeniden oluşturma
    @StateObject private var dhikrVM = DhikrViewModel()
    @StateObject private var alarmVM = AlarmViewModel()

    init() {
        // Hide the native tab bar completely — we use our own custom bar
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView()
                    .onReceive(NotificationCenter.default.publisher(for: .init("OnboardingCompleted"))) { _ in
                        withAnimation { showOnboarding = false }
                    }
            } else if showSplash {
                SplashView {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            } else {
                mainContent
            }
        }
    }

    // MARK: - Main Content with Fixed Bottom Tab Bar
    @ViewBuilder
    private var mainContent: some View {
        ZStack(alignment: .bottom) {

            // ── Page Content ──
            Group {
                switch selectedTab {
                case .home:
                    DashboardView()
                        .transition(.opacity)
                case .quran:
                    QuranView()
                        .transition(.opacity)
                case .dhikr:
                    DhikrView(vm: dhikrVM)
                        .transition(.opacity)
                case .alarms:
                    AlarmView(vm: alarmVM)
                        .transition(.opacity)
                case .vakitler:
                    PrayerTimesView(vm: HomeViewModel.shared)
                        .transition(.opacity)
                }
            }
            // Bottom padding so content isn't hidden behind the tab bar
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 82)
            }

            // ── Fixed Bottom Tab Bar ──
            FloatingTabBar(selectedTab: $selectedTab)
                .environmentObject(localization)
        }
        .ignoresSafeArea(edges: .bottom)
        .environment(\.layoutDirection, localization.isRTL ? .rightToLeft : .leftToRight)
        .id(localization.currentLanguage)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToTab"))) { notif in
            if let tag = notif.object as? Int, let tab = NurTab(rawValue: tag) {
                withAnimation { selectedTab = tab }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocalizationManager.shared)
}

