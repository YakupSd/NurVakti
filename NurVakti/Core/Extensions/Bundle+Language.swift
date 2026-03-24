import Foundation
import ObjectiveC

private var bundleKey: UInt8 = 0

final class BundleEx: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        return (objc_getAssociatedObject(self, &bundleKey) as? Bundle)?.localizedString(forKey: key, value: value, table: tableName) ?? super.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static var overriddenLanguage: String? {
        get { UserDefaults.standard.string(forKey: "AppLanguage") }
        set {
            UserDefaults.standard.set(newValue, forKey: "AppLanguage")
            guard let language = newValue,
                  let path = Bundle.main.path(forResource: language, ofType: "lproj"),
                  let bundle = Bundle(path: path) else {
                objc_setAssociatedObject(Bundle.main, &bundleKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return
            }
            
            object_setClass(Bundle.main, BundleEx.self)
            objc_setAssociatedObject(Bundle.main, &bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
