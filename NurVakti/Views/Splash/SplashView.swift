import SwiftUI

// MARK: - Premium Animated Splash View
struct SplashView: View {
    let onFinish: () -> Void
    
    // Animation States
    @State private var bgOpacity: Double = 0.0
    @State private var hilalScale: CGFloat = 0.3
    @State private var hilalOpacity: Double = 0.0
    @State private var hilalRotation: Double = -30
    @State private var starScale: CGFloat = 0.0
    @State private var starOpacity: Double = 0.0
    @State private var starGlow: CGFloat = 0.6
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0.0
    @State private var ring2Scale: CGFloat = 0.4
    @State private var ring2Opacity: Double = 0.0
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 20
    @State private var bismillahOpacity: Double = 0.0
    @State private var bismillahOffset: CGFloat = 15
    @State private var particlesActive: Bool = false
    @State private var shimmerPhase: CGFloat = -1.0
    @State private var outerGlowPulse: CGFloat = 0.85
    
    var body: some View {
        ZStack {
            // ── Layer 1: Deep Gradient Background ─────────────────
            LinearGradient(
                colors: [
                    Color(hex: "0A0E27"),
                    Color(hex: "0F1B3D"),
                    Color(hex: "1A2755")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(bgOpacity)
            
            // Subtle radial warm glow from center
            RadialGradient(
                colors: [
                    Color(hex: "D4AF37").opacity(0.12),
                    Color(hex: "D4AF37").opacity(0.04),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 300
            )
            .scaleEffect(outerGlowPulse)
            .ignoresSafeArea()
            
            // ── Layer 2: Particle Field ───────────────────────────
            if particlesActive {
                SplashParticleField()
            }
            
            // ── Layer 3: Central Emblem ───────────────────────────
            VStack(spacing: 40) {
                ZStack {
                    // Outer decorative ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color(hex: "D4AF37").opacity(0.5),
                                    Color(hex: "F3E5AB").opacity(0.2),
                                    Color(hex: "D4AF37").opacity(0.5),
                                    Color(hex: "8A6914").opacity(0.3),
                                    Color(hex: "D4AF37").opacity(0.5)
                                ],
                                center: .center
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 170, height: 170)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                    
                    // Inner ring with dots pattern
                    Circle()
                        .stroke(
                            Color(hex: "D4AF37").opacity(0.2),
                            style: StrokeStyle(lineWidth: 1, dash: [2, 6])
                        )
                        .frame(width: 148, height: 148)
                        .scaleEffect(ring2Scale)
                        .opacity(ring2Opacity)
                    
                    // Glass backdrop for emblem
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "1A2755").opacity(0.6),
                                    Color(hex: "0F1B3D").opacity(0.8)
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(width: 130, height: 130)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "D4AF37").opacity(0.4),
                                            Color(hex: "F3E5AB").opacity(0.15),
                                            Color(hex: "D4AF37").opacity(0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: Color(hex: "D4AF37").opacity(0.3), radius: 30, y: 0)
                        .scaleEffect(hilalScale)
                        .opacity(hilalOpacity)
                    
                    // Crescent Moon
                    Image(systemName: "moon.fill")
                        .font(.system(size: 52, weight: .thin))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(hex: "E8DCC8")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.white.opacity(0.4), radius: 12, y: 0)
                        .offset(x: -6, y: 2)
                        .scaleEffect(hilalScale)
                        .opacity(hilalOpacity)
                        .rotationEffect(.degrees(hilalRotation))
                    
                    // Star
                    Image(systemName: "star.fill")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(
                            RadialGradient(
                                colors: [
                                    Color(hex: "FFFDE7"),
                                    Color(hex: "F3E5AB"),
                                    Color(hex: "D4AF37")
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 12
                            )
                        )
                        .shadow(color: Color(hex: "F3E5AB").opacity(starGlow), radius: 16, y: 0)
                        .shadow(color: Color(hex: "D4AF37").opacity(0.5), radius: 6, y: 0)
                        .offset(x: 22, y: -22)
                        .scaleEffect(starScale)
                        .opacity(starOpacity)
                }
                
                // ── Layer 4: Typography ───────────────────────────
                VStack(spacing: 14) {
                    // App Name with shimmer
                    Text("NurVakti")
                        .font(.system(size: 42, weight: .black, design: .serif))
                        .tracking(3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hex: "F3E5AB"),
                                    Color(hex: "D4AF37"),
                                    Color(hex: "F3E5AB")
                                ],
                                startPoint: UnitPoint(x: shimmerPhase, y: 0),
                                endPoint: UnitPoint(x: shimmerPhase + 1, y: 1)
                            )
                        )
                        .shadow(color: Color(hex: "D4AF37").opacity(0.4), radius: 8, y: 2)
                        .opacity(titleOpacity)
                        .offset(y: titleOffset)
                    
