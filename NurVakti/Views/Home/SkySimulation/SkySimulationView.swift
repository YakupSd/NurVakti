import SwiftUI

struct SkySimulationView: View {
    // Current time (can be injected for testing)
    var currentTime: Date = Date()
    
    // Debug/Preview speed (1.0 = real-time, 60.0 = 1 min per sec)
    var debugSpeed: Double = 1.0
    
    // Internal state for animation
    @State private var animatedTime: Double = 0
    @State private var timer: Timer?
    
    var body: some View {
        let (currentPhase, nextPhase, progress) = SkyPhase.current(for: animatedTime)
        let gradient = SkyColorPalette.interpolate(from: currentPhase, to: nextPhase, progress: progress)
        
        ZStack {
            // 1. Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [gradient.top, gradient.horizon]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 2. Star Field (Visible at night)
            let starOpacity = calculateStarOpacity(for: currentPhase, progress: progress)
            AnimatedStarFieldView(opacity: starOpacity)
            
            // 3. Celestial Bodies
            CelestialBodyView(hour: animatedTime, isSun: true)
            CelestialBodyView(hour: animatedTime, isSun: false)
            
            // 4. Life (Birds - Only during day)
            let birdOpacity = calculateBirdOpacity(for: currentPhase)
            BirdLayerView(opacity: birdOpacity)
            
            // 5. Cloud Layer
            let cloudOpacity = calculateCloudOpacity(for: currentPhase, progress: progress)
            let cloudColor = calculateCloudColor(for: currentPhase, progress: progress)
            CloudLayerView(opacity: cloudOpacity, cloudColor: cloudColor)
            
            // 5. Atmosphere Haze (Bottom Glow)
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0.15), .clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 100)
            }
        }
        .onAppear {
            setupInitialTime()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        // Listen for external time changes (e.g. from preview slider)
        .onChange(of: currentTime) { newValue in
            if debugSpeed != 1.0 { // only sync if not in active debug simulation
                 syncWithCurrentTime()
            }
        }
    }

    private func setupInitialTime() {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: currentTime)
        animatedTime = Double(components.hour ?? 0) + Double(components.minute ?? 0) / 60.0 + Double(components.second ?? 0) / 3600.0
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let increment = (0.1 * debugSpeed) / 3600.0 // convert to hours
            animatedTime = (animatedTime + increment).truncatingRemainder(dividingBy: 24.0)
        }
    }
    
    private func syncWithCurrentTime() {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: currentTime)
        animatedTime = Double(components.hour ?? 0) + Double(components.minute ?? 0) / 60.0 + Double(components.second ?? 0) / 3600.0
    }

    // Helper visibility calculations
    private func calculateStarOpacity(for phase : SkyPhase, progress: Double) -> Double {
        switch phase {
        case .night, .deepNight: return 1.0
        case .earlyNight: return progress
        case .preDawn: return 1.0 - progress
        case .dusk: return 0.3 * progress
        default: return 0
        }
    }
    
    private func calculateCloudOpacity(for phase: SkyPhase, progress: Double) -> Double {
        let nightPhases: [SkyPhase] = [.night, .deepNight, .earlyNight, .preDawn]
        return nightPhases.contains(phase) ? 0.3 : 0.7
    }
    
    private func calculateCloudColor(for phase: SkyPhase, progress: Double) -> Color {
        if phase == .sunrise || phase == .dawn {
            return Color(hex: "#FFCC80").opacity(0.8)
        } else if phase == .sunset || phase == .dusk {
            return Color(hex: "#FFAB91").opacity(0.8)
        } else if [.night, .deepNight, .earlyNight].contains(phase) {
            return Color(hex: "#37474F")
        }
        return .white
    }
    
    private func calculateBirdOpacity(for phase: SkyPhase) -> Double {
        let daylightPhases: [SkyPhase] = [.morning, .midday, .afternoon, .lateAfternoon]
        return daylightPhases.contains(phase) ? 0.6 : 0
    }
}
