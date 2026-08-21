import SwiftUI

struct AnimatedStarFieldView: View {
    let opacity: Double
    
    @State private var stars: [Star] = []
    @State private var shootingStarSeed: Double = Double.random(in: 10...25)
    
    struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let twinkleSpeed: Double
        let twinkleOffset: Double
        let brightness: CGFloat // 0.5 to 1.0
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                // 1. Regular Stars with varied brightness
                for star in stars {
                    let x = star.x * size.width
                    let y = star.y * size.height
                    
                    // Twinkle effect
                    let twinkle = 0.6 + 0.4 * sin(time * star.twinkleSpeed + star.twinkleOffset)
                    
                    var starContext = context
                    starContext.opacity = opacity * twinkle * Double(star.brightness)
                    
                    // Bright stars get a subtle glow
                    if star.size > 2.0 {
                        let glowPath = Path(ellipseIn: CGRect(
                            x: x - star.size, y: y - star.size,
                            width: star.size * 4, height: star.size * 4
                        ))
                        var glowCtx = context
                        glowCtx.opacity = opacity * twinkle * 0.15
                        glowCtx.addFilter(.blur(radius: 3))
                        glowCtx.fill(glowPath, with: .color(.white))
                    }
                    
                    let path = Path(ellipseIn: CGRect(x: x, y: y, width: star.size, height: star.size))
                    starContext.fill(path, with: .color(.white))
                }
                
                // 2. Shooting Stars (randomized)
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
        guard opacity > 0.7 else { return }
        
        // Randomized cycle between 12-25 seconds
        let cycle = shootingStarSeed
        let phase = time.truncatingRemainder(dividingBy: cycle)
        let duration = 1.0
        
        if phase < duration {
            let progress = phase / duration
            
            // Randomized angle & position using time seed
            let seed = sin(time / cycle) * 1000
            let angleRad = (0.4 + abs(sin(seed)) * 0.3) // 23-40 degrees
            let startXNorm = 0.3 + abs(cos(seed)) * 0.5
            let startYNorm = 0.05 + abs(sin(seed * 2)) * 0.15
            
            let startX = size.width * CGFloat(startXNorm)
            let startY = size.height * CGFloat(startYNorm)
            let trailLength = CGFloat(60 + abs(sin(seed)) * 40)
            
            let dx = -trailLength * CGFloat(progress) * 3
            let dy = trailLength * CGFloat(progress) * CGFloat(angleRad) * 2
            
            var ctx = context
            ctx.opacity = opacity * (1.0 - progress) * 0.9
            
            let headX = startX + dx
            let headY = startY + dy
            let tailX = headX + trailLength * 0.6
            let tailY = headY - trailLength * CGFloat(angleRad) * 0.4
            
            let path = Path { p in
                p.move(to: CGPoint(x: headX, y: headY))
                p.addLine(to: CGPoint(x: tailX, y: tailY))
            }
            ctx.stroke(path, with: .linearGradient(
                Gradient(colors: [.white, .white.opacity(0.3), .clear]),
                startPoint: CGPoint(x: headX, y: headY),
                endPoint: CGPoint(x: tailX, y: tailY)
            ), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
    }

    private func generateStars() {
        var newStars: [Star] = []
        for _ in 0..<120 {
            let x = CGFloat.random(in: 0...1)
            let y = CGFloat.random(in: 0...0.7)
            let size = CGFloat.random(in: 0.8...2.8)
            let speed = Double.random(in: 0.8...3.5)
            let offset = Double.random(in: 0...Double.pi * 2)
            let brightness = CGFloat.random(in: 0.5...1.0)
            newStars.append(Star(x: x, y: y, size: size, twinkleSpeed: speed, twinkleOffset: offset, brightness: brightness))
        }
        stars = newStars
    }
}
