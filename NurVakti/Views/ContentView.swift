import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var showSplash: Bool = true
    @State private var showOnboarding: Bool = !PersistenceService.shared.settings.hasCompletedOnboarding
    @EnvironmentObject var localization: LocalizationManager
    
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
                TabView(selection: $selectedTab) {
                    
                    HomeView(vm: HomeViewModel())
                        .tabItem {
                            Label(localization.localizedString("tab.home"), systemImage: "moon.stars.fill")
                        }
                        .tag(0)
                    
                    QuranView()
                        .tabItem {
                            Label(localization.localizedString("tab.quran"), systemImage: "book.fill")
                        }
                        .tag(1)
                    
                    DhikrView(vm: DhikrViewModel())
                        .tabItem {
                            Label(localization.localizedString("tab.dhikr"), systemImage: "circle.grid.3x3.fill")
                        }
                        .tag(2)
                    
                    AlarmView(vm: AlarmViewModel())
                        .tabItem {
                            Label(localization.localizedString("tab.alarms"), systemImage: "bell.fill")
                        }
                        .tag(3)
                    
                    SettingsView(vm: SettingsViewModel())
                        .tabItem {
                            Label(localization.localizedString("tab.settings"), systemImage: "gearshape.fill")
                        }
                        .tag(4)
                }
                .accentColor(.nurGold)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToTab"))) { notif in
                    if let tab = notif.object as? Int {
                        selectedTab = tab
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocalizationManager.shared)
}
