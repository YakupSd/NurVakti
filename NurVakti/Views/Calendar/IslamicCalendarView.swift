import SwiftUI

struct IslamicCalendarView: View {
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.dismiss) var dismiss
    @State private var events: [(event: IslamicEvent, date: Date)] = []
    @State private var todayEvent: IslamicEvent? = nil
    @State private var activeMessagesEvent: IslamicEvent? = nil
    
    private let hijriCal = Calendar(identifier: .islamicCivil)
    
    // Bugünün hicri bileşenleri
    private var hijriComponents: DateComponents {
        hijriCal.dateComponents([.year, .month, .day], from: Date())
    }
    
    private var gregorianDateString: String {
        let formatter = DateFormatter()
        formatter.locale = localization.currentLanguage.locale
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // ── Close / Dismiss Header Bar ──
                    HStack {
                        Spacer()
                        Button(action: {
                            HapticManager.shared.light()
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.35))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // ── Hicri Tarih Büyük Badge ────────────────────────
                    hijriDateHeader
                    
                    // ── Bugünkü Özel Gün Banner ────────────────────────
                    if let today = todayEvent {
                        todayEventBanner(today)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                    
                    // ── Yaklaşan Etkinlikler Başlığı ───────────────────
                    HStack {
                        Rectangle()
                            .fill(Color.nurGold.opacity(0.5))
                            .frame(width: 4, height: 18)
                            .cornerRadius(2)
                        Text(localization.localizedString("calendar.upcoming"))
                            .nurFont(13, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                            .tracking(1.5)
                            .textCase(.uppercase)
                        Spacer()
                        Text("\(events.count) \(localization.localizedString("calendar.event"))")
                            .nurFont(12)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.4))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                    
                    // ── Etkinlik Listesi ───────────────────────────────
                    if events.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.2))
                            Text(localization.localizedString("calendar.noEvents"))
                                .nurFont(15)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.4))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(events, id: \.event.key) { item in
                                eventCard(item: item)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    Spacer(minLength: 60)
                }
            }
        }
        .sheet(item: $activeMessagesEvent) { ev in
            spiritualMessagesSheet(for: ev)
        }
        .onAppear {
            events = IslamicCalendarService.shared.upcomingEvents(within: 365)
            todayEvent = IslamicCalendarService.shared.todayEvent()
        }
    }
    
    @ViewBuilder
    private func spiritualMessagesSheet(for event: IslamicEvent) -> some View {
        switch event.key {
        case .mevlidNebevi:
            SpiritualMessagesView(initialCategory: .kandil, initialKandilSub: .mevlid)
        case .regaipKandili:
            SpiritualMessagesView(initialCategory: .kandil, initialKandilSub: .regaip)
        case .miracKandili:
            SpiritualMessagesView(initialCategory: .kandil, initialKandilSub: .mirac)
        case .beratKandili:
            SpiritualMessagesView(initialCategory: .kandil, initialKandilSub: .berat)
        case .laylatalQadr:
            SpiritualMessagesView(initialCategory: .kandil, initialKandilSub: .kadir)
        case .eidAlFitr:
            SpiritualMessagesView(initialCategory: .bayram, initialBayramSub: .ramadan)
        case .eidAlAdha:
            SpiritualMessagesView(initialCategory: .bayram, initialBayramSub: .eidAlAdha)
        case .arafaDay:
            SpiritualMessagesView(initialCategory: .bayram, initialBayramSub: .arafah)
        default:
            SpiritualMessagesView(initialCategory: .specialDays)
        }
    }
    
    // MARK: - Hicri Tarih Header
    @ViewBuilder
    private var hijriDateHeader: some View {
        VStack(spacing: 16) {
            let monthNumber = hijriComponents.month ?? 1
            let monthName = localization.localizedString("calendar.month.\(monthNumber)")
            let day = hijriComponents.day ?? 0
            let year = hijriComponents.year ?? 0
            
            VStack(spacing: 8) {
                Text(monthName.uppercased())
                    .nurFont(13, weight: .bold)
                    .kerning(3)
                    .foregroundColor(.nurGold)
                
                Text("\(day)")
                    .font(.system(size: 72, weight: .ultraLight, design: .serif))
                    .foregroundColor(Color(hex: "1A1A2E"))
                
                Text("\(year) H.")
                    .nurFont(15)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                
                // Miladi karşılığı
                Text(gregorianDateString)
                    .nurFont(13)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(
                LinearGradient(
                    colors: [Color.nurGold.opacity(0.08), Color.nurGold.opacity(0.03)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                Rectangle()
                    .fill(Color.nurGold.opacity(0.15))
                    .frame(height: 1),
                alignment: .bottom
            )
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Bugünkü Etkinlik Banner
    @ViewBuilder
    private func todayEventBanner(_ event: IslamicEvent) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Text(event.key.emoji)
                    .font(.system(size: 36))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(localization.localizedString("calendar.todaySpecial"))
                        .nurFont(11, weight: .bold)
                        .foregroundColor(.nurGold)
                        .tracking(1.2)
                        .textCase(.uppercase)
                    Text(event.key.name(for: localization.currentLanguage))
                        .nurFont(18, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E"))
                }
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.tap()
                    activeMessagesEvent = event
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "envelope.badge.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text("Tebrikler")
                            .nurFont(11, weight: .bold)
                    }
                    .foregroundColor(Color(hex: "#0E1626"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color.nurGold, Color(hex: "E5C158")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.nurGold.opacity(0.14), Color.nurGold.opacity(0.06)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.nurGold.opacity(0.35), lineWidth: 1.5)
        )
    }
    
    // MARK: - Etkinlik Kartı
    @ViewBuilder
    private func eventCard(item: (event: IslamicEvent, date: Date)) -> some View {
        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: item.date).day ?? 0
        let isToday = daysLeft == 0
        let isSoon = daysLeft <= 7 && daysLeft > 0
        
        Button(action: {
            HapticManager.shared.light()
            activeMessagesEvent = item.event
        }) {
            HStack(spacing: 16) {
                // Tarih badge
                VStack(spacing: 3) {
                    Text(item.date.formatted(.dateTime.day()))
                        .nurFont(22, weight: .bold)
                    Text(item.date.formatted(.dateTime.month(.abbreviated)).uppercased())
                        .nurFont(10, weight: .medium)
                        .tracking(0.5)
                }
                .frame(width: 62, height: 62)
                .background(isToday ? Color.nurGold : (isSoon ? Color.nurGold.opacity(0.2) : Color(hex: "1A1A2E").opacity(0.06)))
                .foregroundColor(isToday ? .black : (isSoon ? .nurGold : Color(hex: "1A1A2E")))
                .cornerRadius(16)
                
                // İçerik
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text(item.event.key.emoji)
                            .font(.system(size: 16))
                        Text(item.event.key.name(for: localization.currentLanguage))
                            .nurFont(15, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                    }
                    
                    if isToday {
                        Text(localization.localizedString("calendar.today"))
                            .nurFont(12, weight: .bold)
                            .foregroundColor(.nurGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.nurGold.opacity(0.12))
                            .cornerRadius(6)
                    } else {
                        let suffix = localization.currentLanguage == .tr ? "gün kaldı" :
                                     localization.currentLanguage == .en ? "days left" :
                                     localization.currentLanguage == .de ? "Tage übrig" :
                                     localization.currentLanguage == .ar ? "أيام متبقية" : "dias restantes"
                        Text("\(daysLeft) \(suffix)")
                            .nurFont(12)
                            .foregroundColor(isSoon ? .nurGold : Color(hex: "1A1A2E").opacity(0.45))
                    }
                }
                
                Spacer()
                
                // Kandil gece mi badge & Tebrik oku
                HStack(spacing: 6) {
                    if item.event.key.isSpecialNight {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.nurGold.opacity(0.7))
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.25))
                }
            }
            .padding(16)
            .background(isToday ? Color.nurGold.opacity(0.06) : Color(hex: "1A1A2E").opacity(0.04))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isToday ? Color.nurGold.opacity(0.35) : Color(hex: "1A1A2E").opacity(0.07), lineWidth: isToday ? 1.5 : 1)
            )
        }
        .buttonStyle(BouncyButtonStyle())
    }
}

// MARK: - Safe Array subscript
private extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}
