import WidgetKit
import SwiftUI

// MARK: - Widget Timeline Entry
struct NurWidgetEntry: TimelineEntry {
    let date: Date
    let widgetData: NurWidgetData?
}

// MARK: - Timeline Provider
struct NurWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> NurWidgetEntry {
        NurWidgetEntry(date: Date(), widgetData: sampleData)
    }

    func getSnapshot(in context: Context, completion: @escaping (NurWidgetEntry) -> Void) {
        let entry = NurWidgetEntry(date: Date(), widgetData: NurWidgetData.load() ?? sampleData)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NurWidgetEntry>) -> Void) {
        let data = NurWidgetData.load()
        let now  = Date()
        let entry = NurWidgetEntry(date: now, widgetData: data)

        // Sonraki vakitte yenile
        let nextRefresh = data?.nextPrayerTime ?? Calendar.current.date(byAdding: .minute, value: 15, to: now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    // MARK: - Örnek Veri (Preview & Placeholder)
    private var sampleData: NurWidgetData {
        let now = Date()
        return NurWidgetData(
            nextPrayerName: "Akşam",
            nextPrayerNameEn: "Maghrib",
            nextPrayerTime: Calendar.current.date(byAdding: .hour, value: 2, to: now)!,
            allPrayers: [
                WidgetPrayerEntry(name: "İmsak",  nameEn: "Imsak",   time: Calendar.current.date(byAdding: .hour, value: -10, to: now)!, isNext: false, isPast: true),
                WidgetPrayerEntry(name: "Sabah",  nameEn: "Fajr",    time: Calendar.current.date(byAdding: .hour, value: -9, to: now)!,  isNext: false, isPast: true),
                WidgetPrayerEntry(name: "Öğle",   nameEn: "Dhuhr",   time: Calendar.current.date(byAdding: .hour, value: -3, to: now)!,  isNext: false, isPast: true),
                WidgetPrayerEntry(name: "İkindi", nameEn: "Asr",     time: Calendar.current.date(byAdding: .hour, value: -1, to: now)!,  isNext: false, isPast: true),
                WidgetPrayerEntry(name: "Akşam",  nameEn: "Maghrib", time: Calendar.current.date(byAdding: .hour, value: 2, to: now)!,   isNext: true,  isPast: false),
                WidgetPrayerEntry(name: "Yatsı",  nameEn: "Isha",    time: Calendar.current.date(byAdding: .hour, value: 4, to: now)!,   isNext: false, isPast: false),
            ],
            cityName: "İstanbul",
            hijriDateString: "23 Ramazan 1446",
            languageCode: "tr",
            lastUpdated: now
        )
    }
}

// MARK: - Widget Views
struct NurVaktiWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: NurWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:  SmallWidgetView(entry: entry)
        case .systemMedium: MediumWidgetView(entry: entry)
        case .accessoryRectangular: LockScreenWidgetView(entry: entry)
        case .accessoryCircular: LockScreenCircularView(entry: entry)
        default: SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget (2x2)
struct SmallWidgetView: View {
    var entry: NurWidgetEntry

    var body: some View {
        ZStack {
            // Arka plan
            LinearGradient(colors: [Color(red: 0.05, green: 0.1, blue: 0.2),
                                    Color(red: 0.1, green: 0.2, blue: 0.35)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)

            VStack(alignment: .leading, spacing: 6) {
                // Üst — Ay ikonu + Şehir
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.9, green: 0.75, blue: 0.4))
                    Text(entry.widgetData?.cityName ?? "NurVakti")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer()

                // Orta — Sonraki Vakit Adı
                Text(entry.widgetData?.nextPrayerName ?? "--")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                // Alt — Vakit Saati
                if let time = entry.widgetData?.nextPrayerTime {
                    Text(time, style: .time)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.9, green: 0.75, blue: 0.4))
                }

                // Geri Sayım
                if let time = entry.widgetData?.nextPrayerTime {
                    Text(time, style: .timer)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.55))
                        .monospacedDigit()
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .containerBackground(for: .widget) {
            LinearGradient(colors: [Color(red: 0.05, green: 0.1, blue: 0.2),
                                    Color(red: 0.1, green: 0.2, blue: 0.35)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Medium Widget (4x2)
struct MediumWidgetView: View {
    var entry: NurWidgetEntry

    private var upcomingPrayers: [WidgetPrayerEntry] {
        (entry.widgetData?.allPrayers ?? []).filter { !$0.isPast }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.05, green: 0.1, blue: 0.2),
                                    Color(red: 0.08, green: 0.16, blue: 0.28)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)

            HStack(spacing: 0) {
                // Sol — Sonraki Vakit
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 5) {
                        Image(systemName: "moon.stars.fill")
                            .font(.caption2)
                            .foregroundColor(Color(red: 0.9, green: 0.75, blue: 0.4))
                        Text(entry.widgetData?.cityName ?? "NurVakti")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sonraki Vakit")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                        Text(entry.widgetData?.nextPrayerName ?? "--")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        if let time = entry.widgetData?.nextPrayerTime {
                            Text(time, style: .timer)
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(red: 0.9, green: 0.75, blue: 0.4))
                                .monospacedDigit()
                        }
                    }

                    if let hijri = entry.widgetData?.hijriDateString {
                        Text(hijri)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(14)
                .frame(maxHeight: .infinity)

                // Dikey Ayırıcı
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 1)

                // Sağ — Yaklaşan Vakitler
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(upcomingPrayers.prefix(4)) { prayer in
                        HStack {
                            Text(prayer.name)
                                .font(.system(size: 12, weight: prayer.isNext ? .bold : .regular))
                                .foregroundColor(prayer.isNext ? Color(red: 0.9, green: 0.75, blue: 0.4) : .white.opacity(0.7))
                            Spacer()
                            Text(prayer.time, style: .time)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(prayer.isNext ? Color(red: 0.9, green: 0.75, blue: 0.4) : .white.opacity(0.5))
                        }
                        if prayer != upcomingPrayers.prefix(4).last {
                            Divider().overlay(Color.white.opacity(0.06))
                        }
                    }
                }
                .padding(14)
                .frame(maxHeight: .infinity)
            }
        }
        .containerBackground(for: .widget) {
            Color(red: 0.05, green: 0.1, blue: 0.2)
        }
    }
}

