import SwiftUI

struct PrayerTimeRow: View {
    let prayer: PrayerName
    let time: Date
    let isActive: Bool        // Şu anki vakit
    let isPast: Bool          // Geçmiş vakit
    let notificationEnabled: Bool
    let fontSize: FontSize
    let language: LanguageCode
    let onNotificationToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Sol: İkon
            ZStack {
                Circle()
                    .fill(prayer.startColor.opacity(isActive ? 0.3 : 0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: prayer.symbol)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isActive ? .nurGold : prayer.startColor)
            }
            
            // Orta: İsimler
            VStack(alignment: .leading, spacing: 2) {
                Text(prayer.localizedName(for: language))
                    .nurFont(fontSize.body, weight: .bold)
                    .foregroundColor(isActive ? .nurGold : .white)
                
                Text(prayer.arabicText)
                    .nurFont(fontSize.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Sağ: Saat ve Zil
            HStack(spacing: 8) {
                Text(timeFormatter.string(from: time))
                    .nurFont(20, weight: .bold, design: .monospaced)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(1)
                
                Button(action: onNotificationToggle) {
                    Image(systemName: notificationEnabled ? "bell.fill" : "bell.slash")
                        .foregroundColor(notificationEnabled ? .nurGold : .white.opacity(0.4))
                        .font(.system(size: 16))
                }
                .padding(4)
                // Bildirim butonu accessibility
                .accessibilityLabel("\(prayer.localizedName(for: language)) bildirimi \(notificationEnabled ? "açık" : "kapalı")")
                .accessibilityHint(notificationEnabled ? "Çift dokunarak bildirimi kapat" : "Çift dokunarak bildirimi aç")
                .accessibilityAddTraits(.isButton)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(minHeight: 56)
        .background(isActive ? Color.nurGold.opacity(0.12) : Color.clear)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isActive ? Color.nurGold.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .opacity(isPast ? 0.45 : 1.0)
        .environment(\.layoutDirection, language.isRTL ? .rightToLeft : .leftToRight)
        // ── Satır accessibility ────────────────────────────────────
        .accessibilityElement(children: .combine)
        .accessibilityLabel(rowAccessibilityLabel)
        .accessibilityValue(isActive ? "Aktif vakit" : isPast ? "Geçmiş vakit" : "Gelecek vakit")
    }
    
    private var rowAccessibilityLabel: String {
        let timePart = timeFormatter.string(from: time)
        return "\(prayer.localizedName(for: language)), \(timePart)"
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
        PrayerTimeRow(prayer: .fajr, time: Date(), isActive: false, isPast: true, notificationEnabled: true, fontSize: .medium, language: .tr) {}
        PrayerTimeRow(prayer: .dhuhr, time: Date(), isActive: true, isPast: false, notificationEnabled: true, fontSize: .large, language: .tr) {}
        PrayerTimeRow(prayer: .asr, time: Date(), isActive: false, isPast: false, notificationEnabled: false, fontSize: .medium, language: .ar) {}
    }
    .padding()
    .background(Color.black)
}
