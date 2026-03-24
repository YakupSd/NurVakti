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
}
