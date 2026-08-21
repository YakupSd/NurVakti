import SwiftUI
import UIKit

struct SkyGradient {
    let top: Color
    let horizon: Color
}

struct SkyColorPalette {
    static func gradient(for phase: SkyPhase) -> SkyGradient {
        switch phase {
        case .deepNight:
            return SkyGradient(top: Color(hex: "#010816"), horizon: Color(hex: "#051226"))
        case .preDawn:
            return SkyGradient(top: Color(hex: "#0A1628"), horizon: Color(hex: "#2A3A5A"))
        case .dawn:
            return SkyGradient(top: Color(hex: "#1E3456"), horizon: Color(hex: "#E8824C"))
        case .sunrise:
            return SkyGradient(top: Color(hex: "#3A8AC4"), horizon: Color(hex: "#FFBA6B"))
        case .morning:
            return SkyGradient(top: Color(hex: "#4BABF4"), horizon: Color(hex: "#C8E4FF"))
        case .midday:
            return SkyGradient(top: Color(hex: "#3DA5F5"), horizon: Color(hex: "#B8DCFF"))
        case .afternoon:
            return SkyGradient(top: Color(hex: "#4AABF0"), horizon: Color(hex: "#E8D4A8"))
        case .lateAfternoon:
            return SkyGradient(top: Color(hex: "#5070B8"), horizon: Color(hex: "#F0A850"))
        case .sunset:
            return SkyGradient(top: Color(hex: "#2A3870"), horizon: Color(hex: "#E84820"))
        case .dusk:
            return SkyGradient(top: Color(hex: "#161850"), horizon: Color(hex: "#5A1878"))
        case .earlyNight:
            return SkyGradient(top: Color(hex: "#0D1117"), horizon: Color(hex: "#161850"))
        case .night:
            return SkyGradient(top: Color(hex: "#02060C"), horizon: Color(hex: "#0C1425"))
        }
    }

    static func interpolate(from: SkyPhase, to: SkyPhase, progress: Double) -> SkyGradient {
        let g1 = gradient(for: from)
        let g2 = gradient(for: to)
        
        return SkyGradient(
            top: g1.top.interpolate(to: g2.top, progress: progress),
            horizon: g1.horizon.interpolate(to: g2.horizon, progress: progress)
        )
    }
}

extension Color {
    func interpolate(to color: Color, progress: Double) -> Color {
        let components1 = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let components2 = UIColor(color).cgColor.components ?? [0, 0, 0, 1]
        
        let r = components1[0] + (components2[0] - components1[0]) * CGFloat(progress)
        let g = components1[1] + (components2[1] - components1[1]) * CGFloat(progress)
        let b = components1[2] + (components2[2] - components1[2]) * CGFloat(progress)
        let a = components1[3] + (components2[3] - components1[3]) * CGFloat(progress)
        
        return Color(.sRGB, red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
    }
}
