import SwiftUI

struct AnimatedStarFieldView: View {
    let opacity: Double // Night = 1.0, Day = 0.0
    
    // Seeded random positions to keep stars consistent
    @State private var stars: [Star] = []
    
    struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat // 0.0 to 1.0
        let y: CGFloat // 0.0 to 1.0
        let size: CGFloat
        let twinkleSpeed: Double
        let twinkleOffset: Double
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                // 1. Regular Stars
                for star in stars {
                    let x = star.x * size.width
                    let y = star.y * size.height
                    
                    // Twinkle effect (opacity oscillation)
                    let twinkle = 0.7 + 0.3 * sin(time * star.twinkleSpeed + star.twinkleOffset)
                    
                    var starContext = context
                    starContext.opacity = opacity * twinkle
                    
                    let path = Path(ellipseIn: CGRect(x: x, y: y, width: star.size, height: star.size))
                    starContext.fill(path, with: .color(.white))
                }
                
                // 2. Shooting Star (Dynamic)
                drawShootingStar(in: context, size: size, time: time)
            }
        }
        .onAppear {
            if stars.isEmpty {
                generateStars()
            }
        }
    }
    
    private func drawShootingStar(in context: GraphicsContext, size: CGSize, time: Double) {
        guard opacity > 0.8 else { return } // Only at deep night
        
        // Use time to trigger a burst every ~15 seconds
        let cycle = 15.0
        let phase = time.truncatingRemainder(dividingBy: cycle)
        let duration = 0.8
        
        if phase < duration {
            let progress = phase / duration
            let startX = size.width * 0.8
            let startY = size.height * 0.1
            let dx = -size.width * 0.4 * CGFloat(progress)
            let dy = size.height * 0.2 * CGFloat(progress)
            
            var ctx = context
            ctx.opacity = opacity * (1.0 - progress)
            
            let path = Path { p in
                p.move(to: CGPoint(x: startX + dx, y: startY + dy))
                p.addLine(to: CGPoint(x: startX + dx + 40, y: startY + dy - 20))
            }
            ctx.stroke(path, with: .linearGradient(
                Gradient(colors: [.white, .clear]),
                startPoint: CGPoint(x: startX + dx, y: startY + dy),
                endPoint: CGPoint(x: startX + dx + 40, y: startY + dy - 20)
            ), lineWidth: 2)
        }
    }

    private func generateStars() {
        var newStars: [Star] = []
        // Use a fixed seed-like approach for consistency (not perfect but enough for this)
        for i in 0..<100 {
            let x = CGFloat.random(in: 0...1)
            let y = CGFloat.random(in: 0...0.7) // Mostly in upper sky
            let size = CGFloat.random(in: 1...2.5)
            let speed = Double.random(in: 1...3)
            let offset = Double.random(in: 0...Double.pi * 2)
            newStars.append(Star(x: x, y: y, size: size, twinkleSpeed: speed, twinkleOffset: offset))
        }
        stars = newStars
    }
}
