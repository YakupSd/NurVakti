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
        var existingIds: [String] = []
        for event in allEvents {
            existingIds.append("islamic_event_eve_\(event.key.rawValue)")
            existingIds.append("islamic_event_day_\(event.key.rawValue)")
        }
        center.removePendingNotificationRequests(withIdentifiers: existingIds)

        for event in allEvents {
            for yearOffset in [0, 1] {
                guard let eventDate = event.gregorianDate(for: currentHijriYear + yearOffset) else { continue }

                // 1. 1 GÜN ÖNCESİ (Akşam saat 20:00)
                if let eveDate = Calendar.current.date(byAdding: .day, value: -1, to: eventDate) {
                    var eveComps = Calendar.current.dateComponents([.year, .month, .day], from: eveDate)
                    eveComps.hour = 20
                    eveComps.minute = 0

                    if let finalEveDate = Calendar.current.date(from: eveComps), finalEveDate > Date() {
                        let content = UNMutableNotificationContent()
                        content.title = "\(event.key.emoji) " + (language == .tr ? "Yarın \(event.key.name(for: language))" : "\(event.key.name(for: language)) Tomorrow")
                        content.body  = eveNotificationBody(for: event.key, language: language)
                        content.sound = .default
                        content.interruptionLevel = .active

                        let trigger = UNCalendarNotificationTrigger(dateMatching: eveComps, repeats: false)
                        let request = UNNotificationRequest(
                            identifier: "islamic_event_eve_\(event.key.rawValue)_\(yearOffset)",
                            content: content,
                            trigger: trigger
                        )
                        try? await center.add(request)
                    }
                }

                // 2. AYNI GÜN (Sabah saat 08:00)
                var dayComps = Calendar.current.dateComponents([.year, .month, .day], from: eventDate)
                dayComps.hour = 8
                dayComps.minute = 0

                if let finalDayDate = Calendar.current.date(from: dayComps), finalDayDate > Date() {
                    let content = UNMutableNotificationContent()
                    content.title = "\(event.key.emoji) " + (language == .tr ? "Bugün \(event.key.name(for: language))" : "Today is \(event.key.name(for: language))")
                    content.body  = dayNotificationBody(for: event.key, language: language)
                    content.sound = .default
                    content.interruptionLevel = .timeSensitive

                    let trigger = UNCalendarNotificationTrigger(dateMatching: dayComps, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: "islamic_event_day_\(event.key.rawValue)_\(yearOffset)",
                        content: content,
                        trigger: trigger
                    )
                    try? await center.add(request)
                }
            }
        }
    }

    private func eveNotificationBody(for key: IslamicEventKey, language: LanguageCode) -> String {
        switch (key, language) {
        case (.laylatalQadr, .tr):  return "Yarın Kadir Gecesi! Bin aydan daha hayırlı bu geceye hazırlanalım."
        case (.laylatalQadr, .en):  return "Tomorrow is Laylat al-Qadr! Let's prepare for this night better than a thousand months."
        case (.laylatalQadr, .ar):  return "غداً ليلة القدر المباركة، خير من ألف شهر."
        case (.eidAlFitr, .tr):     return "Yarın Ramazan Bayramı! Bayram coşkusu ve sevinci hanenize dolsun. 🎉"
        case (.eidAlFitr, .en):     return "Tomorrow is Eid al-Fitr! May joy and peace fill your home. 🎉"
        case (.eidAlFitr, .ar):     return "غداً أول أيام عيد الفطر المبارك! 🎉"
        case (.eidAlAdha, .tr):     return "Yarın Kurban Bayramı! Kurban ve bayramınız mübarek olsun. 🌿"
        case (.eidAlAdha, .en):     return "Tomorrow is Eid al-Adha! May your sacrifices be blessed. 🌿"
        case (.eidAlAdha, .ar):     return "غداً أول أيام عيد الأضحى المبارك! 🌿"
        case (.mevlidNebevi, .tr):  return "Yarın Mevlid Kandili! Peygamber Efendimiz'in (s.a.v.) dünyayı teşrif ettiği nurlu gece."
        case (.regaipKandili, .tr): return "Yarın Regaip Kandili! Üç ayların ilk kandilinde dualarımız kabul olsun."
        case (.miracKandili, .tr):  return "Yarın Miraç Kandili! Manevi yükseliş ve namazın müjdelendiği gece."
        case (.beratKandili, .tr):  return "Yarın Berat Kandili! Af ve mağfiret kapılarının açıldığı mübarek gece."
        default:
            switch language {
            case .tr: return "\(key.name(for: language)) yarın idrak edilecek. Hayırlara vesile olsun."
            case .en: return "\(key.name(for: language)) will be celebrated tomorrow. Have a blessed time."
            case .ar: return "غداً هو \(key.name(for: language))، تقبل الله منا ومنكم."
            case .de: return "\(key.name(for: language)) ist morgen. Möge es gesegnet sein."
            case .pt: return "\(key.name(for: language)) será amanhã. Que seja abençoado."
            }
        }
    }

    private func dayNotificationBody(for key: IslamicEventKey, language: LanguageCode) -> String {
        switch (key, language) {
        case (.laylatalQadr, .tr):  return "Bugün Kadir Gecesi! Bu kutlu gecede dualarınız kabul, kalbiniz nurlu olsun."
        case (.laylatalQadr, .en):  return "Tonight is Laylat al-Qadr! Better than a thousand months. May your prayers be answered."
        case (.laylatalQadr, .ar):  return "الليلة ليلة القدر! خير من ألف شهر، تقبل الله طاعتكم."
        case (.eidAlFitr, .tr):     return "Ramazan Bayramınız mübarek olsun! Sevdiklerinizle mutlu ve huzurlu nice bayramlara. 🎉"
        case (.eidAlFitr, .en):     return "Eid Mubarak! Wishing you and your family a blessed and joyful Eid. 🎉"
        case (.eidAlFitr, .ar):     return "عيد الفطر مبارك! تقبل الله منا ومنكم صالح الأعمال. 🎉"
        case (.eidAlAdha, .tr):     return "Kurban Bayramınız mübarek olsun! Kurbanlarınız makbul, haneniz bereketli olsun. 🌿"
        case (.eidAlAdha, .en):     return "Eid al-Adha Mubarak! May your sacrifices be accepted and rewarded. 🌿"
        case (.eidAlAdha, .ar):     return "عيد الأضحى مبارك! كل عام وأنتم بخير وسعادة. 🌿"
        case (.mevlidNebevi, .tr):  return "Mevlid Kandiliniz mübarek olsun! Peygamber Efendimiz'in (s.a.v.) şefaati üzerinize olsun. 💚"
        case (.regaipKandili, .tr): return "Regaip Kandiliniz mübarek olsun! Rağbetimiz yalnız Rabbimize olsun. 🌙"
        case (.miracKandili, .tr):  return "Miraç Kandiliniz mübarek olsun! Namaz ve manevi yükselişle nurlanın. ✨"
        case (.beratKandili, .tr):  return "Berat Kandiliniz mübarek olsun! Rabbim hepimize ak beratlar nasip eylesin. 📜"
        case (.arafaDay, .tr):      return "Arefe Gününüz mübarek olsun! Duaların en hayırlısı bugün yapılan duadır. 🤲"
        case (.ramadanStart, .tr):  return "Hoş Geldin Ramazan-ı Şerif! On bir ayın sultanı hanenize bereket getirsin. 🌙"
        default:
            switch language {
            case .tr: return "\(key.name(for: language))'niz mübarek, dualarınız makbul olsun."
            case .en: return "Wishing you a blessed \(key.name(for: language)). May your prayers be accepted."
            case .ar: return "\(key.name(for: language)) مبارك، تقبل الله منا ومنكم صالح الأعمال."
            case .de: return "Gesegneten \(key.name(for: language)). Mögen Ihre Gebete erhört werden."
            case .pt: return "Abençoado \(key.name(for: language)). Que suas orações sejam aceitas."
            }
        }
    }
}
