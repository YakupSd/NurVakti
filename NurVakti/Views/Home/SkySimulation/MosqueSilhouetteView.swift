import SwiftUI

/// Majestic multi-layered Islamic Mosque & Minaret Skyline with authentic architectural details and night window illumination.
struct MosqueSilhouetteView: View {
    let phase: SkyPhase
    let progress: Double
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            let color = calculateColor()
            let opacity = calculateOpacity()
            let isNight = isNightPhase()
            
            ZStack(alignment: .bottom) {
                // 1. Back Layer: Distant Hills & Minor Domes
                distantSkylinePath(width: w, height: h)
                    .fill(color.opacity(opacity * 0.45))
                
                // 2. Main Foreground Layer: Grand Imperial Mosque Complex
                grandMosquePath(width: w, height: h)
                    .fill(color.opacity(opacity))
                
                // 3. Night Lighting (Warm glowing windows & minaret balconies during evening/night)
                if isNight {
                    nightLightsPath(width: w, height: h)
                        .fill(Color(hex: "#FFE49E").opacity(calculateLightOpacity()))
                        .shadow(color: Color(hex: "#FFB830").opacity(0.8), radius: 4)
                }
            }
            .frame(width: w, height: h)
        }
    }
    
    // MARK: - 1. Distant Skyline (Back Layer)
    private func distantSkylinePath(width w: CGFloat, height h: CGFloat) -> Path {
        Path { p in
            let baseY = h * 0.88
            
            p.move(to: CGPoint(x: 0, y: h))
            p.addLine(to: CGPoint(x: 0, y: baseY))
            
            // Distant soft rolling hill on left
            p.addQuadCurve(
                to: CGPoint(x: w * 0.22, y: baseY - 15),
                control: CGPoint(x: w * 0.10, y: baseY - 25)
            )
            
            // Distant small minaret left
            p.addLine(to: CGPoint(x: w * 0.23, y: baseY - 15))
            p.addLine(to: CGPoint(x: w * 0.232, y: baseY - 42))
            p.addLine(to: CGPoint(x: w * 0.235, y: baseY - 15))
            
            // Distant small dome
            p.addQuadCurve(
                to: CGPoint(x: w * 0.32, y: baseY - 15),
                control: CGPoint(x: w * 0.275, y: baseY - 35)
            )
            
            // Mid ground bridge/wall
            p.addLine(to: CGPoint(x: w * 0.65, y: baseY - 10))
            
            // Distant small minaret right
            p.addLine(to: CGPoint(x: w * 0.82, y: baseY - 10))
            p.addLine(to: CGPoint(x: w * 0.822, y: baseY - 38))
            p.addLine(to: CGPoint(x: w * 0.825, y: baseY - 10))
            
            // Distant hill right
            p.addQuadCurve(
                to: CGPoint(x: w, y: baseY),
                control: CGPoint(x: w * 0.92, y: baseY - 20)
            )
            
            p.addLine(to: CGPoint(x: w, y: h))
            p.closeSubpath()
        }
    }
    
    // MARK: - 2. Grand Mosque Foreground (Detailed Vector Silhouette)
    private func grandMosquePath(width w: CGFloat, height h: CGFloat) -> Path {
        Path { p in
            let baseY = h * 0.94
            
            p.move(to: CGPoint(x: 0, y: h))
            p.addLine(to: CGPoint(x: 0, y: baseY))
            
            // Left urban skyline
            p.addLine(to: CGPoint(x: w * 0.08, y: baseY))
            p.addLine(to: CGPoint(x: w * 0.08, y: baseY - 12))
            p.addLine(to: CGPoint(x: w * 0.13, y: baseY - 12))
            p.addLine(to: CGPoint(x: w * 0.13, y: baseY - 22))
            p.addLine(to: CGPoint(x: w * 0.18, y: baseY - 22))
            p.addLine(to: CGPoint(x: w * 0.18, y: baseY - 8))
            p.addLine(to: CGPoint(x: w * 0.24, y: baseY - 8))
            
            // Left Outer Minaret
            let m1X = w * 0.26
            p.addLine(to: CGPoint(x: m1X, y: baseY))
            drawMinaret(in: &p, baseX: m1X, baseY: baseY, height: 68, width: 4.5)
            
            // Cascading Left Semi-Dome
            let leftDomeStart = w * 0.28
            let leftDomeEnd = w * 0.38
            p.addLine(to: CGPoint(x: leftDomeStart, y: baseY))
            p.addLine(to: CGPoint(x: leftDomeStart, y: baseY - 18))
            p.addQuadCurve(
                to: CGPoint(x: leftDomeEnd, y: baseY - 26),
                control: CGPoint(x: (leftDomeStart + leftDomeEnd) / 2, y: baseY - 44)
            )
            
            // Left Inner Tall Minaret
            let m2X = w * 0.385
            p.addLine(to: CGPoint(x: m2X, y: baseY))
            drawMinaret(in: &p, baseX: m2X, baseY: baseY, height: 86, width: 5.5)
            
            // GRAND CENTRAL DOME
            let centerDomeStart = w * 0.40
            let centerDomeEnd = w * 0.60
            let apexX = w * 0.50
            let domeBaseY = baseY - 28
            
            p.addLine(to: CGPoint(x: centerDomeStart, y: baseY))
            p.addLine(to: CGPoint(x: centerDomeStart, y: domeBaseY))
            
            // Authentic Ottoman Dome Arch
            p.addCurve(
                to: CGPoint(x: apexX, y: baseY - 66),
                control1: CGPoint(x: centerDomeStart + w * 0.02, y: domeBaseY - 26),
                control2: CGPoint(x: apexX - w * 0.04, y: baseY - 66)
            )
            // Crescent finial (alem) on top
            p.addLine(to: CGPoint(x: apexX, y: baseY - 74))
            p.addLine(to: CGPoint(x: apexX, y: baseY - 66))
            
            p.addCurve(
                to: CGPoint(x: centerDomeEnd, y: domeBaseY),
                control1: CGPoint(x: apexX + w * 0.04, y: baseY - 66),
                control2: CGPoint(x: centerDomeEnd - w * 0.02, y: domeBaseY - 26)
            )
            p.addLine(to: CGPoint(x: centerDomeEnd, y: baseY))
            
            // Right Inner Tall Minaret
            let m3X = w * 0.61
            drawMinaret(in: &p, baseX: m3X, baseY: baseY, height: 86, width: 5.5)
            
            // Cascading Right Semi-Dome
            let rightDomeStart = w * 0.62
            let rightDomeEnd = w * 0.72
            p.addLine(to: CGPoint(x: rightDomeStart, y: baseY))
            p.addLine(to: CGPoint(x: rightDomeStart, y: baseY - 26))
            p.addQuadCurve(
                to: CGPoint(x: rightDomeEnd, y: baseY - 18),
                control: CGPoint(x: (rightDomeStart + rightDomeEnd) / 2, y: baseY - 44)
            )
            p.addLine(to: CGPoint(x: rightDomeEnd, y: baseY))
            
            // Right Outer Minaret
            let m4X = w * 0.74
            drawMinaret(in: &p, baseX: m4X, baseY: baseY, height: 68, width: 4.5)
            
            // Right urban skyline
            p.addLine(to: CGPoint(x: w * 0.76, y: baseY))
            p.addLine(to: CGPoint(x: w * 0.76, y: baseY - 10))
            p.addLine(to: CGPoint(x: w * 0.82, y: baseY - 10))
            p.addLine(to: CGPoint(x: w * 0.82, y: baseY - 24))
            p.addLine(to: CGPoint(x: w * 0.88, y: baseY - 24))
            p.addLine(to: CGPoint(x: w * 0.88, y: baseY - 14))
            p.addLine(to: CGPoint(x: w * 0.94, y: baseY - 14))
            p.addLine(to: CGPoint(x: w * 0.94, y: baseY - 6))
            p.addLine(to: CGPoint(x: w, y: baseY - 6))
            p.addLine(to: CGPoint(x: w, y: baseY))
            p.addLine(to: CGPoint(x: w, y: h))
            p.closeSubpath()
        }
    }
    
    // Helper to draw a slender Ottoman minaret with balconies (şerefe) and pointed cone (külah)
    private func drawMinaret(in p: inout Path, baseX: CGFloat, baseY: CGFloat, height: CGFloat, width: CGFloat) {
        let halfW = width / 2
        let topY = baseY - height
        let balcony1Y = baseY - height * 0.45
        let balcony2Y = baseY - height * 0.75
        
        // Base shaft up to first balcony
        p.addLine(to: CGPoint(x: baseX - halfW, y: baseY))
        p.addLine(to: CGPoint(x: baseX - halfW, y: balcony1Y))
        
        // Balcony 1 (Şerefe)
        p.addLine(to: CGPoint(x: baseX - halfW - 2.5, y: balcony1Y))
        p.addLine(to: CGPoint(x: baseX - halfW - 2.5, y: balcony1Y - 3))
        p.addLine(to: CGPoint(x: baseX - halfW * 0.9, y: balcony1Y - 3))
        
        // Shaft to second balcony
        p.addLine(to: CGPoint(x: baseX - halfW * 0.85, y: balcony2Y))
        
        // Balcony 2 (Şerefe)
        p.addLine(to: CGPoint(x: baseX - halfW - 2, y: balcony2Y))
        p.addLine(to: CGPoint(x: baseX - halfW - 2, y: balcony2Y - 2.5))
        p.addLine(to: CGPoint(x: baseX - halfW * 0.8, y: balcony2Y - 2.5))
        
        // Upper shaft to cone base
        p.addLine(to: CGPoint(x: baseX - halfW * 0.7, y: topY + 12))
        
        // Pointed Külah (Cone) & Crescent Alem
        p.addLine(to: CGPoint(x: baseX, y: topY))
        p.addLine(to: CGPoint(x: baseX, y: topY - 5)) // Alem tip
        p.addLine(to: CGPoint(x: baseX, y: topY))
        p.addLine(to: CGPoint(x: baseX + halfW * 0.7, y: topY + 12))
        
        // Right side balcony 2
        p.addLine(to: CGPoint(x: baseX + halfW * 0.8, y: balcony2Y - 2.5))
        p.addLine(to: CGPoint(x: baseX + halfW + 2, y: balcony2Y - 2.5))
        p.addLine(to: CGPoint(x: baseX + halfW + 2, y: balcony2Y))
        p.addLine(to: CGPoint(x: baseX + halfW * 0.85, y: balcony2Y))
        
        // Right side balcony 1
        p.addLine(to: CGPoint(x: baseX + halfW * 0.9, y: balcony1Y - 3))
        p.addLine(to: CGPoint(x: baseX + halfW + 2.5, y: balcony1Y - 3))
        p.addLine(to: CGPoint(x: baseX + halfW + 2.5, y: balcony1Y))
        p.addLine(to: CGPoint(x: baseX + halfW, y: balcony1Y))
        
        // Base down
        p.addLine(to: CGPoint(x: baseX + halfW, y: baseY))
    }
    
    // MARK: - 3. Night Lights (Glowing mosque windows & minaret kandil lights)
    private func nightLightsPath(width w: CGFloat, height h: CGFloat) -> Path {
        Path { p in
            let baseY = h * 0.94
            
            // Windows under central dome
            let domeBaseY = baseY - 24
            let winY = domeBaseY
            let winWidth: CGFloat = 2.5
            let winHeight: CGFloat = 5.0
            
            for i in -3...3 {
                let wx = w * 0.50 + CGFloat(i) * 9.0
                p.addRoundedRect(
                    in: CGRect(x: wx - winWidth/2, y: winY, width: winWidth, height: winHeight),
                    cornerSize: CGSize(width: 1.5, height: 1.5)
                )
            }
            
            // Windows in lower facade
            let lowerY = baseY - 12
            for i in -4...4 {
                let wx = w * 0.50 + CGFloat(i) * 8.0
                p.addRoundedRect(
                    in: CGRect(x: wx - 1.5, y: lowerY, width: 3.0, height: 4.5),
                    cornerSize: CGSize(width: 1, height: 1)
                )
            }
            
            // Kandil lights on minaret balconies
            let minarets: [(x: CGFloat, h: CGFloat)] = [
                (w * 0.26, 68),
                (w * 0.385, 86),
                (w * 0.61, 86),
                (w * 0.74, 68)
            ]
            
            for m in minarets {
                let b1Y = baseY - m.h * 0.45 - 1.5
                let b2Y = baseY - m.h * 0.75 - 1.5
                
                p.addEllipse(in: CGRect(x: m.x - 2, y: b1Y, width: 4, height: 2))
                p.addEllipse(in: CGRect(x: m.x - 1.5, y: b2Y, width: 3, height: 2))
            }
        }
    }
    
    // MARK: - Color & Opacity Logic
    private func calculateColor() -> Color {
        switch phase {
        case .sunset:
            return Color(hex: "#1A0A26")
        case .dusk:
            return Color(hex: "#12061E")
        case .night, .deepNight:
            return Color(hex: "#030814")
        case .preDawn:
            return Color(hex: "#091222")
        case .dawn, .sunrise:
            return Color(hex: "#1A1A32")
        case .lateAfternoon:
            return Color(hex: "#1E2A44")
        default:
            return Color(hex: "#182A48")
        }
    }
    
    private func calculateOpacity() -> Double {
        switch phase {
        case .sunset:
            return 0.55 + progress * 0.25
        case .dusk:
            return 0.80
        case .night, .deepNight:
            return 0.75
        case .earlyNight:
            return 0.80
        case .preDawn:
            return 0.65 - progress * 0.2
        case .dawn:
            return 0.45 - progress * 0.15
        case .sunrise:
            return 0.30 - progress * 0.1
        case .morning:
            return 0.20
        case .midday:
            return 0.22
        case .afternoon:
            return 0.24
        case .lateAfternoon:
            return 0.28 + progress * 0.2
        }
    }
    
    private func isNightPhase() -> Bool {
        switch phase {
        case .sunset, .dusk, .earlyNight, .night, .deepNight, .preDawn:
            return true
        default:
            return false
        }
    }
    
    private func calculateLightOpacity() -> Double {
        switch phase {
        case .sunset:
            return 0.2 + progress * 0.4
        case .dusk, .earlyNight, .night, .deepNight:
            return 0.95
        case .preDawn:
            return 0.8 - progress * 0.4
        default:
            return 0
        }
    }
}
