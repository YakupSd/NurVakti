import Foundation
import SwiftUI
import Combine
import UserNotifications
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var selectedLanguage: LanguageCode
    @Published var fontSize: FontSize
    @Published var calcMethod: String
    @Published var madhab: Madhab
    @Published var notifStatus: UNAuthorizationStatus = .notDetermined
    
    private let persistService: PersistenceService
    private let notifService: NotificationService
    
    init(persistService: PersistenceService? = nil, notifService: NotificationService? = nil) {
        let actualPersistService = persistService ?? .shared
        let actualNotifService = notifService ?? .shared
        self.persistService = actualPersistService
        self.notifService = actualNotifService
        
        let initialSettings = actualPersistService.settings
        self.settings = initialSettings
        self.selectedLanguage = initialSettings.language
        self.fontSize = initialSettings.fontSize
        self.calcMethod = initialSettings.calculationMethod
        self.madhab = initialSettings.madhab
    }
    
    func onAppear() async {
        await notifService.checkPermission()
        self.notifStatus = notifService.permissionStatus
    }
    
    func changeLanguage(_ code: LanguageCode) {
        selectedLanguage = code
        LocalizationManager.shared.setLanguage(code)
        saveSettings()
        
        // Bildirimleri yeni dilde planla
        // Task { await notifService.scheduleAll(...) }
    }
    
    func changeFontSize(_ size: FontSize) {
        fontSize = size
        saveSettings()
    }
    
    func changeCalcMethod(_ method: String) {
        calcMethod = method
        saveSettings()
        // PrayerTimeService yeniden hesaplama tetiklemesi gerekebilir
    }
    
    func changeMadhab(_ value: Madhab) {
        madhab = value
        saveSettings()
    }
    
    private func saveSettings() {
        settings.language = selectedLanguage
        settings.fontSize = fontSize
        settings.calculationMethod = calcMethod
        settings.madhab = madhab
        persistService.saveSettings(settings)
    }
    
    func resetToDefaults() {
        let defaults = AppSettings()
        self.settings = defaults
        changeLanguage(defaults.language)
        changeFontSize(defaults.fontSize)
        changeCalcMethod(defaults.calculationMethod)
        changeMadhab(defaults.madhab)
    }
    
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
