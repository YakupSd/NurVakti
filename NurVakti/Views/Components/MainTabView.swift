import SwiftUI

/// Legacy wrapper — kept for backwards compatibility.
/// Primary entry point is ContentView which embeds FloatingTabBar directly.
struct MainTabView: View {
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        ContentView()
            .environmentObject(localization)
    }
}

#Preview {
    MainTabView()
        .environmentObject(LocalizationManager.shared)
}

