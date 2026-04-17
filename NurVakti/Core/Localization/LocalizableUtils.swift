import Foundation

public enum LocalizableSection: String {
    case result = "Result"
    case label = "Label"
}

public class LocalizableUtils {
    public static let shared = LocalizableUtils()
    
    public func getGeneralValue(section: LocalizableSection, key: String) -> String {
        // Mapping key to existing localization system
        // If the key is e.g. "Action.NoResponse.Message", we try to find it in Localizable.strings
        return LocalizationManager.shared.localizedString(key)
    }
}