// MARK: - Lock Screen Rectangular (iOS 16+)
struct LockScreenWidgetView: View {
    var entry: NurWidgetEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "moon.stars.fill")
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.widgetData?.nextPrayerName ?? "--")
                    .font(.caption.weight(.bold))
                if let time = entry.widgetData?.nextPrayerTime {
                    Text(time, style: .timer)
                        .font(.caption2)
                        .monospacedDigit()
                }
            }
        }
        .containerBackground(for: .widget) { Color.clear }
    }
}

// MARK: - Lock Screen Circular
struct LockScreenCircularView: View {
    var entry: NurWidgetEntry

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 14))
            if let time = entry.widgetData?.nextPrayerTime {
                Text(time, style: .timer)
                    .font(.system(size: 9, design: .monospaced))
                    .monospacedDigit()
            }
        }
        .containerBackground(for: .widget) { Color.clear }
    }
}

// MARK: - Widget Bundle Entry Point
@main
struct NurVaktiWidgetBundle: WidgetBundle {
    var body: some Widget {
        NurVaktiWidget()
    }
}

struct NurVaktiWidget: Widget {
    let kind = "NurVaktiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NurWidgetProvider()) { entry in
            NurVaktiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("NurVakti")
        .description("Namaz vakitlerini ve geri sayımı gösterir.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryCircular
        ])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    NurVaktiWidget()
} timeline: {
    NurWidgetEntry(date: .now, widgetData: nil)
}

#Preview(as: .systemMedium) {
    NurVaktiWidget()
} timeline: {
    NurWidgetEntry(date: .now, widgetData: nil)
}
