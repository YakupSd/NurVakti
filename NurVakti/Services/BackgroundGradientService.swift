import SwiftUI
import Combine

final class BackgroundGradientService: ObservableObject {
    @Published var currentTheme: PrayerTheme = .dhuhrTheme
    @Published var gradient: LinearGradient = LinearGradient(colors: [.blue, .white], startPoint: .top, endPoint: .bottom)
    
    @Published var showStars: Bool = false
    @Published var sunPosition: Double = 0.5
    
    func updateTheme(prayers: PrayerTime, currentTime: Date) {
        let theme: PrayerTheme
        
        if currentTime < prayers.imsak || currentTime > prayers.isha {
            theme = .ishaTheme
        } else if currentTime < prayers.fajr {
            theme = .imsakTheme
        } else if currentTime < prayers.sunrise {
            theme = .fajrTheme
        } else if currentTime < prayers.dhuhr {
            theme = .sunriseTheme
        } else if currentTime < prayers.asr {
            theme = .dhuhrTheme
        } else if currentTime < prayers.maghrib {
            theme = .asrTheme
        } else {
            theme = .maghribTheme
        }
        
        DispatchQueue.main.async {
            self.currentTheme = theme
            self.gradient = LinearGradient(colors: [theme.topColor, theme.bottomColor], startPoint: .top, endPoint: .bottom)
            self.showStars = theme.starOpacity > 0.5
            self.sunPosition = theme.sunPosition
        }
    }
    
    // İki tema arasında interpolasyon logic placeholder
    func interpolatedGradient(from: PrayerTheme, 
                               to: PrayerTheme, 
                               progress: Double) -> LinearGradient {
        // Renk interpolasyonu için özel logic gerekebilir
        return LinearGradient(colors: [from.topColor, to.bottomColor], startPoint: .top, endPoint: .bottom)
    }
}
