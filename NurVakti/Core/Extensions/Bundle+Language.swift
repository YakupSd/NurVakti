import Foundation

extension Bundle {
    private static var _overriddenLanguage: String?
    
    static var overriddenLanguage: String? {
        get { return _overriddenLanguage }
        set {
            _overriddenLanguage = newValue
            
            // Method Swizzling for localizedString
            if let newValue = newValue {
                object_setClass(Bundle.main, LanguageBundle.self)
            }
        }
    }
}

class LanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let lang = Bundle.overriddenLanguage,
              let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
