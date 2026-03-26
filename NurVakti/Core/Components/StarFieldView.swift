import SwiftUI

struct StarFieldView: View {
    let opacity: Double
    
    @State private var twinkle = false
    
    var body: some View {
        Canvas { context, size in
            for _ in 0..<80 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let starSize = Double.random(in: 1...3)
                
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: starSize, height: starSize)),
                    with: .color(.white.opacity(Double.random(in: 0.3...1.0)))
                )
            }
        }
        .opacity(opacity)
        .opacity(twinkle ? 0.6 : 1.0)
        .animation(.easeInOut(duration: Double.random(in: 1...3)).repeatForever(autoreverses: true), value: twinkle)
        .onAppear { twinkle.toggle() }
        .drawingGroup() 
    }
}

#Preview {
    StarFieldView(opacity: 0.8)
        .background(Color.black)
}
