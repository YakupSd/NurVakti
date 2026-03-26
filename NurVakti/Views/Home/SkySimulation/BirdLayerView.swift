import SwiftUI

struct BirdLayerView: View {
    let opacity: Double // Visible only during day
    
    @State private var birds: [Bird] = []
    
    struct Bird: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let speed: CGFloat
        let scale: CGFloat
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                guard opacity > 0.1 else { return }
                
                context.opacity = opacity
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                for bird in birds {
                    // Birds fly from right to left
                    let currentX = (bird.x - CGFloat(time) * bird.speed).truncatingRemainder(dividingBy: 1.4) + 0.2
                    let drawX = currentX * size.width
                    let drawY = bird.y * size.height
                    
                    // Simple "flapping" effect using scaleY oscillation
                    let flap = 0.8 + 0.2 * sin(time * 8 + Double(bird.id.hashValue))
                    
                    let rect = CGRect(
                        x: drawX,
                        y: drawY,
                        width: 30 * bird.scale,
                        height: 20 * bird.scale * CGFloat(flap)
                    )
                    
                    context.draw(Image("bird_flight"), in: rect)
                }
            }
        }
        .onAppear {
            if birds.isEmpty {
                generateBirds()
            }
        }
    }
    
    private func generateBirds() {
        var newBirds: [Bird] = []
        for _ in 0..<3 {
            newBirds.append(Bird(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0.1...0.3),
                speed: CGFloat.random(in: 0.02...0.05),
                scale: CGFloat.random(in: 0.6...1.0)
            ))
        }
        birds = newBirds
    }
}
