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
                // Sol: Lüks İkon Rozeti
                ZStack {
                    Circle()
                        .fill(iconBg)
                        .frame(width: 44, height: 44)
                    
                    if isActive {
                        Circle()
                            .fill(Color.nurGold.opacity(0.2))
                            .frame(width: 44, height: 44)
                            .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                            .opacity(pulseAnimation ? 0 : 0.8)
                            .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: pulseAnimation)
                    }
                    
                    Image(systemName: prayer.symbol)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(
                            isActive
                                ? LinearGradient(colors: [Color(hex: "D4AF37"), Color(hex: "B8860B")], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [iconColor, iconColor], startPoint: .top, endPoint: .bottom)
                        )
                }
                
                // Orta: Vakit Adı + Arapça Yazılışı
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(prayer.localizedName(for: language))
                            .nurFont(16, weight: isActive ? .bold : .semibold)
                            .foregroundColor(
                                isActive
                                    ? Color(hex: "1A1A2E")
                                    : (isPast ? Color(hex: "1A1A2E").opacity(0.4) : Color(hex: "1A1A2E").opacity(0.85))
                            )
                        
                        if isActive {
                            Circle()
                                .fill(Color.nurGold)
                                .frame(width: 6, height: 6)
                        }
                    }
                    
                    Text(prayer.arabicText)
                        .font(.custom("Amiri-Regular", size: 12))
                        .foregroundColor(
                            isActive
                                ? Color.nurGold.opacity(0.85)
                                : (isPast ? Color(hex: "1A1A2E").opacity(0.25) : Color(hex: "1A1A2E").opacity(0.45))
                        )
                }
                
                Spacer()
                
                // Sağ: Saat + Durum / Bildirim Butonu
                HStack(spacing: 10) {
                    VStack(alignment: .trailing, spacing: 3) {
                        Text(timeFormatter.string(from: time))
                            .nurFont(17, weight: .bold, design: .rounded)
                            .foregroundColor(
                                isActive
                                    ? Color(hex: "1A1A2E")
                                    : (isPast ? Color(hex: "1A1A2E").opacity(0.35) : Color(hex: "1A1A2E").opacity(0.85))
                            )
                        
                        if isPast {
                            HStack(spacing: 3) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 9, weight: .bold))
                                Text(NSLocalizedString("prayer.completed", comment: ""))
                                    .nurFont(9, weight: .bold)
                            }
                            .foregroundColor(Color(hex: "2D8B56").opacity(0.85))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "2D8B56").opacity(0.08))
                            .cornerRadius(6)
                        } else if isActive, let rem = remainingTime {
                            HStack(spacing: 3) {
                                Image(systemName: "timer")
                                    .font(.system(size: 9))
                                Text("\(rem) \(NSLocalizedString("prayer.remaining", comment: ""))")
                                    .nurFont(9, weight: .bold)
                            }
                            .foregroundColor(Color(hex: "A07818"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.nurGold.opacity(0.14))
                            .cornerRadius(6)
                        }
                    }
                    
                    // Bildirim Zili
                    if !isPast {
                        Button(action: {
                            HapticManager.shared.light()
                            onNotificationToggle()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(notificationEnabled ? Color.nurGold.opacity(0.14) : Color(hex: "1A1A2E").opacity(0.04))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: notificationEnabled ? "bell.fill" : "bell")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(notificationEnabled ? .nurGold : Color(hex: "1A1A2E").opacity(0.3))
                            }
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Canlı İlerleme Çubuğu (Sadece Aktif Vakit)
            if isActive, let p = progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.nurGold.opacity(0.15))
                            .frame(height: 3.5)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.nurGold, Color(hex: "E5C158")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(8, geo.size.width * CGFloat(p)), height: 3.5)
                            .shadow(color: .nurGold.opacity(0.4), radius: 2)
                    }
                }
                .frame(height: 3.5)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
        .background(
            ZStack {
                if isActive {
                    LinearGradient(
                        colors: [Color.white, Color(hex: "FFFDF5")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else if isPast {
                    Color.white.opacity(0.7)
                } else {
                    Color.white
                }
            }
        )
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isActive
                        ? Color.nurGold.opacity(0.55)
                        : Color(hex: "1A1A2E").opacity(0.05),
                    lineWidth: isActive ? 1.4 : 1
                )
        )
        .shadow(
            color: isActive ? Color.nurGold.opacity(0.12) : Color.black.opacity(0.02),
            radius: isActive ? 10 : 4,
            y: isActive ? 4 : 2
        )
        .padding(.horizontal, 18)
        .padding(.vertical, 3)
        .onAppear {
            if isActive { pulseAnimation = true }
        }
    }
    
    // MARK: - Helpers
    private var iconColor: Color {
        if isPast { return Color(hex: "1A1A2E").opacity(0.35) }
        return Color(hex: "1A1A2E").opacity(0.7)
    }
    
    private var iconBg: Color {
        if isPast { return Color(hex: "1A1A2E").opacity(0.03) }
        if isActive { return Color.nurGold.opacity(0.15) }
        return Color(hex: "1A1A2E").opacity(0.04)
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
    ZStack {
        Color(hex: "F8F6F0").ignoresSafeArea()
        VStack(spacing: 8) {
            PrayerTimeRow(prayer: .fajr, time: Date(), isActive: false, isPast: true, progress: 1.0, remainingTime: nil, notificationEnabled: true, fontSize: .medium, language: .tr) {}
            PrayerTimeRow(prayer: .dhuhr, time: Date(), isActive: true, isPast: false, progress: 0.4, remainingTime: "01:24:33", notificationEnabled: true, fontSize: .medium, language: .tr) {}
            PrayerTimeRow(prayer: .asr, time: Date(), isActive: false, isPast: false, progress: 0.0, remainingTime: nil, notificationEnabled: false, fontSize: .medium, language: .tr) {}
        }
        .padding()
    }
}
