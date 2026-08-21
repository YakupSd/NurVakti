//
//  NurVaktiWidgetn.swift
//  NurVaktiWidgetn
//
//  Created by Yakup Suda on 7.08.2026.
//

import WidgetKit
import SwiftUI

// MARK: - Light Luxury Color System for Widget Extension
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
    
    // Warm Cream & Imperial Gold Luxury Light Palette
    static let widgetBgTop     = Color(hex: "FFFDF9") // Warm Pearlescent Silk
    static let widgetBgBot     = Color(hex: "F3EDE3") // Soft Ivory
    static let widgetGold      = Color(hex: "8A5A00") // Deep Imperial Gold
    static let widgetGoldLight = Color(hex: "D4AF37") // Radiant Gold
    static let widgetTextDark  = Color(hex: "1A1A2E") // Deep Slate Charcoal
    static let widgetTextMuted = Color(hex: "64748B") // Slate Gray
    static let widgetCardBg    = Color.white
    static let widgetBorder    = Color(hex: "1A1A2E").opacity(0.08)
}

// MARK: - Prayer Icon & Calligraphy Helper
struct PrayerIcon {
    static func icon(for nameEn: String) -> String {
        switch nameEn.lowercased() {
        case "imsak":   return "moon.haze.fill"
        case "fajr":    return "sunrise.fill"
        case "sunrise": return "sun.horizon.fill"
        case "dhuhr":   return "sun.max.fill"
        case "asr":     return "cloud.sun.fill"
        case "maghrib": return "sunset.fill"
        case "isha":    return "moon.stars.fill"
        default:        return "clock.fill"
        }
    }
    
    static func arabic(for nameEn: String) -> String {
        switch nameEn.lowercased() {
        case "imsak":   return "الإمساك"
        case "fajr":    return "الفجر"
        case "sunrise": return "الشروق"
        case "dhuhr":   return "الظهر"
        case "asr":     return "العصر"
        case "maghrib": return "المغرب"
        case "isha":    return "العشاء"
        default:        return ""
        }
    }
    
    static func iconColor(for nameEn: String) -> Color {
        switch nameEn.lowercased() {
        case "imsak":   return Color(hex: "64748B")
        case "fajr":    return Color(hex: "E11D48")
        case "sunrise": return Color(hex: "D97706")
        case "dhuhr":   return Color(hex: "D97706")
        case "asr":     return Color(hex: "2563EB")
        case "maghrib": return Color(hex: "EA580C")
        case "isha":    return Color(hex: "7C3AED")
        default:        return Color(hex: "8A5A00")
        }
    }
}

// MARK: - Widget Localization Helper
func nextPrayerLabel(for langCode: String) -> String {
    switch langCode.lowercased() {
    case "tr": return "SIRADAKİ VAKİT"
    case "en": return "NEXT PRAYER"
    case "ar": return "الصلاة التالية"
    case "de": return "NÄCHSTES GEBET"
    case "pt": return "PRÓXIMA ORAÇÃO"
    default:   return "NEXT PRAYER"
    }
}

// MARK: - Timeline Entry
struct PrayerWidgetEntry: TimelineEntry {
    let date: Date
    let data: NurWidgetData?
    
    static var placeholder: PrayerWidgetEntry {
        let now = Date()
        return PrayerWidgetEntry(date: now, data: NurWidgetData.fallbackData())
    }
}

