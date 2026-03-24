import SwiftUI

struct CountdownRing: View {
    let nextPrayerName: PrayerName
    let timeRemaining: TimeInterval
    let totalInterval: TimeInterval
    let language: LanguageCode
    let fontSize: FontSize
    
    private var progress: Double {
        max(0, min(1, 1 - (timeRemaining / totalInterval)))
    }
    
    var body: some View {
        ZStack {
            // Dış Halkalar
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(colors: [nextPrayerName.startColor.opacity(0.5), nextPrayerName.startColor], center: .center),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            
            // İçerik
            VStack(spacing: 8) {
                Text(nextPrayerLabel)
                    .font(.system(size: fontSize.caption, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .textCase(.uppercase)
                
                Text(nextPrayerName.localizedName(for: language))
                    .font(.system(size: fontSize.title, weight: .bold))
                    .foregroundColor(.white)
                
                Text(timeString)
                    .font(.system(size: fontSize.body + 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.nurGold)
                    .contentTransition(.numericText()) // iOS 16+ flip benzeri geçiş
            }
            
            // Küçük Arapça vakit adı
            VStack {
                Spacer()
                Text(nextPrayerName.rawValue.capitalized) // Basitleştirilmiş
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 20)
            }
        }
        .frame(width: 240, height: 240)
        // ── Accessibility ──────────────────────────────────────────
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(nextPrayerLabel): \(nextPrayerName.localizedName(for: language))")
        .accessibilityValue(accessibilityTimeString)
    }
    
    private var accessibilityTimeString: String {
        let h = Int(timeRemaining) / 3600
        let m = (Int(timeRemaining) % 3600) / 60
        let s = Int(timeRemaining) % 60
        if h > 0 { return "\(h) saat \(m) dakika kaldı" }
        if m > 0 { return "\(m) dakika \(s) saniye kaldı" }
        return "\(s) saniye kaldı"
    }
    
    private var nextPrayerLabel: String {
        switch language {
        case .tr: return "Sonraki Vakit"
        case .ar: return "الصلاة القادمة"
        case .en: return "Next Prayer"
        case .de: return "Nächstes Gebet"
        case .pt: return "Próxima Oração"
        }
    }
    
    private var timeString: String {
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    CountdownRing(nextPrayerName: .maghrib, timeRemaining: 3661, totalInterval: 14400, language: .tr, fontSize: .large)
        .padding()
        .background(Color.black)
}
