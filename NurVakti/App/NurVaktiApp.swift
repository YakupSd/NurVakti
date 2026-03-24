import SwiftUI

@main
struct NurVaktiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Services as StateObjects
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var locationService = LocationService()
    @StateObject private var prayerService = PrayerTimeService()
    @StateObject private var notifService = NotificationService.shared
    @StateObject private var persistService = PersistenceService.shared
    @StateObject private var bgService = BackgroundGradientService()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(localization)
                .environmentObject(locationService)
                .environmentObject(prayerService)
                .environmentObject(notifService)
                .environmentObject(persistService)
                .environmentObject(bgService)
                .environment(\.layoutDirection, localization.isRTL ? .rightToLeft : .leftToRight)
                .preferredColorScheme(.dark)
                // ── Deep Link – URL Scheme ─────────────────────────
                .onOpenURL { url in
                    DeepLinkHandler.shared.handle(url: url)
                }
        }
    }
}
