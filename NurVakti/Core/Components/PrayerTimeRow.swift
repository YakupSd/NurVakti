import SwiftUI

struct PrayerTimeRow: View {
    let prayer: PrayerName
    let time: Date
    let isActive: Bool
    let isPast: Bool
    let progress: Double?
    let remainingTime: String?
    let notificationEnabled: Bool
    let fontSize: FontSize
    let language: LanguageCode
    let onNotificationToggle: () -> Void
    
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                // Sol: İkon
                ZStack {
                    Circle()
                        .fill(iconBg)
                        .frame(width: 50, height: 50)
                    
                    if isActive {
                        Circle()
                            .fill(prayer.startColor.opacity(0.25))
                            .frame(width: 50, height: 50)
                            .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                            .opacity(pulseAnimation ? 0 : 0.8)
                            .animation(.easeOut(duration: 1.4).repeatForever(autoreverses: false), value: pulseAnimation)
                    }
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                .shadow(color: isActive ? prayer.startColor.opacity(0.4) : .clear, radius: 8)
                
                // Orta: İsim + Alt Bilgi
                VStack(alignment: .leading, spacing: 3) {
                    Text(prayer.localizedName(for: language))
                        .nurFont(fontSize.body + 2, weight: .bold)
                        .foregroundColor(isActive ? .white : (isPast ? .white.opacity(0.45) : .white.opacity(0.9)))
                    
                    if isActive, let rem = remainingTime {
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.system(size: 10))
                            Text("\(rem) \(NSLocalizedString("prayer.remaining", comment: ""))")
                                .nurFont(12, weight: .semibold)
                        }
                        .foregroundColor(.nurGold)
                    } else {
                        Text(prayer.arabicText)
                            .font(.custom("Amiri-Regular", size: 13))
                            .foregroundColor(.white.opacity(isPast ? 0.25 : 0.4))
                    }
                }
                
                Spacer()
                
                // Sağ: Saat + Durum
                VStack(alignment: .trailing, spacing: 5) {
                    Text(timeFormatter.string(from: time))
                        .nurFont(22, weight: .bold, design: .monospaced)
                        .foregroundColor(isActive ? .white : (isPast ? .white.opacity(0.3) : .white.opacity(0.8)))
                    
                    statusBadge
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            
            // Progress Bar — sadece aktif vakit
            if isActive, let p = progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [prayer.startColor, .nurGold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(8, geo.size.width * CGFloat(p)), height: 4)
                            .shadow(color: .nurGold.opacity(0.5), radius: 3)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 18)
                .padding(.bottom, 14)
            }
        }
        .background(rowBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isActive ? Color.nurGold.opacity(0.5) : Color.white.opacity(isPast ? 0.03 : 0.07),
                    lineWidth: isActive ? 1.5 : 1
                )
        )
        .shadow(color: isActive ? prayer.startColor.opacity(0.2) : .clear, radius: 12, y: 6)
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
        .onAppear {
            if isActive { pulseAnimation = true }
        }
    }
    
    // MARK: - Computed Properties
    
    @ViewBuilder
    private var statusBadge: some View {
        if isPast {
            HStack(spacing: 3) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                Text(NSLocalizedString("prayer.completed", comment: ""))
                    .nurFont(10, weight: .bold)
            }
            .foregroundColor(.green.opacity(0.7))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
        } else if isActive {
            HStack(spacing: 3) {
                Circle()
                    .fill(Color.nurGold)
                    .frame(width: 6, height: 6)
                Text(NSLocalizedString("prayer.active", comment: ""))
                    .nurFont(10, weight: .bold)
            }
            .foregroundColor(.nurGold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.nurGold.opacity(0.12))
            .cornerRadius(8)
        } else {
            Button(action: onNotificationToggle) {
                Image(systemName: notificationEnabled ? "bell.fill" : "bell.slash")
                    .font(.system(size: 13))
                    .foregroundColor(notificationEnabled ? .nurGold.opacity(0.7) : .white.opacity(0.2))
            }
        }
    }
    
    private var iconName: String {
        if isPast { return "checkmark.circle.fill" }
        if isActive { return prayer.symbol }
        return prayer.symbol
    }
    
    private var iconColor: Color {
        if isPast { return .green.opacity(0.5) }
        if isActive { return .nurGold }
        return .white.opacity(0.35)
    }
    
    private var iconBg: Color {
        if isPast { return Color.green.opacity(0.06) }
        if isActive { return prayer.startColor.opacity(0.2) }
        return Color.white.opacity(0.05)
    }
    
    @ViewBuilder
    private var rowBackground: some View {
        if isActive {
            LinearGradient(
                colors: [prayer.startColor.opacity(0.45), Color(hex: "0F172A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isPast {
            Color(hex: "0A1020").opacity(0.9)
        } else {
            Color(hex: "10192E").opacity(0.85)
        }
    }
    
    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }
}

fileprivate extension PrayerName {
    var arabicText: String {
        switch self {
        case .imsak:   return "الإمساك"
        case .fajr:    return "الفجر"
        case .sunrise: return "الشروق"
        case .dhuhr:   return "الظهر"
        case .asr:     return "العصر"
        case .maghrib: return "المغرب"
        case .isha:    return "العشاء"
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        PrayerTimeRow(prayer: .fajr, time: Date(), isActive: false, isPast: true, progress: 1.0, remainingTime: nil, notificationEnabled: true, fontSize: .medium, language: .tr) {}
        PrayerTimeRow(prayer: .dhuhr, time: Date(), isActive: true, isPast: false, progress: 0.4, remainingTime: "01:24:33", notificationEnabled: true, fontSize: .medium, language: .tr) {}
        PrayerTimeRow(prayer: .asr, time: Date(), isActive: false, isPast: false, progress: 0.0, remainingTime: nil, notificationEnabled: false, fontSize: .medium, language: .tr) {}
    }
    .padding()
    .background(Color(hex: "0F172A"))
}
