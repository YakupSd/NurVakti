import SwiftUI

struct SkySimulationPreview: View {
    @State private var timeProgress: Double = 0.5 // 0.0 to 1.0
    
    var body: some View {
        ZStack {
            // The simulation view mapped to slider
            SkySimulationView(
                currentTime: dateFromProgress(timeProgress),
                debugSpeed: 0 // Stop internal time for scrubbing
            )
            .id(timeProgress) // Force recreate or sync
            
            // Overlay Controls
            VStack {
                Spacer()
                
                VStack(spacing: 15) {
                    let hour = timeProgress * 24.0
                    let (current, next, _) = SkyPhase.current(for: hour)
                    
                    Text(formatTime(hour: hour))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text(current.rawValue)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Slider(value: $timeProgress, in: 0...0.999)
                        .accentColor(.orange)
                        .padding(.horizontal)
                    
                    Text("Time Scrubber (00:00 - 23:59)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding()
            }
        }
    }
    
    private func dateFromProgress(_ progress: Double) -> Date {
        let hours = Int(progress * 24)
        let minutes = Int((progress * 24).truncatingRemainder(dividingBy: 1) * 60)
        return Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: Date()) ?? Date()
    }
    
    private func formatTime(hour: Double) -> String {
        let h = Int(hour)
        let m = Int((hour * 60).truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", h, m)
    }
}

#Preview {
    SkySimulationPreview()
}
