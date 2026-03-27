import SwiftUI

struct CelestialBodyView: View {
    let hour: Double
    let isSun: Bool
    
    var body: some View {
        GeometryReader { geo in
            let pos = calculatePosition(in: geo.size)
            let appearance = calculateAppearance()
            
            if appearance.opacity > 0 {
                ZStack {
                    // Glow / Halo (Enhanced for premium look)
                    Circle()
                        .fill(appearance.color.opacity(isSun ? 0.4 : 0.2))
                        .frame(width: appearance.size * (isSun ? 3.0 : 2.5), 
                               height: appearance.size * (isSun ? 3.0 : 2.5))
                        .blur(radius: appearance.size * 1.2)
                    
                    // Main Body: Now using Premium AI-generated Assets
                    Image(isSun ? "premium_sun" : "premium_moon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: appearance.size, height: appearance.size)
                        .shadow(color: appearance.color.opacity(0.8), radius: 20)
                }
                .position(pos)
                .opacity(appearance.opacity)
            }
        }
    }

    private func calculatePosition(in size: CGSize) -> CGPoint {
        // Map hour to 0..1 for active period
        // Sun: 6:00 to 18:00
        // Moon: 18:00 to 6:00
        var activeProgress: Double = 0
        let start = isSun ? 6.0 : 18.0
        let end = isSun ? 19.0 : 7.0 // slightly longer for overlap
        
        var h = hour
        if !isSun {
            if h < 12 { h += 24 }
        }
        
        let duration = end > start ? (end - start) : (end + 24 - start)
        activeProgress = (h - start) / duration
        
        // Parabolic arc
        let x = CGFloat(activeProgress) * size.width
        let peakY = size.height * 0.2
        let baseY = size.height * 0.8
        
        // y = a(x-h)^2 + k where (h,k) is apex
        let midX = size.width / 2
        let a = (baseY - peakY) / pow(midX, 2)
        let y = a * pow(x - midX, 2) + peakY
        
        return CGPoint(x: x, y: y)
    }

    private func calculateAppearance() -> (size: CGFloat, color: Color, opacity: Double) {
        let (current, _, progress) = SkyPhase.current(for: hour)
        
        if isSun {
            // Sun visibility: Dawn to Sunset
            let visiblePhases: [SkyPhase] = [.dawn, .sunrise, .morning, .midday, .afternoon, .lateAfternoon, .sunset]
            let isVisible = visiblePhases.contains(current)
            
            if !isVisible { return (30, .white, 0) }
            
            // Refraction effect near horizon
            let isNearHorizon = [SkyPhase.dawn, .sunrise, .lateAfternoon, .sunset].contains(current)
            let size: CGFloat = isNearHorizon ? 45 : 35
            let color: Color = isNearHorizon ? Color(hex: "#FFA726") : .white
            
            return (size, color, 1.0)
        } else {
            // Moon visibility: Dusk to Dawn
            let visiblePhases: [SkyPhase] = [.dusk, .earlyNight, .night, .deepNight, .preDawn]
            let isVisible = visiblePhases.contains(current)
            
            if !isVisible { return (25, .white, 0) }
            
            return (25, Color(hex: "#F5F5F5"), 1.0)
        }
    }
}
