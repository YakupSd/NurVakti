import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var localization: LocalizationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 1. Ana Sayfa
            NavigationStack {
                HomeView(vm: HomeViewModel())
            }
            .tabItem {
                Label(localizedString("menu_home"), systemImage: "house.fill")
            }
            .tag(0)
            
            // 2. Kur'an
            NavigationStack {
                QuranView()
            }
            .tabItem {
                Label(localizedString("menu_quran"), systemImage: "book.fill")
            }
            .tag(1)
            
            // 3. Zikir
            NavigationStack {
                DhikrView(vm: DhikrViewModel())
            }
            .tabItem {
                Label(localizedString("menu_dhikr"), systemImage: "sparkles")
            }
            .tag(2)
            
            // 4. Alarm
            NavigationStack {
                AlarmView(vm: AlarmViewModel())
            }
            .tabItem {
                Label(localizedString("menu_alarm"), systemImage: "bell.fill")
            }
            .tag(3)
            
            // 5. Ayarlar
            NavigationStack {
                SettingsView(vm: SettingsViewModel())
            }
            .tabItem {
                Label(localizedString("menu_settings"), systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .tint(.nurGold) // Seçili tab rengi
        .environment(\.layoutDirection, localization.isRTL ? .rightToLeft : .leftToRight)
        .id(localization.currentLanguage) // Dil değişince tüm view'ları rebuild et
    }
    
    private func localizedString(_ key: String) -> String {
        switch (key, localization.currentLanguage) {
        case ("menu_home", .tr): return "Ana Sayfa"
        case ("menu_quran", .tr): return "Kur'an"
        case ("menu_dhikr", .tr): return "Zikir"
        case ("menu_alarm", .tr): return "Alarm"
        case ("menu_settings", .tr): return "Ayarlar"
        // Diğer diller...
        default: return key
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(LocalizationManager.shared)
}
