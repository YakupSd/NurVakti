import UIKit
import UserNotifications
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        checkNotificationStatus()
        // ── Background Refresh ─────────────────────────────────────
        BackgroundRefreshService.shared.register()
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.nurvakti.monthly.refresh",
            using: nil
        ) { task in
            Task {
                await MonthlyDuaService.shared.refreshIfNeeded()
                task.setTaskCompleted(success: true)
                self.scheduleMonthlyRefresh()
            }
        }
        scheduleMonthlyRefresh()
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

    func scheduleMonthlyRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.nurvakti.monthly.refresh")
        request.earliestBeginDate = Calendar.current.nextFirstOfMonth()
        try? BGTaskScheduler.shared.submit(request)
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { _ in }
    }
}

// ── Calendar Extension for Monthly Refresh ────────────────────────
extension Calendar {
    func nextFirstOfMonth() -> Date {
        var components = dateComponents([.year, .month], from: Date())
        if let month = components.month {
            components.month = month + 1
        }
        components.day = 1
        components.hour = 3
        components.minute = 0
        return date(from: components) ?? Date().addingTimeInterval(86400 * 28)
    }
}
