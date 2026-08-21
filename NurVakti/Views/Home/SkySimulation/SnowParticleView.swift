import SwiftUI

// MARK: - High Performance Canvas Snow Particle System
struct SnowParticleView: View {
    let isHeavy: Bool
    
    @State private var flakes: [SnowFlake] = []
    
    struct SnowFlake: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let speed: CGFloat
        let swaySpeed: Double
        let swayOffset: Double
        let opacity: Double
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let count = flakes.count
                
                for i in 0..<count {
                    let flake = flakes[i]
                    
                    // Snow drifts down with organic sinusoidal sway
                    let currentY = (flake.y + CGFloat(time) * flake.speed).truncatingRemainder(dividingBy: 1.2) - 0.1
                    let sway = sin(time * flake.swaySpeed + flake.swayOffset) * 0.04
                    let currentX = flake.x + CGFloat(sway)
                    
                    let drawX = currentX * size.width
                    let drawY = currentY * size.height
                    
                    var ctx = context
                    ctx.opacity = flake.opacity
                    
                    let rect = CGRect(
                        x: drawX - flake.size / 2,
                        y: drawY - flake.size / 2,
                        width: flake.size,
                        height: flake.size
                    )
                    
                    ctx.fill(Path(ellipseIn: rect), with: .color(.white))
                }
            }
        }
        .onAppear {
            if flakes.isEmpty {
                generateFlakes()
            }
        }
    }
    
    private func generateFlakes() {
        var newFlakes: [SnowFlake] = []
        let flakeCount = isHeavy ? 90 : 45
        
        for _ in 0..<flakeCount {
            newFlakes.append(SnowFlake(
                x: CGFloat.random(in: -0.1...1.1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 2.0...5.5),
                speed: CGFloat.random(in: 0.08...0.22),
                swaySpeed: Double.random(in: 1.5...3.0),
                swayOffset: Double.random(in: 0...Double.pi * 2),
                opacity: Double.random(in: 0.4...0.9)
            ))
        }
        flakes = newFlakes
    }
}
