import SwiftUI

@main
struct NurVaktiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Services as StateObjects
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var locationService = LocationService.shared
    @StateObject private var prayerService = PrayerTimeService.shared
    @StateObject private var notifService = NotificationService.shared
    @StateObject private var persistService = PersistenceService.shared
    @StateObject private var bgService = BackgroundGradientService.shared
    @StateObject private var monthlyDuaService = MonthlyDuaService.shared
    @StateObject private var libraryService = DuaLibraryService.shared
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var userSession = UserSession.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(localization)
                .environmentObject(locationService)
                .environmentObject(prayerService)
                .environmentObject(notifService)
                .environmentObject(persistService)
                .environmentObject(bgService)
                .environmentObject(monthlyDuaService)
                .environmentObject(libraryService)
                .environmentObject(audioManager)
                .environmentObject(userSession)
                .environment(\.layoutDirection, localization.isRTL ? .rightToLeft : .leftToRight)
                .preferredColorScheme(.dark)
                .onAppear {
                    libraryService.setup()
                }
                // ── Deep Link – URL Scheme ─────────────────────────
                .onOpenURL { url in
                    DeepLinkHandler.shared.handle(url: url)
                }
        }
    }
}
