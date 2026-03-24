import SwiftUI

struct SunMoonArcView: View {
    let sunPosition: Double    // 0=ufuk sol, 0.5=tepe, 1=ufuk sağ
    let isMoon: Bool
    let theme: PrayerTheme
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height * 0.4
            
            ZStack {
                // Arc Path
                Path { path in
                    path.addArc(center: CGPoint(x: width / 2, y: height + 50),
                                radius: width / 2,
                                startAngle: .degrees(180),
                                endAngle: .degrees(0),
                                clockwise: false)
                }
                .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [5]))
                
                // Sun/Moon Icon with Halo
                ZStack {
                    if !isMoon {
                        Circle() // Halo for Sun
                            .fill(Color.yellow.opacity(0.15))
                            .frame(width: 80, height: 80)
                            .blur(radius: 20)
                    } else {
                        Circle() // Glow for Moon
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 60, height: 60)
                            .blur(radius: 15)
                    }
                    
                    Image(systemName: isMoon ? "moon.stars.fill" : "sun.max.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(isMoon ? .white : .nurGold)
                        .shadow(color: isMoon ? .white.opacity(0.8) : .nurGold.opacity(0.8), radius: 15)
                }
                .offset(x: calculateX(progress: sunPosition, width: width),
                        y: calculateY(progress: sunPosition, width: width, height: height))
                .animation(.easeInOut(duration: 3.0), value: sunPosition)
            }
        }
        .frame(height: 200)
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

#Preview {
    SunMoonArcView(sunPosition: 0.5, isMoon: false, theme: .dhuhrTheme)
        .padding()
        .background(Color.blue)
}