// MARK: - Dynamic Multi-Day Timeline Provider
struct PrayerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerWidgetEntry {
        .placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PrayerWidgetEntry) -> Void) {
        let loaded = NurWidgetData.load() ?? NurWidgetData.fallbackData()
        let now = Date()
        completion(PrayerWidgetEntry(date: now, data: loaded.dataForDate(now)))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerWidgetEntry>) -> Void) {
        let loaded = NurWidgetData.load() ?? NurWidgetData.fallbackData()
        let now = Date()
        let cal = Calendar.current
        
        var entries: [PrayerWidgetEntry] = []
        
        // 1. Current entry for right now
        entries.append(PrayerWidgetEntry(date: now, data: loaded.dataForDate(now)))
        
        // 2. Çok günlük havuzdaki tüm vakitleri topla
        var allChronological: [WidgetPrayerEntry] = []
        if let days = loaded.days, !days.isEmpty {
            allChronological = days.flatMap { $0.prayers }.sorted { $0.time < $1.time }
        } else {
            allChronological = loaded.allPrayers.sorted { $0.time < $1.time }
        }
        
        // 3. Önümüzdeki 48 saatlik ufuk içindeki her vakit geçiş anı için entry ekle
        let horizon = now.addingTimeInterval(48 * 3600)
        let futurePrayers = allChronological.filter { $0.time > now && $0.time <= horizon }
        
        for prayer in futurePrayers {
            // Vakit giriş anında ve hemen sonrasında güncel veriyi hesapla
            let switchTime = prayer.time.addingTimeInterval(1)
            let entryData = loaded.dataForDate(switchTime)
            entries.append(PrayerWidgetEntry(date: prayer.time, data: entryData))
        }
        
        // 4. Gece yarısı geçişleri için (00:00:01) entry ekle (gün ve Hicri takvim değişimi)
        for dayOffset in 1...2 {
            if let midnight = cal.date(byAdding: .day, value: dayOffset, to: cal.startOfDay(for: now)) {
                let midnightSwitch = midnight.addingTimeInterval(1)
                if midnightSwitch > now && midnightSwitch <= horizon {
                    let entryData = loaded.dataForDate(midnightSwitch)
                    entries.append(PrayerWidgetEntry(date: midnightSwitch, data: entryData))
                }
            }
        }
        
        // Tarihe göre sırala
        entries.sort { $0.date < $1.date }
        
        // Refresh policy: son entry'den 30 dk sonra veya en geç 2 saat sonra
        let nextRefresh = entries.last?.date.addingTimeInterval(1800) ?? now.addingTimeInterval(3600 * 2)
        let timeline = Timeline(entries: entries, policy: .after(nextRefresh))
        completion(timeline)
    }
}

// MARK: - Widget Configuration
struct NurVaktiWidgetn: Widget {
    let kind: String = "NurVaktiPrayerTimes"
    
    private var displayName: String {
        let lang = Locale.preferredLanguages.first?.prefix(2) ?? "en"
        switch lang {
        case "tr": return "NurVakti Vakitler"
        case "ar": return "أوقات الصلاة NurVakti"
        case "de": return "NurVakti Gebetszeiten"
        case "pt": return "NurVakti Horários"
        default:   return "NurVakti Prayer Times"
        }
    }
    
