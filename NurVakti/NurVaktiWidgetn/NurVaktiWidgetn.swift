//
//  NurVaktiWidgetn.swift
//  NurVaktiWidgetn
//
//  Created by Yakup Suda on 7.08.2026.
//

import WidgetKit
import SwiftUI

// MARK: - Color Helpers (Widget Extension can't access main app's Color extensions)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
    
    static let widgetBgTop    = Color(hex: "0D1B2A")
    static let widgetBgBot    = Color(hex: "1C2541")
    static let widgetGold     = Color(hex: "C9A84C")
    static let widgetTeal     = Color(hex: "2DD4A8")
    static let widgetCardBg   = Color(hex: "162038")
}

// MARK: - Prayer Icon Helper
struct PrayerIcon {
    static func icon(for nameEn: String) -> String {
        switch nameEn.lowercased() {
        case "imsak":   return "moon.haze.fill"
        case "fajr":    return "sunrise.fill"
        case "sunrise":  return "sun.horizon.fill"
        case "dhuhr":   return "sun.max.fill"
        case "asr":     return "cloud.sun.fill"
        case "maghrib": return "sunset.fill"
        case "isha":    return "moon.stars.fill"
        default:        return "clock.fill"
        }
    }
    
    static func iconColor(for nameEn: String) -> Color {
        switch nameEn.lowercased() {
        case "imsak":   return Color(hex: "94A3B8")
        case "fajr":    return Color(hex: "FCA5A5")
        case "sunrise": return Color(hex: "FDE68A")
        case "dhuhr":   return Color(hex: "FBBF24")
        case "asr":     return Color(hex: "60A5FA")
        case "maghrib": return Color(hex: "F97316")
        case "isha":    return Color(hex: "A78BFA")
        default:        return .white
        }
    }
}

// MARK: - Timeline Entry
struct PrayerWidgetEntry: TimelineEntry {
    let date: Date
    let data: NurWidgetData?
    
    static var placeholder: PrayerWidgetEntry {
        let now = Date()
        return PrayerWidgetEntry(date: now, data: NurWidgetData(
            nextPrayerName: "Akşam",
            nextPrayerNameEn: "Maghrib",
            nextPrayerTime: Calendar.current.date(byAdding: .minute, value: 33, to: now)!,
            allPrayers: [
                WidgetPrayerEntry(name: "İmsak",  nameEn: "Imsak",   time: Calendar.current.date(byAdding: .hour, value: -10, to: now)!, isNext: false, isPast: true),
                WidgetPrayerEntry(name: "Güneş",  nameEn: "Sunrise", time: Calendar.current.date(byAdding: .hour, value: -8, to: now)!,  isNext: false, isPast: true),
                WidgetPrayerEntry(name: "Öğle",   nameEn: "Dhuhr",   time: Calendar.current.date(byAdding: .hour, value: -3, to: now)!,  isNext: false, isPast: true),
                WidgetPrayerEntry(name: "İkindi", nameEn: "Asr",     time: Calendar.current.date(byAdding: .hour, value: -1, to: now)!,  isNext: false, isPast: true),
                WidgetPrayerEntry(name: "Akşam",  nameEn: "Maghrib", time: Calendar.current.date(byAdding: .minute, value: 33, to: now)!, isNext: true,  isPast: false),
                WidgetPrayerEntry(name: "Yatsı",  nameEn: "Isha",    time: Calendar.current.date(byAdding: .hour, value: 3, to: now)!,   isNext: false, isPast: false),
            ],
            cityName: "Menderes, İzmir",
            hijriDateString: "15 Safer 1448",
            languageCode: "tr",
            lastUpdated: now
        ))
    }
}

// MARK: - Timeline Provider
struct PrayerTimelineProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> PrayerWidgetEntry {
        .placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PrayerWidgetEntry) -> Void) {
        let data = NurWidgetData.load()
        completion(PrayerWidgetEntry(date: Date(), data: data ?? PrayerWidgetEntry.placeholder.data))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerWidgetEntry>) -> Void) {
        let data = NurWidgetData.load()
        let now = Date()
        let entry = PrayerWidgetEntry(date: now, data: data)
        
        // Sonraki vakitte güncelle, yoksa 15 dakika sonra
        let nextRefresh = data?.nextPrayerTime ?? Calendar.current.date(byAdding: .minute, value: 15, to: now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }
}

// MARK: - Widget Configuration
struct NurVaktiWidgetn: Widget {
    let kind: String = "NurVaktiPrayerTimes"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimelineProvider()) { entry in
            PrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Namaz Vakitleri")
        .description("Namaz vakitlerini ve geri sayımı ana ekranınızdan takip edin.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryCircular
        ])
    }
}

