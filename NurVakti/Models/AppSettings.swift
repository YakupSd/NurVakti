import Foundation

public struct AppSettings: Codable {
    public var language: LanguageCode = .tr
    public var fontSize: FontSize = .large    // Varsayılan büyük (yaşlı kitle)
    public var calculationMethod: String = "Diyanet"
    public var madhab: Madhab = .hanafi
    public var notificationsEnabled: Bool = true
    public var manualCityName: String? = nil
    public var useManualLocation: Bool = false
    // ── Onboarding ──────────────────────────────────────────
    public var hasCompletedOnboarding: Bool = false
    
    public init() {}
}

public enum Madhab: String, Codable, CaseIterable {
    case hanafi, shafii
    
    public func displayName(for language: LanguageCode) -> String {
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
