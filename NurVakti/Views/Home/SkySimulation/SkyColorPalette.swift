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
            return SkyGradient(top: Color(hex: "#051226"), horizon: Color(hex: "#1A2A44"))
        case .dawn:
            return SkyGradient(top: Color(hex: "#1A2A44"), horizon: Color(hex: "#FF6B35"))
        case .sunrise:
            return SkyGradient(top: Color(hex: "#1B6CA8"), horizon: Color(hex: "#FFA040"))
        case .morning:
            return SkyGradient(top: Color(hex: "#4099FF"), horizon: Color(hex: "#AADDFF"))
        case .midday:
            return SkyGradient(top: Color(hex: "#1E88E5"), horizon: Color(hex: "#90CAF9"))
        case .afternoon:
            return SkyGradient(top: Color(hex: "#42A5F5"), horizon: Color(hex: "#FFCC80"))
        case .lateAfternoon:
            return SkyGradient(top: Color(hex: "#5C6BC0"), horizon: Color(hex: "#FFAB40"))
        case .sunset:
            return SkyGradient(top: Color(hex: "#283593"), horizon: Color(hex: "#FF3D00"))
        case .dusk:
            return SkyGradient(top: Color(hex: "#1A237E"), horizon: Color(hex: "#6A1B9A"))
        case .earlyNight:
            return SkyGradient(top: Color(hex: "#0D1117"), horizon: Color(hex: "#1A237E"))
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
