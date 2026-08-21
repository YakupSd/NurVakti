import SwiftUI

struct CloudLayerView: View {
    let opacity: Double
    let cloudColor: Color
    
    @State private var cloudSeeds: [CloudSeed] = []
    
    struct CloudSeed: Identifiable {
        let id = UUID()
        var x: CGFloat
        let y: CGFloat
        let scale: CGFloat
        let speed: CGFloat
        let blurRadius: CGFloat   // Depth: farther clouds = more blur
        let depthOpacity: CGFloat // Depth: farther clouds = more transparent
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
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    let currentX = (seed.x + CGFloat(time) * seed.speed).truncatingRemainder(dividingBy: 1.3) - 0.15
                    
                    let drawX = currentX * size.width
                    let drawY = seed.y * size.height
                    
                    context.drawLayer { ctx in
                        ctx.opacity = opacity * Double(seed.depthOpacity)
                        
                        // Apply depth blur for atmospheric perspective
                        if seed.blurRadius > 0 {
                            ctx.addFilter(.blur(radius: seed.blurRadius))
                        }
                        
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
        
        // Background clouds (far away, blurry, transparent, slow)
        for _ in 0..<3 {
            let x = CGFloat.random(in: 0...1)
            let y = CGFloat.random(in: 0.02...0.15)
            let scale = CGFloat.random(in: 1.2...1.8)
            let speed = CGFloat.random(in: 0.002...0.005)
            
            newClouds.append(CloudSeed(
                x: x, y: y, scale: scale, speed: speed,
                blurRadius: CGFloat.random(in: 3...6),
                depthOpacity: CGFloat.random(in: 0.35...0.55),
                parts: []
            ))
        }
        
        // Mid-ground clouds (medium clarity)
        for _ in 0..<3 {
            let x = CGFloat.random(in: 0...1)
            let y = CGFloat.random(in: 0.12...0.30)
            let scale = CGFloat.random(in: 0.9...1.3)
            let speed = CGFloat.random(in: 0.005...0.009)
            
            newClouds.append(CloudSeed(
                x: x, y: y, scale: scale, speed: speed,
                blurRadius: CGFloat.random(in: 0.5...2.0),
                depthOpacity: CGFloat.random(in: 0.7...0.85),
                parts: []
            ))
        }
        
        // Foreground clouds (closest, sharp, opaque, fastest)
        for _ in 0..<2 {
            let x = CGFloat.random(in: 0...1)
            let y = CGFloat.random(in: 0.25...0.40)
            let scale = CGFloat.random(in: 0.7...1.1)
            let speed = CGFloat.random(in: 0.008...0.014)
            
            newClouds.append(CloudSeed(
                x: x, y: y, scale: scale, speed: speed,
                blurRadius: 0,
                depthOpacity: CGFloat.random(in: 0.85...1.0),
                parts: []
            ))
        }
        
        cloudSeeds = newClouds
    }
}
