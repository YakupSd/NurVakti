import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        checkNotificationStatus()
        // ── Background Refresh ─────────────────────────────────────
        BackgroundRefreshService.shared.register()
        return true
    }

    // MARK: - Deep Link — URL Scheme
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        DeepLinkHandler.shared.handle(url: url)
        return true
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Uygulama öndeyken bildirimi banner olarak göster
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    /// Bildirimdeki aksiyonlar veya dokunuş
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // Deep link URL varsa kullan
        if let urlString = userInfo["deepLinkURL"] as? String,
           let url = URL(string: urlString) {
            DeepLinkHandler.shared.handle(url: url)
        }
        // Geriye dönük uyumluluk: tabIndex
        else if let tabIndex = userInfo["tabIndex"] as? Int {
            NotificationCenter.default.post(name: .init("NavigateToTab"), object: tabIndex)
        }
        completionHandler()
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { _ in }
    }
}
