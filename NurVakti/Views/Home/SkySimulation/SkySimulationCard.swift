import SwiftUI

struct SkySimulationCard: View {
    let nextPrayerName: PrayerName
    let timeRemaining: TimeInterval
    let totalInterval: TimeInterval
    let language: LanguageCode
    
    var body: some View {
        ZStack {
            // 1. Physical Sky Simulation Background
            SkySimulationView()
                .clipShape(RoundedRectangle(cornerRadius: 32))
            
            // 2. Dark Overlay to ensure text readability
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.black.opacity(0.2))
            
            // 3. Countdown Ring
            CountdownRing(
                nextPrayerName: nextPrayerName,
                timeRemaining: timeRemaining,
                totalInterval: totalInterval,
                language: language,
                fontSize: .large
            )
            .padding(.vertical, 30)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1.0, contentMode: .fit)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.black.opacity(0.4))
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        )
        .padding(.horizontal, 4)
    }
}

#Preview {
    SkySimulationCard(nextPrayerName: .asr, timeRemaining: 3600, totalInterval: 14400, language: .tr)
        .padding()
        .background(Color.gray)
}
