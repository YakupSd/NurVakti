import SwiftUI

struct CelestialBodyView: View {
    let hour: Double
    let isSun: Bool
    var hijriDay: Int = Calendar.current.component(.day, from: Date()) // Approximate lunar day
    
    var body: some View {
        GeometryReader { geo in
            let pos = calculatePosition(in: geo.size)
            let appearance = calculateAppearance()
            
            if appearance.opacity > 0 {
                ZStack {
                    // Glow / Halo
                    Circle()
                        .fill(appearance.color.opacity(isSun ? 0.4 : 0.2))
                        .frame(width: appearance.size * (isSun ? 3.0 : 2.5), 
                               height: appearance.size * (isSun ? 3.0 : 2.5))
                        .blur(radius: appearance.size * 1.2)
                    
                    if isSun {
                        // Sun: Premium Asset
                        Image("premium_sun")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: appearance.size, height: appearance.size)
                            .shadow(color: appearance.color.opacity(0.8), radius: 20)
                    } else {
                        // Moon: Premium Asset with Lunar Phase Masking
                        ZStack {
                            Image("premium_moon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: appearance.size, height: appearance.size)
                                .shadow(color: appearance.color.opacity(0.6), radius: 15)
                            
                            // Lunar Phase Shadow Overlay
                            MoonPhaseOverlay(lunarDay: hijriDay)
                                .frame(width: appearance.size, height: appearance.size)
                        }
                    }
                }
                .position(pos)
                .opacity(appearance.opacity)
            }
        }
    }

    private func calculatePosition(in size: CGSize) -> CGPoint {
        var activeProgress: Double = 0
        let start = isSun ? 6.0 : 18.0
        let end = isSun ? 19.0 : 7.0
        
        var h = hour
        if !isSun {
            if h < 12 { h += 24 }
        }
        
        let duration = end > start ? (end - start) : (end + 24 - start)
        activeProgress = (h - start) / duration
        
        // Parabolic arc
        let x = CGFloat(activeProgress) * size.width
        let peakY = size.height * 0.18
        let baseY = size.height * 0.82
        
        let midX = size.width / 2
        let a = (baseY - peakY) / pow(midX, 2)
        let y = a * pow(x - midX, 2) + peakY
        
        return CGPoint(x: x, y: y)
    }

    private func calculateAppearance() -> (size: CGFloat, color: Color, opacity: Double) {
        let (current, _, _) = SkyPhase.current(for: hour)
        
        if isSun {
            let visiblePhases: [SkyPhase] = [.dawn, .sunrise, .morning, .midday, .afternoon, .lateAfternoon, .sunset]
            let isVisible = visiblePhases.contains(current)
            
            if !isVisible { return (30, .white, 0) }
            
            let isNearHorizon = [SkyPhase.dawn, .sunrise, .lateAfternoon, .sunset].contains(current)
            let size: CGFloat = isNearHorizon ? 48 : 38
            let color: Color = isNearHorizon ? Color(hex: "#FFA726") : .white
            
            return (size, color, 1.0)
        } else {
            let visiblePhases: [SkyPhase] = [.dusk, .earlyNight, .night, .deepNight, .preDawn]
            let isVisible = visiblePhases.contains(current)
            
            if !isVisible { return (25, .white, 0) }
            
            return (30, Color(hex: "#F0EEDD"), 1.0)
        }
    }
}

// MARK: - Moon Phase Overlay (Islamic Lunar Calendar)
struct MoonPhaseOverlay: View {
    let lunarDay: Int // 1-30 (Hijri day of month)
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            
            // Calculate illumination: 0 = new moon, 1 = full moon
            let illumination = calculateIllumination()
            
            // Only draw shadow if not full moon
            if illumination < 0.95 {
                Canvas { context, canvasSize in
                    // Shadow mask over the moon
                    let shadowOffsetX = (1.0 - illumination * 2) * radius
                    
                    context.drawLayer { ctx in
                        // Dark side of moon
                        let shadowPath = Path { p in
                            // Draw a clipping ellipse to create crescent effect
                            p.addEllipse(in: CGRect(
                                x: center.x - radius + shadowOffsetX,
                                y: center.y - radius,
                                width: radius * 2,
                                height: radius * 2
                            ))
                        }
                        
                        // Only clip and fill the shadow area
                        ctx.clip(to: Path(ellipseIn: CGRect(
                            x: 0, y: 0,
                            width: canvasSize.width,
                            height: canvasSize.height
                        )))
                        
                        if illumination < 0.5 {
                            // Waxing: shadow on the left
                            ctx.fill(shadowPath, with: .color(Color.black.opacity(0.7)))
                        }
                    }
                }
            }
        }
        .clipShape(Circle())
    }
    
    private func calculateIllumination() -> Double {
        // Simplified lunar illumination based on hijri day
        // Day 1 = new moon (0%), Day 15 = full moon (100%), Day 30 = new moon (0%)
        let normalizedDay = Double(((lunarDay - 1) % 30))
        if normalizedDay <= 15 {
            return normalizedDay / 15.0
        } else {
            return (30.0 - normalizedDay) / 15.0
        }
    }
}
