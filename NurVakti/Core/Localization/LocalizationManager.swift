import SwiftUI
import Combine

public final class LocalizationManager: ObservableObject {
    @Published public var currentLanguage: LanguageCode = .tr
    @Published public var isRTL: Bool = false
    @Published public var locale: Locale = Locale(identifier: "tr_TR")
    
    public static let shared = LocalizationManager()
    
    public init() {
        let savedLang = UserDefaults.standard.string(forKey: "AppLanguage") ?? "tr"
        let code = LanguageCode(rawValue: savedLang) ?? .tr
        setLanguage(code)
    }
    
    public func setLanguage(_ code: LanguageCode) {
        // 1. Bundle Override
        Bundle.overriddenLanguage = code.rawValue
        
        // 2. State Update
        DispatchQueue.main.async {
            self.currentLanguage = code
            self.isRTL = code.isRTL
            self.locale = code.locale
            
            // 3. UI Reconstruction Trigger
            self.objectWillChange.send()
            
            // 4. Persistence
            var settings = PersistenceService.shared.loadSettings()
            settings.language = code
            PersistenceService.shared.saveSettings(settings)
            
            // 5. Global Notification (Opsiyonel)
            NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: code)
        }
    }
    
    public func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
