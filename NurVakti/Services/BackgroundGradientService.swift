import SwiftUI
import Combine

@MainActor
final class BackgroundGradientService: ObservableObject {
    @Published var currentTheme: PrayerTheme = .dhuhrTheme
    @Published var gradient: LinearGradient = LinearGradient(colors: [.blue, .white], startPoint: .top, endPoint: .bottom)
    
    @Published var showStars: Bool = false
    @Published var sunPosition: Double = 0.5
    
    func updateTheme(prayers: PrayerTime, currentTime: Date) {
        let hour = Double(Calendar.current.component(.hour, from: currentTime)) +
                   Double(Calendar.current.component(.minute, from: currentTime)) / 60.0
        
        let (currentPhase, nextPhase, progress) = SkyPhase.current(for: hour)
        let skyGradient = SkyColorPalette.interpolate(from: currentPhase, to: nextPhase, progress: progress)
        
        // Map SkyPhase to a dynamic PrayerTheme for compatibility with existing views
        let theme = PrayerTheme(
            prayerName: .imsak, // Dummy as it's no longer strictly 1:1 with prayers
            topColor: skyGradient.top,
            bottomColor: skyGradient.horizon,
            starOpacity: calculateStarOpacity(for: currentPhase, progress: progress),
            sunPosition: calculateSunPosition(for: hour),
            auraColor: skyGradient.horizon.opacity(0.3),
            ambientLabel: currentPhase.rawValue
        )
        
        DispatchQueue.main.async {
            self.currentTheme = theme
            self.gradient = LinearGradient(colors: [theme.topColor, theme.bottomColor], startPoint: .top, endPoint: .bottom)
            self.showStars = theme.starOpacity > 0.5
            self.sunPosition = theme.sunPosition
        }
    }
    
    private func calculateStarOpacity(for phase: SkyPhase, progress: Double) -> Double {
        switch phase {
        case .night, .deepNight: return 1.0
        case .earlyNight: return progress
        case .preDawn: return 1.0 - progress
        case .dusk: return 0.3 * progress
        default: return 0
        }
    }
    
    private func calculateSunPosition(for hour: Double) -> Double {
        // Simple 24h mapping to 0..1..0 arc
        // 6:00 (0) -> 12:00 (1.0) -> 18:00 (0)
        if hour >= 6 && hour <= 18 {
            let progress = (hour - 6) / 12.0
            return sin(progress * .pi)
        }
        return -0.2 // below horizon
    }
    
    // İki tema arasında interpolasyon logic placeholder
    func interpolatedGradient(from: PrayerTheme, 
                               to: PrayerTheme, 
                               progress: Double) -> LinearGradient {
        // Renk interpolasyonu için özel logic gerekebilir
        return LinearGradient(colors: [from.topColor, to.bottomColor], startPoint: .top, endPoint: .bottom)
    }
}
