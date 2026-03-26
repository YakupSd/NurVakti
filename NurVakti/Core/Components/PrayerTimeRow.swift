import SwiftUI

struct PrayerTimeRow: View {
    let prayer: PrayerName
    let time: Date
    let isActive: Bool        // Şu anki vakit
    let isPast: Bool          // Geçmiş vakit
    let progress: Double?     // 0.0 - 1.0 arası ilerleme
    let remainingTime: String? // Kalan süre (örn: "01:24")
    let notificationEnabled: Bool
    let fontSize: FontSize
    let language: LanguageCode
    let onNotificationToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Sol: İkon (Premium Style)
                ZStack {
                    Circle()
                        .fill(isActive ? prayer.startColor.opacity(0.3) : .white.opacity(0.05))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: isActive ? prayer.symbol : (isPast ? "checkmark.circle.fill" : prayer.symbol))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(isActive ? .nurGold : (isPast ? .green.opacity(0.6) : .white.opacity(0.5)))
                }
                .shadow(color: isActive ? prayer.startColor.opacity(0.5) : .clear, radius: 10)
                
                // Orta: İsimler
                VStack(alignment: .leading, spacing: 2) {
                    Text(prayer.localizedName(for: language))
                        .nurFont(fontSize.body + 2, weight: .bold)
                        .foregroundColor(isActive ? .white : (isPast ? .white.opacity(0.4) : .white))
                    
                    if isActive, let rem = remainingTime {
                        Text("\(rem) \(NSLocalizedString("general.remaining", comment: ""))")
                            .nurFont(12, weight: .medium)
                            .foregroundColor(.nurGold)
                    } else {
                        Text(prayer.arabicText)
                            .nurFont(12)
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                Spacer()
                
                // Sağ: Saat ve Zil
                VStack(alignment: .trailing, spacing: 4) {
                    Text(timeFormatter.string(from: time))
                        .nurFont(20, weight: .bold, design: .monospaced)
                        .foregroundColor(isActive ? .white : (isPast ? .white.opacity(0.3) : .white))
                    
                    if !isPast {
                        Button(action: onNotificationToggle) {
                            HStack(spacing: 4) {
                                Image(systemName: notificationEnabled ? "bell.fill" : "bell.slash")
                                    .font(.system(size: 12))
                                if isActive {
                                    Text("ACTIVE")
                                        .nurFont(10, weight: .black)
                                }
                            }
                            .foregroundColor(notificationEnabled ? .nurGold : .white.opacity(0.3))
                        }
                    } else {
                        Text("Completed")
                            .nurFont(10, weight: .bold)
                            .foregroundColor(.green.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Progress Bar (Sadece aktif vakit için)
            if isActive, let p = progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(
                                LinearGradient(colors: [.nurGold, .nurGoldLight], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geo.size.width * CGFloat(p), height: 6)
                            .shadow(color: .nurGold.opacity(0.5), radius: 4)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .background(
            ZStack {
                if isActive {
                    LinearGradient(colors: [prayer.startColor.opacity(0.4), .black.opacity(0.2)], 
                                  startPoint: .topLeading, 
                                  endPoint: .bottomTrailing)
                } else {
                    Color.white.opacity(0.03)
                }
            }
        )
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isActive ? Color.nurGold.opacity(0.6) : Color.white.opacity(0.05), lineWidth: isActive ? 2 : 1)
        )
        .shadow(color: isActive ? .black.opacity(0.3) : .clear, radius: 15, y: 10)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .opacity(isPast ? 0.6 : 1.0)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}

fileprivate extension PrayerName {
    var arabicText: String {
        switch self {
        case .imsak: return "الإمساك"
        case .fajr: return "الفجر"
        case .sunrise: return "الشروق"
        case .dhuhr: return "الظهر"
        case .asr: return "العصر"
        case .maghrib: return "المغرب"
        case .isha: return "العشاء"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        PrayerTimeRow(prayer: .fajr, time: Date(), isActive: false, isPast: true, progress: 1.0, remainingTime: nil, notificationEnabled: true, fontSize: .medium, language: .tr) {}
        PrayerTimeRow(prayer: .dhuhr, time: Date(), isActive: true, isPast: false, progress: 0.4, remainingTime: "01:24", notificationEnabled: true, fontSize: .large, language: .tr) {}
        PrayerTimeRow(prayer: .asr, time: Date(), isActive: false, isPast: false, progress: 0.0, remainingTime: nil, notificationEnabled: false, fontSize: .medium, language: .ar) {}
    }
    .padding()
    .background(Color.mushafBackground)
}
