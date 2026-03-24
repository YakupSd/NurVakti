import Foundation
import Combine
import UserNotifications

// MARK: - IslamicCalendarService
// Foundation'ın Calendar.islamicCivil ile özel günleri hesaplar.
// Yaklaşan etkinlikleri bildirimler ile kullanıcıya iletir.

final class IslamicCalendarService: ObservableObject {
    static let shared = IslamicCalendarService()
    private init() {}

    private let islamicCal = Calendar(identifier: .islamicCivil)
    private let gregorianCal = Calendar(identifier: .gregorian)

    // MARK: - Tüm Takvim Olayları
    private let allEvents: [IslamicEvent] = [
        IslamicEvent(key: .regaipKandili, hijriMonth: 7,  hijriDay: 1,  durationDays: 1),
        IslamicEvent(key: .miracKandili,  hijriMonth: 7,  hijriDay: 27, durationDays: 1),
        IslamicEvent(key: .beratKandili,  hijriMonth: 8,  hijriDay: 15, durationDays: 1),
        IslamicEvent(key: .ramadanStart,  hijriMonth: 9,  hijriDay: 1,  durationDays: 30),
        IslamicEvent(key: .laylatalQadr,  hijriMonth: 9,  hijriDay: 27, durationDays: 1),
        IslamicEvent(key: .eidAlFitr,     hijriMonth: 10, hijriDay: 1,  durationDays: 3),
        IslamicEvent(key: .arafaDay,      hijriMonth: 12, hijriDay: 9,  durationDays: 1),
        IslamicEvent(key: .eidAlAdha,     hijriMonth: 12, hijriDay: 10, durationDays: 4),
        IslamicEvent(key: .mevlidNebevi,  hijriMonth: 3,  hijriDay: 12, durationDays: 1),
    ]

    // MARK: - Bugünkü Hicri Yıl
    private var currentHijriYear: Int {
        islamicCal.component(.year, from: Date())
    }

    // MARK: - Bugün Aktif Etkinlik Var mı?
    func todayEvent() -> IslamicEvent? {
        let today = Calendar.current.startOfDay(for: Date())
        for event in allEvents {
            // Bu yıl ve geçen yıl kontrol et (yıl dönemi kenarlarında sorun çıkabilir)
            for yearOffset in [0, -1, 1] {
                if let eventDate = event.gregorianDate(for: currentHijriYear + yearOffset) {
                    let start = Calendar.current.startOfDay(for: eventDate)
                    let end   = Calendar.current.date(byAdding: .day, value: event.durationDays, to: start) ?? start

                    if today >= start && today < end {
                        return event
                    }
                }
            }
        }
        return nil
    }

    // MARK: - Yaklaşan Etkinlikler (30 gün içinde)
    func upcomingEvents(within days: Int = 30) -> [(event: IslamicEvent, date: Date)] {
        let today = Date()
        var results: [(IslamicEvent, Date)] = []

        for event in allEvents {
            for yearOffset in [0, 1] {
                if let eventDate = event.gregorianDate(for: currentHijriYear + yearOffset) {
                    let diff = Calendar.current.dateComponents([.day], from: today, to: eventDate).day ?? 0
                    if diff >= 0 && diff <= days {
                        results.append((event, eventDate))
                    }
                }
            }
        }

        return results.sorted { $0.1 < $1.1 }
    }

    // MARK: - Bugünkü Hicri Tarih Bileşenleri
    func currentHijriComponents() -> DateComponents {
        islamicCal.dateComponents([.year, .month, .day], from: Date())
    }

    // MARK: - Kandil / Özel Gün Bildirimleri
    func scheduleEventNotifications(language: LanguageCode) async {
        let center = UNUserNotificationCenter.current()

        // Mevcut kandil bildirimlerini temizle
        let existingIds = allEvents.map { "islamic_event_\($0.key.rawValue)" }
        center.removePendingNotificationRequests(withIdentifiers: existingIds)

        for event in allEvents {
            guard let eventDate = event.gregorianDate(for: currentHijriYear) else { continue }

            // 1 gün öncesinde bildirim gönder
            guard let notifDate = Calendar.current.date(byAdding: .day, value: -1, to: eventDate),
                  notifDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title  = event.key.emoji + " " + event.key.name(for: language)
            content.body   = notificationBody(for: event.key, language: language)
            content.sound  = .default
            content.badge  = 1

            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notifDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

            let request = UNNotificationRequest(
                identifier: "islamic_event_\(event.key.rawValue)",
                content: content,
                trigger: trigger
            )

            try? await center.add(request)
        }
    }

    private func notificationBody(for key: IslamicEventKey, language: LanguageCode) -> String {
        switch (key, language) {
        case (.laylatalQadr, .tr):  return "Bu gece Kadir Gecesi! Bin aydan daha hayırlıdır."
        case (.laylatalQadr, .en):  return "Tonight is Laylat al-Qadr! Better than a thousand months."
        case (.laylatalQadr, .ar):  return "الليلة ليلة القدر! خير من ألف شهر."

        case (.eidAlFitr, .tr):     return "Ramazan Bayramınız mübarek olsun! 🎉"
        case (.eidAlFitr, .en):     return "Eid Mubarak! May your Eid be blessed. 🎉"
        case (.eidAlFitr, .ar):     return "عيد الفطر مبارك! 🎉"

        case (.eidAlAdha, .tr):     return "Kurban Bayramınız mübarek olsun! 🌿"
        case (.eidAlAdha, .en):     return "Eid al-Adha Mubarak! 🌿"
        case (.eidAlAdha, .ar):     return "عيد الأضحى مبارك! 🌿"

        case (.ramadanStart, .tr):  return "Hayırlı Ramazanlar! Bu mübarek ayınız bereketli geçsin."
        case (.ramadanStart, .en):  return "Ramadan Mubarak! May this blessed month be fruitful."
        case (.ramadanStart, .ar):  return "رمضان مبارك! جعله الله شهراً مباركاً."

        default:
            switch language {
            case .tr: return "Mübarek bir gün sizi bekliyor."
            case .en: return "A blessed day awaits you."
            case .ar: return "يوم مبارك ينتظركم."
            case .de: return "Ein gesegneter Tag erwartet Sie."
            case .pt: return "Um dia abençoado espera por você."
            }
        }
    }
}