                    // Bismillah
                    Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                        .font(.custom("ScheherazadeNew-Bold", size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hex: "D4AF37").opacity(0.8),
                                    Color(hex: "F3E5AB").opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color(hex: "D4AF37").opacity(0.2), radius: 6)
                        .opacity(bismillahOpacity)
                        .offset(y: bismillahOffset)
                    
                    // Thin gold divider
                    RoundedRectangle(cornerRadius: 1)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color(hex: "D4AF37").opacity(0.4),
                                    Color(hex: "F3E5AB").opacity(0.6),
                                    Color(hex: "D4AF37").opacity(0.4),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 120, height: 1.5)
                        .opacity(bismillahOpacity)
                }
            }
        }
        .onAppear { startAnimationSequence() }
    }
    
    // MARK: - Animation Sequence
    private func startAnimationSequence() {
        // 0. Background fade in
        withAnimation(.easeIn(duration: 0.3)) {
            bgOpacity = 1.0
        }
        
        // 1. Particles start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            particlesActive = true
        }
        
        // 2. Emblem backdrop + crescent appear
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
            hilalScale = 1.0
            hilalOpacity = 1.0
            hilalRotation = 0
        }
        
        // 3. Rings expand
        withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
            ringScale = 1.0
            ringOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
            ring2Scale = 1.0
            ring2Opacity = 1.0
        }
        
        // 4. Star pops in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.5)) {
            starScale = 1.0
            starOpacity = 1.0
        }
        
        // 5. Star glow pulse
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(0.6)) {
            starGlow = 1.0
        }
        
        // 6. Outer glow pulse
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.4)) {
            outerGlowPulse = 1.1
        }
        
        // 7. Title slide up + fade in
        withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
            titleOpacity = 1.0
            titleOffset = 0
        }
        
        // 8. Shimmer sweep
        withAnimation(.easeInOut(duration: 1.5).delay(0.7)) {
            shimmerPhase = 2.0
        }
        
        // 9. Bismillah
        withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
            bismillahOpacity = 1.0
            bismillahOffset = 0
        }
        
        // 10. Finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            onFinish()
        }
    }
}

// MARK: - Floating Particle Field
struct SplashParticleField: View {
    let particleCount = 25
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<particleCount, id: \.self) { i in
                    SplashParticle(
                        screenSize: geo.size,
                        delay: Double(i) * 0.08,
                        index: i
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct SplashParticle: View {
    let screenSize: CGSize
    let delay: Double
    let index: Int
    
    @State private var opacity: Double = 0
    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    
    private var size: CGFloat {
        CGFloat.random(in: 1.5...4)
    }
    
    private var startX: CGFloat {
        CGFloat.random(in: 0...screenSize.width)
    }
    
    private var startY: CGFloat {
        CGFloat.random(in: screenSize.height * 0.2...screenSize.height * 0.9)
    }
    
    var body: some View {
        Circle()
            .fill(
                index % 3 == 0
                ? Color(hex: "F3E5AB").opacity(0.7)
                : Color.white.opacity(0.4)
            )
            .frame(width: size, height: size)
            .blur(radius: size > 3 ? 1 : 0)
            .position(x: startX + xOffset, y: startY + yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: Double.random(in: 1.5...3.0)).delay(delay)) {
                    opacity = Double.random(in: 0.3...0.8)
                    yOffset = CGFloat.random(in: -100...(-40))
                    xOffset = CGFloat.random(in: -20...20)
                }
                // Fade out
                withAnimation(.easeIn(duration: 0.8).delay(delay + 1.5)) {
                    opacity = 0
                }
            }
    }
}

#Preview {
    SplashView {}
}
