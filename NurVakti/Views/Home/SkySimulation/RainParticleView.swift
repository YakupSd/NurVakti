import SwiftUI

// MARK: - High Performance Canvas Rain Particle System
struct RainParticleView: View {
    let isHeavy: Bool
    
    @State private var drops: [RainDrop] = []
    
    struct RainDrop: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let length: CGFloat
        let speed: CGFloat
        let opacity: Double
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let count = drops.count
                
                for i in 0..<count {
                    let drop = drops[i]
                    
                    // Rain falls down and slightly diagonally (wind effect)
                    let currentY = (drop.y + CGFloat(time) * drop.speed).truncatingRemainder(dividingBy: 1.2) - 0.1
                    let currentX = drop.x - (currentY * 0.15) // Slight diagonal slant
                    
                    let drawX = currentX * size.width
                    let drawY = currentY * size.height
                    
                    var ctx = context
                    ctx.opacity = drop.opacity
                    
                    let path = Path { p in
                        p.move(to: CGPoint(x: drawX, y: drawY))
                        p.addLine(to: CGPoint(x: drawX - 3, y: drawY + drop.length))
                    }
                    
                    ctx.stroke(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.7)]),
                            startPoint: CGPoint(x: drawX, y: drawY),
                            endPoint: CGPoint(x: drawX - 3, y: drawY + drop.length)
                        ),
                        lineWidth: isHeavy ? 1.5 : 1.0
                    )
                }
            }
        }
        .onAppear {
            if drops.isEmpty {
                generateDrops()
            }
        }
    }
    
    private func generateDrops() {
        var newDrops: [RainDrop] = []
        let dropCount = isHeavy ? 110 : 60
        
        for _ in 0..<dropCount {
            newDrops.append(RainDrop(
                x: CGFloat.random(in: -0.2...1.2),
                y: CGFloat.random(in: 0...1),
                length: CGFloat.random(in: isHeavy ? 18...32 : 12...22),
                speed: CGFloat.random(in: isHeavy ? 0.9...1.6 : 0.6...1.1),
                opacity: Double.random(in: 0.25...0.65)
            ))
        }
        drops = newDrops
    }
}
