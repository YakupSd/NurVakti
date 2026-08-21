import SwiftUI
import Combine

struct NurLoadingView: View {
    @State private var beadIndex = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .background(Color.white)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                ZStack {
                    // Outer Beads (Tasbih) - 33 beads
                    ForEach(0..<33, id: \.self) { index in
                        BeadView(index: index, activeIndex: beadIndex)
                            .rotationEffect(.degrees(Double(index) * (360.0 / 33.0)))
                    }
                    
                    // Central pulsing icon (Qibla / Sacred Symbol)
                    ZStack {
                        // Halo
                        Circle()
                            .fill(Color.nurGold.opacity(0.15))
                            .frame(width: 60, height: 60)
                            .scaleEffect(pulseScale)
                        
                        // Icon
                        Image(systemName: "location.north.line.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.nurGold)
                            .rotationEffect(.degrees(rotation))
                    }
                }
                .frame(width: 150, height: 150)
                
                VStack(spacing: 8) {
                    Text("NurVakti".uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .kerning(4)
                        .foregroundColor(.nurGold.opacity(0.8))
                    
                    Text(LocalizationManager.shared.localizedString("general.pleaseWait"))
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                        .italic()
                }
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                beadIndex = (beadIndex + 1) % 33
            }
            
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.4
            }
            
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation += 10
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.3
            }
        }
    }
}

struct BeadView: View {
    let index: Int
    let activeIndex: Int
    
    var isActive: Bool { index == activeIndex }
    
    var body: some View {
        Circle()
            .fill(isActive ? Color.nurGold : Color(hex: "1A1A2E").opacity(0.2))
            .frame(width: isActive ? 8 : 4, height: isActive ? 8 : 4)
            .offset(y: -60) // Radius of the tasbih ring
            .shadow(color: isActive ? .nurGold.opacity(0.6) : .clear, radius: 4)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
    }
}

#Preview {
    NurLoadingView()
}
