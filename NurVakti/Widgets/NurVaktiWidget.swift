import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), prayerName: "Öğle", prayerTime: "13:10")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), prayerName: "İkindi", prayerTime: "16:45")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Gerçekte burada PersistenceService üzerinden vakitleri çekmeliyiz.
        // Ancak Asset/Target kısıtları nedeniyle temel yapıyı kuruyoruz.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, prayerName: "Vakit", prayerTime: "00:00")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let prayerName: String
    let prayerTime: String
}

struct NurVaktiWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color(hex: "0F172A")
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image("AppIcon") // Replace with actual asset if available
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("NurVakti")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.nurGold)
                }
                
                Spacer()
                
                Text(entry.prayerName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(entry.prayerTime)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding()
        }
    }
}

@main
struct NurVaktiWidget: Widget {
    let kind: String = "NurVaktiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NurVaktiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("NurVakti Vakitler")
        .description("Namaz vakitlerini ana ekranından takip et.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
