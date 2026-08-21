import SwiftUI

struct SkySimulationView: View {
    var prayerTimes: PrayerTime? = nil
    var weather: WeatherData? = nil
    var currentTime: Date = Date()
    var debugSpeed: Double = 1.0
    
    @State private var animatedTime: Double = 0
    @State private var timer: Timer?
    @State private var lightningFlash: Double = 0.0
    
    var body: some View {
        let (currentPhase, nextPhase, progress) = SkyPhase.current(for: animatedTime)
        let gradient = SkyColorPalette.interpolate(from: currentPhase, to: nextPhase, progress: progress)
        let condition = weather?.condition ?? .clear
        
        ZStack {
            // 1. Base Sky Gradient
            LinearGradient(
                gradient: Gradient(colors: [gradient.top, gradient.horizon]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 2. Overcast/Storm Sky Darkening Tint
            if condition == .overcast || condition == .thunderstorm || condition == .heavyRain {
                Color(hex: "#101624").opacity(condition == .thunderstorm ? 0.35 : 0.22)
            }
            
            // 3. Horizon Glow (Sunrise / Sunset / Dawn)
            if condition != .overcast && condition != .heavyRain && condition != .thunderstorm {
                horizonGlow(for: currentPhase, progress: progress)
            }
            
            // 4. Star Field (Visible at night, dimmed if cloudy/raining)
            let starOpacity = calculateStarOpacity(for: currentPhase, progress: progress, condition: condition)
            AnimatedStarFieldView(opacity: starOpacity)
            
            // 5. Celestial Bodies (Sun & Moon)
            CelestialBodyView(hour: animatedTime, isSun: true)
            CelestialBodyView(hour: animatedTime, isSun: false)
            
            // 6. Birds (Visible during day when weather is clear/partlyCloudy)
            if condition == .clear || condition == .partlyCloudy {
                let birdOpacity = calculateBirdOpacity(for: currentPhase)
                BirdLayerView(opacity: birdOpacity)
            }
            
            // 7. Cloud Layer with Dynamic Weather Cloud Cover
            let cloudOpacity = calculateCloudOpacity(for: currentPhase, progress: progress, condition: condition)
            let cloudColor = calculateCloudColor(for: currentPhase, progress: progress, condition: condition)
            CloudLayerView(opacity: cloudOpacity, cloudColor: cloudColor)
            
            // 8. Mosque Silhouette Skyline
            MosqueSilhouetteView(phase: currentPhase, progress: progress)
            
            // 9. Rain Particle Layer (Drizzle, Rain, Heavy Rain, Thunderstorm)
            if condition == .rain || condition == .drizzle || condition == .heavyRain || condition == .thunderstorm {
                RainParticleView(isHeavy: condition == .heavyRain || condition == .thunderstorm)
            }
            
            // 10. Snow Particle Layer (Snow, Heavy Snow)
            if condition == .snow || condition == .heavySnow {
                SnowParticleView(isHeavy: condition == .heavySnow)
            }
            
            // 11. Fog / Mist Layer
            if condition == .fog {
                fogLayer
            }
            
            // 12. Thunderstorm Lightning Flash
            if condition == .thunderstorm && lightningFlash > 0 {
                Color.white.opacity(lightningFlash)
                    .blendMode(.screen)
            }
            
            // 13. Atmospheric Haze (Bottom Horizon Fade)
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "1A1A2E").opacity(0.10), .clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 90)
            }
        }
        .onAppear {
            setupInitialTime()
            startTimer()
            if condition == .thunderstorm {
                scheduleLightning()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onChange(of: currentTime) { newValue in
            if debugSpeed != 1.0 {
                 syncWithCurrentTime()
            }
        }
        .onChange(of: weather?.condition) { newCondition in
            if newCondition == .thunderstorm {
                scheduleLightning()
            }
        }
    }
    
    // MARK: - Fog / Mist Layer
    private var fogLayer: some View {
        VStack {
            Spacer()
            LinearGradient(
                colors: [Color.white.opacity(0.35), Color.white.opacity(0.1), Color.clear],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 200)
            .blur(radius: 10)
        }
    }
    
    // MARK: - Thunderstorm Lightning Flash Scheduler
    private func scheduleLightning() {
        let delay = Double.random(in: 4.0...10.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeIn(duration: 0.08)) {
                self.lightningFlash = 0.45
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeOut(duration: 0.25)) {
                    self.lightningFlash = 0.0
                }
                if self.weather?.condition == .thunderstorm {
                    self.scheduleLightning()
                }
            }
        }
    }
    
    // MARK: - Horizon Glow
    @ViewBuilder
    private func horizonGlow(for phase: SkyPhase, progress: Double) -> some View {
        let glowPhases: [SkyPhase] = [.dawn, .sunrise, .lateAfternoon, .sunset, .dusk]
        
        if glowPhases.contains(phase) {
            let glowColor: Color = {
                switch phase {
                case .dawn, .sunrise:
                    return Color(hex: "#FFA040")
                case .lateAfternoon:
                    return Color(hex: "#FF8C38")
                case .sunset:
                    return Color(hex: "#FF4500")
                case .dusk:
                    return Color(hex: "#8B3A8B")
                default:
                    return Color.clear
                }
            }()
            
            let glowOpacity: Double = {
                switch phase {
                case .dawn: return 0.3 + progress * 0.3
                case .sunrise: return 0.5 - progress * 0.3
                case .lateAfternoon: return 0.2 + progress * 0.3
                case .sunset: return 0.5
                case .dusk: return 0.4 - progress * 0.3
                default: return 0
                }
            }()
            
            VStack {
                Spacer()
                RadialGradient(
                    colors: [
                        glowColor.opacity(glowOpacity),
                        glowColor.opacity(glowOpacity * 0.5),
                        Color.clear
                    ],
                    center: .bottom,
                    startRadius: 10,
                    endRadius: 350
                )
                .frame(height: 350)
            }
        }
    }

    private func setupInitialTime() {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: currentTime)
        animatedTime = Double(components.hour ?? 0) + Double(components.minute ?? 0) / 60.0 + Double(components.second ?? 0) / 3600.0
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let increment = (0.1 * debugSpeed) / 3600.0
            animatedTime = (animatedTime + increment).truncatingRemainder(dividingBy: 24.0)
        }
    }
    
    private func syncWithCurrentTime() {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: currentTime)
        animatedTime = Double(components.hour ?? 0) + Double(components.minute ?? 0) / 60.0 + Double(components.second ?? 0) / 3600.0
    }

    private func calculateStarOpacity(for phase: SkyPhase, progress: Double, condition: WeatherCondition) -> Double {
        var base: Double = 0
        switch phase {
        case .night, .deepNight: base = 1.0
        case .earlyNight: base = progress
        case .preDawn: base = 1.0 - progress
        case .dusk: base = 0.3 * progress
        default: base = 0
        }
        
        if condition == .overcast || condition == .heavyRain || condition == .thunderstorm {
            return base * 0.15
        } else if condition == .rain || condition == .snow {
            return base * 0.35
        }
        return base
    }
    
    private func calculateCloudOpacity(for phase: SkyPhase, progress: Double, condition: WeatherCondition) -> Double {
        let nightPhases: [SkyPhase] = [.night, .deepNight, .earlyNight, .preDawn]
        let isNight = nightPhases.contains(phase)
        
        switch condition {
        case .clear:
            return isNight ? 0.15 : 0.40
        case .partlyCloudy:
            return isNight ? 0.35 : 0.65
        case .overcast, .heavyRain, .thunderstorm:
            return isNight ? 0.60 : 0.95
        case .rain, .drizzle, .snow, .heavySnow:
            return isNight ? 0.50 : 0.85
        case .fog:
            return 0.50
        }
    }
    
    private func calculateCloudColor(for phase: SkyPhase, progress: Double, condition: WeatherCondition) -> Color {
        if condition == .thunderstorm {
            return Color(hex: "#252836")
        } else if condition == .overcast || condition == .heavyRain {
            return Color(hex: "#454D5E")
        }
        
        switch phase {
        case .sunset, .dusk:
            return Color(hex: "#FFB088")
        case .sunrise, .dawn:
            return Color(hex: "#FFD4B8")
        case .night, .deepNight, .earlyNight:
            return Color(hex: "#2A3044")
        default:
            return .white
        }
    }
    
    private func calculateBirdOpacity(for phase: SkyPhase) -> Double {
        switch phase {
        case .morning, .midday, .afternoon: return 0.6
        case .sunrise, .lateAfternoon: return 0.3
        default: return 0
        }
    }
}