    private var displayDescription: String {
        let lang = Locale.preferredLanguages.first?.prefix(2) ?? "en"
        switch lang {
        case "tr": return "Namaz vakitlerini ve geri sayımı takip edin."
        case "ar": return "تتبع أوقات الصلاة والعد التنازلي."
        case "de": return "Verfolgen Sie Gebetszeiten und den Countdown."
        case "pt": return "Acompanhe os horários de oração e a contagem regressiva."
        default:   return "Track prayer times and countdown."
        }
    }
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimelineProvider()) { entry in
            PrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(displayName)
        .description(displayDescription)
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
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
        case .systemLarge:
            LargePrayerWidget(entry: entry)
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
// MARK: - SMALL WIDGET (2×2) — Lüks Açık Krem & Altın
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct SmallPrayerWidget: View {
    let entry: PrayerWidgetEntry
    private var data: NurWidgetData { entry.data ?? NurWidgetData.fallbackData() }
    
    var body: some View {
        ZStack {
            // Background Warm Silk Gradient
            LinearGradient(
                colors: [Color.widgetBgTop, Color.widgetBgBot],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 0) {
                // Top Row: Location & Icon
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.widgetGold)
                    Text(data.cityName.isEmpty ? "NurVakti" : data.cityName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.widgetTextDark)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: PrayerIcon.icon(for: data.nextPrayerNameEn))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(PrayerIcon.iconColor(for: data.nextPrayerNameEn))
                }
                
                Spacer()
                
                // Next Prayer Title & Arabic Calligraphy
                VStack(alignment: .leading, spacing: 1) {
                    Text(nextPrayerLabel(for: data.languageCode))
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(hex: "8A5A00"))
                        .tracking(1.2)
                    
                    HStack(spacing: 6) {
                        Text(data.nextPrayerName)
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.widgetTextDark)
                        
                        let ar = PrayerIcon.arabic(for: data.nextPrayerNameEn)
                        if !ar.isEmpty {
                            Text(ar)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.widgetGold)
                        }
                    }
                }
                
                Spacer().frame(height: 4)
                
                // Live Dynamic Countdown Timer with Past-Date Guard
                if data.nextPrayerTime > entry.date {
                    Text(data.nextPrayerTime, style: .timer)
                        .font(.system(size: 26, weight: .black, design: .monospaced))
                        .foregroundColor(Color(hex: "8A5A00"))
                        .monospacedDigit()
                } else {
                    Text("00:00:00")
                        .font(.system(size: 26, weight: .black, design: .monospaced))
                        .foregroundColor(Color(hex: "8A5A00"))
                        .monospacedDigit()
                }
            }
            .padding(14)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.widgetBgTop, Color.widgetBgBot],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - MEDIUM WIDGET (4×2) — Lüks Açık Krem & Altın
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct MediumPrayerWidget: View {
    let entry: PrayerWidgetEntry
    private var data: NurWidgetData { entry.data ?? NurWidgetData.fallbackData() }
    private var prayers: [WidgetPrayerEntry] { data.allPrayers.isEmpty ? NurWidgetData.fallbackData().allPrayers : data.allPrayers }
    
    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }
    
    var body: some View {
        ZStack {
            // Background Warm Silk Gradient
            LinearGradient(
                colors: [Color.widgetBgTop, Color.widgetBgBot],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 0) {
                // ── SOL: Sıradaki Vakit + Canlı Geri Sayım ──
                leftPanel
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // ── Dikey Zarif Ayırıcı ──
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.widgetGold.opacity(0.25), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1)
                    .padding(.vertical, 8)
                
                // ── SAĞ: 6 Vakit Listesi ──
                rightPanel
                    .frame(width: 175)
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.widgetBgTop, Color.widgetBgBot],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: Left Panel
    private var leftPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Location & Pin
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.widgetGold)
                Text(data.cityName.isEmpty ? "NurVakti" : data.cityName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.widgetTextDark)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Next Prayer Tag & Icon
            HStack(spacing: 5) {
                Image(systemName: PrayerIcon.icon(for: data.nextPrayerNameEn))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(PrayerIcon.iconColor(for: data.nextPrayerNameEn))
                
                Text(data.nextPrayerName)
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.widgetTextDark)
            }
            
            // Live Dynamic Countdown Timer with Past-Date Guard
            if data.nextPrayerTime > entry.date {
                Text(data.nextPrayerTime, style: .timer)
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundColor(Color(hex: "8A5A00"))
                    .monospacedDigit()
                    .minimumScaleFactor(0.75)
                    .padding(.top, 2)
            } else {
                Text("00:00:00")
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundColor(Color(hex: "8A5A00"))
                    .monospacedDigit()
                    .minimumScaleFactor(0.75)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            // Hijri Date Footer
            if !data.hijriDateString.isEmpty {
                Text(data.hijriDateString)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "8A5A00"))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
    
    // MARK: Right Panel — 6 Prayer Times
    private var rightPanel: some View {
        VStack(spacing: 2) {
            ForEach(prayers) { prayer in
                prayerRow(prayer)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
    
    // MARK: Individual Prayer Row
    @ViewBuilder
    private func prayerRow(_ prayer: WidgetPrayerEntry) -> some View {
        let isActive = prayer.isNext
        
        HStack(spacing: 6) {
            Image(systemName: PrayerIcon.icon(for: prayer.nameEn))
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(isActive ? Color(hex: "8A5A00") : (prayer.isPast ? Color.widgetTextMuted.opacity(0.4) : Color.widgetTextMuted))
                .frame(width: 12)
            
            Text(prayer.name)
                .font(.system(size: 11, weight: isActive ? .bold : .medium))
                .foregroundColor(isActive ? Color(hex: "1A1A2E") : (prayer.isPast ? Color.widgetTextMuted.opacity(0.5) : Color.widgetTextDark))
                .lineLimit(1)
            
            Spacer()
            
            Text(timeFormatter.string(from: prayer.time))
                .font(.system(size: 11, weight: isActive ? .heavy : .semibold, design: .monospaced))
                .foregroundColor(isActive ? Color(hex: "8A5A00") : (prayer.isPast ? Color.widgetTextMuted.opacity(0.5) : Color.widgetTextDark.opacity(0.85)))
                .monospacedDigit()
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(
            Group {
                if isActive {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "D4AF37").opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "D4AF37").opacity(0.5), lineWidth: 1)
                        )
                } else {
                    Color.clear
                }
            }
        )
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - LARGE WIDGET (4×4) — Kapsamlı Vakit
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct LargePrayerWidget: View {
    let entry: PrayerWidgetEntry
    private var data: NurWidgetData { entry.data ?? NurWidgetData.fallbackData() }
    private var prayers: [WidgetPrayerEntry] { data.allPrayers.isEmpty ? NurWidgetData.fallbackData().allPrayers : data.allPrayers }
    
    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.widgetBgTop, Color.widgetBgBot],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 12) {
                // Top Header Row
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.widgetGold)
                            .font(.system(size: 12, weight: .bold))
                        Text("NurVakti")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.widgetTextDark)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.widgetGold)
                        Text(data.cityName.isEmpty ? "NurVakti" : data.cityName)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.widgetTextDark)
                    }
                }
                
                // Hero Countdown Card
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(nextPrayerLabel(for: data.languageCode))
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(hex: "8A5A00"))
                            .tracking(1.2)
                        
                        HStack(spacing: 6) {
                            Text(data.nextPrayerName)
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(.widgetTextDark)
                            
                            let ar = PrayerIcon.arabic(for: data.nextPrayerNameEn)
                            if !ar.isEmpty {
                                Text(ar)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.widgetGold)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if data.nextPrayerTime > entry.date {
                        Text(data.nextPrayerTime, style: .timer)
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(Color(hex: "8A5A00"))
                            .monospacedDigit()
                    } else {
                        Text("00:00:00")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(Color(hex: "8A5A00"))
                            .monospacedDigit()
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "D4AF37").opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
                )
                
                // Prayer Times Grid (2 Columns)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                    ForEach(prayers) { prayer in
                        let isActive = prayer.isNext
                        HStack {
                            Image(systemName: PrayerIcon.icon(for: prayer.nameEn))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(isActive ? Color(hex: "8A5A00") : Color.widgetTextMuted)
                            
                            Text(prayer.name)
                                .font(.system(size: 12, weight: isActive ? .bold : .medium))
                                .foregroundColor(isActive ? Color.widgetTextDark : (prayer.isPast ? Color.widgetTextMuted.opacity(0.5) : Color.widgetTextDark))
                            
                            Spacer()
                            
                            Text(timeFormatter.string(from: prayer.time))
                                .font(.system(size: 12, weight: isActive ? .heavy : .semibold, design: .monospaced))
                                .foregroundColor(isActive ? Color(hex: "8A5A00") : (prayer.isPast ? Color.widgetTextMuted.opacity(0.5) : Color.widgetTextDark.opacity(0.85)))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isActive ? Color(hex: "D4AF37").opacity(0.2) : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isActive ? Color(hex: "D4AF37").opacity(0.5) : Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                                )
                        )
                    }
                }
                
                // Footer: Hijri Date
                if !data.hijriDateString.isEmpty {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 9))
                            .foregroundColor(.widgetGold)
                        Text(data.hijriDateString)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "8A5A00"))
                        Spacer()
                    }
                    .padding(.top, 2)
                }
            }
            .padding(14)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.widgetBgTop, Color.widgetBgBot],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - LOCK SCREEN — Rectangular
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
struct LockRectangularWidget: View {
    let entry: PrayerWidgetEntry
    private var data: NurWidgetData { entry.data ?? NurWidgetData.fallbackData() }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: PrayerIcon.icon(for: data.nextPrayerNameEn))
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(data.nextPrayerName)
                        .font(.caption.weight(.bold))
                    
                    Text("·")
                    
                    Text(data.cityName.isEmpty ? "NurVakti" : data.cityName)
                        .font(.caption2)
                        .lineLimit(1)
                }
                
                if data.nextPrayerTime > entry.date {
                    Text(data.nextPrayerTime, style: .timer)
                        .font(.caption.weight(.heavy))
                        .monospacedDigit()
                } else {
                    Text("00:00:00")
                        .font(.caption.weight(.heavy))
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
    private var data: NurWidgetData { entry.data ?? NurWidgetData.fallbackData() }
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            VStack(spacing: 1) {
                Image(systemName: PrayerIcon.icon(for: data.nextPrayerNameEn))
                    .font(.system(size: 13, weight: .bold))
                
                Text(data.nextPrayerName)
                    .font(.system(size: 8, weight: .bold))
                
                if data.nextPrayerTime > entry.date {
                    Text(data.nextPrayerTime, style: .timer)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .monospacedDigit()
                } else {
                    Text("00:00")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
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

#Preview(as: .systemLarge) {
    NurVaktiWidgetn()
} timeline: {
    PrayerWidgetEntry.placeholder
}
