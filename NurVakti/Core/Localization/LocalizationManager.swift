import SwiftUI
import Combine

final class LocalizationManager: ObservableObject {
    @Published var currentLanguage: LanguageCode = .tr
    @Published var isRTL: Bool = false
    @Published var locale: Locale = Locale(identifier: "tr_TR")
    
    static let shared = LocalizationManager()
    
    private init() {
        let savedLang = UserDefaults.standard.string(forKey: "AppLanguage") ?? "tr"
        let code = LanguageCode(rawValue: savedLang) ?? .tr
        setLanguage(code)
    }
    
    func setLanguage(_ code: LanguageCode) {
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
    
    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
