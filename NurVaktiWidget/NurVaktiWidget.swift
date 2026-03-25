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

            // Arka Plan Deseni (Kandil falan varsa)
            if let event = IslamicCalendarService.shared.todayEvent() {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(event.key.emoji)
                            .font(.system(size: 60))
                            .opacity(0.05)
                            .offset(x: 20, y: 20)
                    }
                }
            }

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
                    
                    if let event = IslamicCalendarService.shared.todayEvent() {
                        Text(event.key.name(for: LanguageCode(rawValue: entry.widgetData?.languageCode ?? "tr") ?? .tr))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.nurGold)
                            .lineLimit(1)
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
        DhikrWidget()
        GuidanceWidget()
    }
}

// MARK: - Prayer Times Widget
struct NurVaktiWidget: Widget {
    let kind = "NurVaktiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NurWidgetProvider()) { entry in
            NurVaktiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Namaz Vakitleri")
        .description("Namaz vakitlerini ve geri sayımı gösterir.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline
        ])
    }
}

// MARK: - Dhikr Widget (Zikirmatik)
struct DhikrWidget: Widget {
    let kind = "DhikrWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NurWidgetProvider()) { entry in
            DhikrWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Zikirmatik")
        .description("Aktif zikrinizi ve ilerlemenizi takip edin.")
        .supportedFamilies([
            .systemSmall,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Dhikr Widget Views
struct DhikrWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: NurWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            DhikrSmallView(entry: entry)
        case .accessoryCircular:
            DhikrCircularView(entry: entry)
        case .accessoryRectangular:
            DhikrRectangularView(entry: entry)
        case .accessoryInline:
            Text("\(entry.widgetData?.activeDhikrName ?? "Zikir"): \(entry.widgetData?.activeDhikrCount ?? 0)")
        default:
            DhikrSmallView(entry: entry)
        }
    }
}

struct DhikrSmallView: View {
    var entry: NurWidgetEntry

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.1, green: 0.25, blue: 0.2),
                                    Color(red: 0.05, green: 0.15, blue: 0.1)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "hand.tap.fill")
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.7))
                    Text("Zikirmatik")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                Text(entry.widgetData?.activeDhikrName ?? "Zikir Seçilmedi")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                HStack(alignment: .bottom) {
                    Text("\(entry.widgetData?.activeDhikrCount ?? 0)")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.7))
                    
                    if let target = entry.widgetData?.activeDhikrTarget, target > 0 {
                        Text("/ \(target)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.bottom, 4)
                    }
                }
                
                // Progress Bar
                if let count = entry.widgetData?.activeDhikrCount,
                   let target = entry.widgetData?.activeDhikrTarget, target > 0 {
                    ProgressView(value: Double(count), total: Double(target))
                        .tint(Color(red: 0.4, green: 0.9, blue: 0.7))
                        .background(Color.white.opacity(0.1))
                        .scaleEffect(x: 1, y: 0.5, anchor: .center)
                }
            }
            .padding(14)
        }
        .containerBackground(for: .widget) {
            Color(red: 0.05, green: 0.15, blue: 0.1)
        }
    }
}

struct DhikrCircularView: View {
    var entry: NurWidgetEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text("\(entry.widgetData?.activeDhikrCount ?? 0)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                if let target = entry.widgetData?.activeDhikrTarget, target > 0 {
                    Text("\(target)")
                        .font(.system(size: 8))
                        .opacity(0.6)
                }
            }
        }
        .containerBackground(for: .widget) { Color.clear }
    }
}

struct DhikrRectangularView: View {
    var entry: NurWidgetEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "hand.tap.fill")
                .font(.title2)
            VStack(alignment: .leading, spacing: 0) {
                Text(entry.widgetData?.activeDhikrName ?? "Zikir")
                    .font(.caption.weight(.bold))
                Text("\(entry.widgetData?.activeDhikrCount ?? 0) / \(entry.widgetData?.activeDhikrTarget ?? 0)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            Spacer()
        }
        .containerBackground(for: .widget) { Color.clear }
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

// MARK: - Guidance Widget (Daily Ayat/Hadith)
struct GuidanceWidget: Widget {
    let kind: String = "GuidanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GuidanceProvider()) { entry in
            GuidanceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Günün Kelamı")
        .description("Her gün yeni bir ayet veya hadis ile huzur bulun.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct GuidanceEntry: TimelineEntry {
    let date: Date
    let item: GuidanceItem
    let language: LanguageCode
}

struct GuidanceProvider: TimelineProvider {
    func placeholder(in context: Context) -> GuidanceEntry {
        let lang = LanguageCode(rawValue: Locale.current.language.languageCode?.identifier ?? "tr") ?? .tr
        return GuidanceEntry(date: Date(), item: GuidanceService.shared.getDailyGuidance(for: lang), language: lang)
    }

    func getSnapshot(in context: Context, completion: @escaping (GuidanceEntry) -> Void) {
        let lang = LanguageCode(rawValue: Locale.current.language.languageCode?.identifier ?? "tr") ?? .tr
        let entry = GuidanceEntry(date: Date(), item: GuidanceService.shared.getDailyGuidance(for: lang), language: lang)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GuidanceEntry>) -> Void) {
        let lang = LanguageCode(rawValue: Locale.current.language.languageCode?.identifier ?? "tr") ?? .tr
        let now = Date()
        let entry = GuidanceEntry(date: now, item: GuidanceService.shared.getDailyGuidance(for: lang), language: lang)
        
        // Gece yarısı yenile
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        let nextUpdate = Calendar.current.startOfDay(for: tomorrow)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct GuidanceWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: GuidanceEntry

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.05, green: 0.15, blue: 0.25),
                                    Color(red: 0.02, green: 0.08, blue: 0.15)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: entry.item.type == .ayat ? "quote.bubble.fill" : "person.fill.viewfinder")
                        .foregroundColor(Color.nurGold)
                    Text(entry.item.type == .ayat ? "Günün Ayeti" : "Günün Hadisi")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.nurGold)
                    Spacer()
                }

                Spacer()

                Text(entry.item.text)
                    .font(.system(size: family == .systemLarge ? 20 : 16, weight: .medium))
                    .italic()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(family == .systemLarge ? 10 : 4)
                    .minimumScaleFactor(0.7)

                if let source = entry.item.source {
                    Text(source)
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(16)
        }
        .containerBackground(for: .widget) {
            Color(red: 0.02, green: 0.08, blue: 0.15)
        }
    }
}
