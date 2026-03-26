import SwiftUI

struct DynamicHomeBackground: View {
    let theme: PrayerTheme
    
    var body: some View {
        ZStack {
            // LAYER 1: The Constant Base (Deep Midnight)
            LinearGradient(
                colors: [
                    Color(hex: "0D1B2A"), // Deepest Navy
                    Color(hex: "000000")  // Pure Black bottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // LAYER 2: The Evolving Atmosphere (Subtle Tint)
            LinearGradient(
                colors: [
                    theme.topColor.opacity(0.6),
                    theme.bottomColor.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 3.0), value: theme)
            
            // LAYER 3: The Dynamic Aura (Moves with Sun/Moon)
            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height * 0.4
                let sunX = calculateX(progress: theme.sunPosition, width: width)
                let sunY = calculateY(progress: theme.sunPosition, width: width, height: height)
                
                RadialGradient(
                    colors: [
                        theme.auraColor,
                        theme.auraColor.opacity(0.1),
                        .clear
                    ],
                    center: UnitPoint(x: (sunX + width/2) / width, y: (sunY + 50) / geo.size.height),
                    startRadius: 0,
                    endRadius: 300
                )
                .blur(radius: 50)
                .animation(.easeInOut(duration: 3.0), value: theme.sunPosition)
            }
            .ignoresSafeArea()
            
            // LAYER 4: Stars (Context Sensitive - Now sharing AnimatedStarField)
            AnimatedStarFieldView(opacity: theme.starOpacity)
                .ignoresSafeArea()
            
            // LAYER 5: Clouds (Context Sensitive - Same as Simulation)
            CloudLayerView(opacity: theme.starOpacity > 0.5 ? 0.3 : 0.7, 
                           cloudColor: theme.starOpacity > 0.5 ? Color(hex: "#37474F") : .white)
                .ignoresSafeArea()
        }
    }
    
    private func calculateX(progress: Double, width: CGFloat) -> CGFloat {
        let radius = width / 2
        let angle = Double.pi * (1 - progress)
        return CGFloat(cos(angle)) * radius
    }
    
    private func calculateY(progress: Double, width: CGFloat, height: CGFloat) -> CGFloat {
        let radius = width / 2
        let angle = Double.pi * (1 - progress)
        return CGFloat(-sin(angle)) * radius + height
    }
}