// MARK: - Entry View Router
struct PrayerWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: PrayerWidgetEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallPrayerWidget(entry: entry)
        case .systemMedium:
            MediumPrayerWidget(entry: entry)
        case .accessoryRectangular:
            LockRectangularWidget(entry: entry)
        case .accessoryCircular:
            LockCircularWidget(entry: entry)
        default:
            SmallPrayerWidget(entry: entry)
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - SMALL WIDGET (2×2)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct SmallPrayerWidget: View {
    let entry: PrayerWidgetEntry
    
    private var data: NurWidgetData? { entry.data }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.widgetBgTop, Color.widgetBgBot],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 0) {
                // Top — City
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.widgetGold.opacity(0.7))
                    Text(data?.cityName ?? "NurVakti")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Next Prayer Name
                Text(nextPrayerLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                
                Text(data?.nextPrayerName ?? "--")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 1)
                
                // Countdown
                if let time = data?.nextPrayerTime {
                    Text(time, style: .timer)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.widgetGold)
                        .monospacedDigit()
                        .padding(.top, 2)
                }
                
                Spacer().frame(height: 4)
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.widgetBgTop, Color.widgetBgBot],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var nextPrayerLabel: String {
        let lang = data?.languageCode ?? "tr"
        switch lang {
        case "ar": return "الصلاة القادمة"
        case "en": return "Next Prayer"
        case "de": return "Nächstes Gebet"
        default:   return "Sonraki Vakit"
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - MEDIUM WIDGET (4×2) — Resimdeki Tasarım
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct MediumPrayerWidget: View {
    let entry: PrayerWidgetEntry
    
    private var data: NurWidgetData? { entry.data }
    private var prayers: [WidgetPrayerEntry] { data?.allPrayers ?? [] }
    
    // Time formatter
    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.widgetBgTop, Color(hex: "0F1B30")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 0) {
                // ── SOL: Sonraki Vakit + Geri Sayım ──
                leftPanel
                
                // ── Dikey Ayırıcı ──
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.02), Color.white.opacity(0.08), Color.white.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1)
                    .padding(.vertical, 8)
                
                // ── SAĞ: Tüm Vakitler ──
                rightPanel
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.widgetBgTop, Color(hex: "0F1B30")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: Left Panel
    private var leftPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            // Prayer name (what we're counting to)
            Text(data?.nextPrayerName ?? "--")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            // Countdown timer — large and prominent
            if let time = data?.nextPrayerTime {
                Text(time, style: .timer)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .monospacedDigit()
                    .padding(.top, 2)
                    .minimumScaleFactor(0.7)
            }
            
            Spacer()
            
            // City name
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.widgetGold.opacity(0.6))
                Text(data?.cityName ?? "")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxHeight: .infinity)
    }
    
    // MARK: Right Panel — All Prayer Times
    private var rightPanel: some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(prayers) { prayer in
                prayerRow(prayer)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxHeight: .infinity)
    }
    
    // MARK: Individual Prayer Row
    @ViewBuilder
    private func prayerRow(_ prayer: WidgetPrayerEntry) -> some View {
        let isActive = prayer.isNext
        
        HStack(spacing: 6) {
            // Prayer icon
            Image(systemName: PrayerIcon.icon(for: prayer.nameEn))
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(isActive ? .widgetTeal : PrayerIcon.iconColor(for: prayer.nameEn).opacity(prayer.isPast ? 0.4 : 0.8))
                .frame(width: 14)
            
            // Prayer name
            Text(prayer.name)
                .font(.system(size: 12, weight: isActive ? .bold : .medium))
                .foregroundColor(isActive ? .widgetTeal : (prayer.isPast ? .white.opacity(0.35) : .white.opacity(0.8)))
                .lineLimit(1)
            
            Spacer()
            
            // Time
            Text(timeFormatter.string(from: prayer.time))
                .font(.system(size: 12, weight: isActive ? .bold : .medium, design: .monospaced))
                .foregroundColor(isActive ? .widgetTeal : (prayer.isPast ? .white.opacity(0.3) : .white.opacity(0.7)))
                .monospacedDigit()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            isActive
                ? RoundedRectangle(cornerRadius: 8)
                    .fill(Color.widgetTeal.opacity(0.12))
                : nil
        )
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - LOCK SCREEN — Rectangular
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct LockRectangularWidget: View {
    let entry: PrayerWidgetEntry
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "moon.stars.fill")
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.data?.nextPrayerName ?? "--")
                    .font(.caption.weight(.bold))
                
                if let time = entry.data?.nextPrayerTime {
                    Text(time, style: .timer)
                        .font(.caption2)
                        .monospacedDigit()
                }
            }
            
            Spacer()
        }
        .containerBackground(for: .widget) { Color.clear }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - LOCK SCREEN — Circular
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct LockCircularWidget: View {
    let entry: PrayerWidgetEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            VStack(spacing: 1) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 12))
                
                if let time = entry.data?.nextPrayerTime {
                    Text(time, style: .timer)
                        .font(.system(size: 9, design: .monospaced))
                        .monospacedDigit()
                }
            }
        }
        .containerBackground(for: .widget) { Color.clear }
    }
}

// MARK: - Previews
#Preview(as: .systemSmall) {
    NurVaktiWidgetn()
} timeline: {
    PrayerWidgetEntry.placeholder
}

#Preview(as: .systemMedium) {
    NurVaktiWidgetn()
} timeline: {
    PrayerWidgetEntry.placeholder
}
