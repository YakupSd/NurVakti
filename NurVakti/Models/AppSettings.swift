import Foundation

struct AppSettings: Codable {
    var language: LanguageCode = .tr
    var fontSize: FontSize = .large    // Varsayılan büyük (yaşlı kitle)
    var calculationMethod: String = "Diyanet"
    var madhab: Madhab = .hanafi
    var notificationsEnabled: Bool = true
    var manualCityName: String? = nil
    var useManualLocation: Bool = false
    // ── Onboarding ──────────────────────────────────────────
    var hasCompletedOnboarding: Bool = false
}

enum Madhab: String, Codable, CaseIterable {
    case hanafi, shafii
    
    func displayName(for language: LanguageCode) -> String {
        switch (self, language) {
        case (.hanafi, .tr): return "Hanefi"
        case (.shafii, .tr): return "Şafii"
        case (.hanafi, .ar): return "حنفي"
        case (.shafii, .ar): return "شافعي"
        case (.hanafi, .en): return "Hanafi"
        case (.shafii, .en): return "Shafii"
        case (.hanafi, .de): return "Hanafitisch"
        case (.shafii, .de): return "Schafiitisch"
        case (.hanafi, .pt): return "Hanafi"
        case (.shafii, .pt): return "Shafii"
        }
    }
}

extension AppSettings {
    static func load() -> AppSettings {
        PersistenceService.shared.load(key: "app_settings", as: AppSettings.self) ?? AppSettings()
    }
    
    func save() {
        PersistenceService.shared.save(self, key: "app_settings")
    }
}
