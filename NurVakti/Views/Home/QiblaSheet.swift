import SwiftUI
import CoreLocation

struct QiblaSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var qiblaAngle: Double = 0
    
    var body: some View {
        ZStack {
            Color(hex: "0F2027").ignoresSafeArea()
            
            VStack(spacing: 40) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding()
                
                Text(LocalizationManager.shared.localizedString("qibla.qiblaDirection"))
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                ZStack {
                    // Pusula Arka Planı
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 4)
                        .frame(width: 300, height: 300)
                    
                    // Pusula İğnesi
                    VStack {
                        Image(systemName: "location.north.line.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.nurGold)
                            .rotationEffect(.degrees(qiblaAngle))
                    }
                    
                    // Merkez Nokta
                    Circle()
                        .fill(Color.nurGold)
                        .frame(width: 12, height: 12)
                }
                
                VStack(spacing: 8) {
                    Text(LocalizationManager.shared.localizedString("qibla.kaabaDirection"))
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(Int(qiblaAngle))°")
                        .font(.system(size: 44, weight: .bold, design: .monospaced))
                        .foregroundColor(.nurGold)
                }
                
                Text(LocalizationManager.shared.localizedString("qibla.calibrateHint"))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}

#Preview {
    QiblaSheet()
}
