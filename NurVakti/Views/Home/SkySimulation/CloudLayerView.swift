import SwiftUI

struct CloudLayerView: View {
    let opacity: Double // Night = 0.1, Day = 0.8
    let cloudColor: Color
    
    @State private var cloudSeeds: [CloudSeed] = []
    
    struct CloudSeed: Identifiable {
        let id = UUID()
        var x: CGFloat
        let y: CGFloat
        let scale: CGFloat
        let speed: CGFloat
        let parts: [CloudPart]
    }
    
    struct CloudPart {
        let offsetX: CGFloat
        let offsetY: CGFloat
        let size: CGSize
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for seed in cloudSeeds {
                    // Constant movement
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    let currentX = (seed.x + CGFloat(time) * seed.speed).truncatingRemainder(dividingBy: 1.2) - 0.1
                    
                    let drawX = currentX * size.width
                    let drawY = seed.y * size.height
                    
                    context.drawLayer { ctx in
                        ctx.opacity = opacity
                        let rect = CGRect(
                            x: drawX,
                            y: drawY,
                            width: 200 * seed.scale,
                            height: 100 * seed.scale
                        )
                        ctx.draw(Image("premium_cloud"), in: rect)
                    }
                }
            }
        }
        .onAppear {
            if cloudSeeds.isEmpty {
                generateClouds()
            }
        }
    }

    private func generateClouds() {
        var newClouds: [CloudSeed] = []
        for _ in 0..<7 { // Increased density slightly
            let x = CGFloat.random(in: 0...1)
            let y = CGFloat.random(in: 0.05...0.4)
            let scale = CGFloat.random(in: 0.8...1.5)
            let speed = CGFloat.random(in: 0.003...0.012)
            
            newClouds.append(CloudSeed(x: x, y: y, scale: scale, speed: speed, parts: []))
        }
        cloudSeeds = newClouds
    }
}
