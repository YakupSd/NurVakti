import SwiftUI

struct NurFontModifier: ViewModifier {
    @EnvironmentObject var persistService: PersistenceService
    let size: CGFloat
    let weight: Font.Weight
    let design: Font.Design
    
    func body(content: Content) -> some View {
        let scale = persistService.settings.fontSize.scaleFactor
        return content.font(.system(size: size * scale, weight: weight, design: design))
    }
}

extension View {
    func nurFont(_ size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        modifier(NurFontModifier(size: size, weight: weight, design: design))
    }
    
    /// Calculates a dynamic font size for Arabic text based on character count.
    func dynamicArabicFont(text: String, baseSize: CGFloat = 36) -> some View {
        let length = text.count
        var finalSize = baseSize
        
        if length > 300 {
            finalSize = baseSize * 0.5 // Very Small
        } else if length > 150 {
            finalSize = baseSize * 0.65 // Small
        } else if length > 70 {
            finalSize = baseSize * 0.8 // Medium
        }
        
        return self.font(.custom("Traditional Arabic", size: finalSize))
    }
    
    /// Calculates a dynamic font size for meaning/translation text based on character count.
    func dynamicMeaningFont(text: String, baseSize: CGFloat = 16) -> some View {
        let length = text.count
        var finalSize = baseSize
        
        if length > 400 {
            finalSize = baseSize * 0.8
        } else if length > 200 {
            finalSize = baseSize * 0.9
        }
        
        return self.nurFont(finalSize)
    }
}

public enum CustomFonts: String {
    case MavenBlack = "MavenPro-Black"
    case MavenBold = "MavenPro-Bold"
    case MavenExtraBold = "MavenPro-ExtraBold"
    case MavenMedium = "MavenPro-Medium"
    case MavenRegular = "MavenPro-Regular"
    case MavenSemiBold = "MavenPro-SemiBold"

    case InterBlack = "Inter-Black"
    case InterBlackItalic = "Inter-BlackItalic"
    case InterBold = "Inter-Bold"
    case InterBoldItalic = "Inter-BoldItalic"
    case InterExtraBold = "Inter-ExtraBold"
    case InterExtraBoldItalic = "Inter-ExtraBoldItalic"
    case InterExtraLight = "Inter-ExtraLight"
    case InterExtraLightItalic = "Inter-ExtraLightItalic"
    case InterItalic = "Inter-Italic"
    case InterLight = "Inter-Light"
    case InterLightItalic = "Inter-LightItalic"
    case InterMedium = "Inter-Medium"
    case InterMediumItalic = "Inter-MediumItalic"
    case InterRegular = "Inter-Regular"
    case InterSemiBold = "Inter-SemiBold"
    case InterSemiBoldItalic = "Inter-SemiBoldItalic"
    case InterThin = "Inter-Thin"
    case InterThinItalic = "Inter-ThinItalic"
    
}

extension Font {
    public static func setCustomFont(name: CustomFonts, size: CGFloat = 14) -> Font {
        if let uiFont = UIFont(name: name.rawValue, size: size) {
            return Font(uiFont)
        } else {
            return Font.system(size: size, weight: .bold)
        }
    }
}

extension UIFont {
    public static func setCustomUIFont(name: CustomFonts, size: CGFloat = 14) -> UIFont {
        return UIFont(name: name.rawValue, size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
}
