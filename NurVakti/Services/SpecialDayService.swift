import Foundation
import SwiftUI
import Combine
import UserNotifications

// MARK: - Special Day Information Model
struct SpecialDayInfo: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let badgeText: String
    let emoji: String
    let category: SpiritualCategory
    let subCategory: String?
    let gradientColors: [Color]
    let borderGradient: [Color]
    let accentColor: Color
    let actionTitle: String
    let isFriday: Bool
    let eventKey: IslamicEventKey?

    init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String,
        badgeText: String,
        emoji: String,
        category: SpiritualCategory,
        subCategory: String? = nil,
        gradientColors: [Color],
        borderGradient: [Color],
        accentColor: Color,
        actionTitle: String = "Özel Mesaj ve Duaları Keşfet →",
        isFriday: Bool = false,
        eventKey: IslamicEventKey? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.badgeText = badgeText
        self.emoji = emoji
        self.category = category
        self.subCategory = subCategory
        self.gradientColors = gradientColors
        self.borderGradient = borderGradient
        self.accentColor = accentColor
        self.actionTitle = actionTitle
        self.isFriday = isFriday
        self.eventKey = eventKey
    }
}

// MARK: - SpecialDayService
final class SpecialDayService: ObservableObject {
    static let shared = SpecialDayService()

    @Published private(set) var todaySpecialDay: SpecialDayInfo?

    private init() {
        refreshTodaySpecialDay(language: LocalizationManager.shared.currentLanguage)
    }

    var isTodayFriday: Bool {
        Calendar.current.component(.weekday, from: Date()) == 6
    }

    // MARK: - Günlük Özel Gün Tespiti
    @discardableResult
    func refreshTodaySpecialDay(language: LanguageCode) -> SpecialDayInfo? {
        let calendar = Calendar.current
        let isFriday = calendar.component(.weekday, from: Date()) == 6
        let todayEvent = IslamicCalendarService.shared.todayEvent()

        var info: SpecialDayInfo? = nil

        if let event = todayEvent {
            info = buildEventInfo(for: event, language: language, alsoFriday: isFriday)
        } else if isFriday {
            info = buildFridayInfo(language: language)
        }

        self.todaySpecialDay = info
        return info
    }

    // MARK: - Kandil & Bayram Bilgisi Üretici
    private func buildEventInfo(for event: IslamicEvent, language: LanguageCode, alsoFriday: Bool) -> SpecialDayInfo {
        let name = event.key.name(for: language)

        switch event.key {
        case .mevlidNebevi:
            let fridaySuffix = alsoFriday ? (language == .tr ? " & Cuma" : " & Friday") : ""
            let title = language == .tr ? "Mevlid Kandili\(fridaySuffix) Mübarek Olsun" :
                        language == .en ? "Mawlid al-Nabi\(fridaySuffix) Mubarak" :
                        language == .ar ? "المولد النبوي الشريف مبارك" :
                        language == .de ? "Mawlid an-Nabi\(fridaySuffix) Mubarak" : "Mawlid an-Nabi\(fridaySuffix) Abençoado"
            let subtitle = language == .tr ? "Âlemlere rahmet Peygamber Efendimiz'in (s.a.v.) dünyayı teşrif ettiği bu nurlu gününüz mübarek olsun." :
                           language == .en ? "May this blessed day marking the birth of Prophet Muhammad (PBUH) bring peace and blessings." :
                           language == .ar ? "نبارك لكم ذكرى مولد خير الأنام سيدنا محمد صلى الله عليه وسلم." :
                           language == .de ? "Möge dieser gesegnete Tag der Geburt unseres Propheten (saw) Frieden bringen." : "Que este dia abençoado traga paz e bênçãos a você e sua família."
            let badge = language == .tr ? "MÜBAREK KANDİL" : (language == .en ? "BLESSED NIGHT" : "ليلة مباركة")

            return SpecialDayInfo(
                title: "\(title) 💚",
                subtitle: subtitle,
                badgeText: badge,
                emoji: "💚",
                category: .kandil,
                subCategory: KandilSubType.mevlid.rawValue,
                gradientColors: [Color(hex: "#0A2818"), Color(hex: "#051A0F"), Color(hex: "#020D07")],
                borderGradient: [Color(hex: "#2ECC71").opacity(0.8), Color.nurGold],
                accentColor: Color(hex: "#2ECC71"),
                actionTitle: language == .tr ? "Mevlid Dualarını ve Mesajları Gör →" : "View Supplications →",
                isFriday: alsoFriday,
                eventKey: event.key
            )

        case .regaipKandili:
            let fridaySuffix = alsoFriday ? (language == .tr ? " & Cuma" : " & Friday") : ""
            let title = language == .tr ? "Regaip Kandili\(fridaySuffix) Mübarek Olsun" :
                        language == .en ? "Raghaib Night\(fridaySuffix) Mubarak" :
                        language == .ar ? "ليلة الرغائب مباركة" :
                        language == .de ? "Regaib-Nacht\(fridaySuffix) Mubarak" : "Noite de Raghaib\(fridaySuffix) Abençoada"
            let subtitle = language == .tr ? "Üç ayların ilk müjdecisi olan bu müstesna gecede dualarınız ve rağbetiniz kabul olsun." :
                           language == .en ? "May your prayers be accepted on this sacred herald of the three holy months." :
                           language == .ar ? "نسأل الله أن يتقبل دعاءكم في هذه الليلة المباركة من الأشهر الحرم." :
                           language == .de ? "Mögen Ihre Gebete in dieser heiligen Nacht der drei Monate erhört werden." : "Que suas orações sejam aceitas nesta noite sagrada."
            let badge = language == .tr ? "ÜÇ AYLARIN MÜJDECİSİ" : "HOLY NIGHT"

            return SpecialDayInfo(
                title: "\(title) 🌙",
                subtitle: subtitle,
                badgeText: badge,
                emoji: "🌙",
                category: .kandil,
                subCategory: KandilSubType.regaip.rawValue,
                gradientColors: [Color(hex: "#0E1626"), Color(hex: "#070B14"), Color(hex: "#102038")],
                borderGradient: [Color.nurGold, Color(hex: "#4A90E2").opacity(0.7)],
                accentColor: .nurGold,
                actionTitle: language == .tr ? "Regaip Mesajlarını ve Dualarını Keşfet →" : "Explore Blessings →",
                isFriday: alsoFriday,
                eventKey: event.key
            )

        case .miracKandili:
            let fridaySuffix = alsoFriday ? (language == .tr ? " & Cuma" : " & Friday") : ""
            let title = language == .tr ? "Miraç Kandili\(fridaySuffix) Mübarek Olsun" :
                        language == .en ? "Isra & Mi'raj\(fridaySuffix) Mubarak" :
                        language == .ar ? "ذكرى الإسراء والمعراج مباركة" :
                        language == .de ? "Isra und Miradsch\(fridaySuffix) Mubarak" : "Isra e Miraj\(fridaySuffix) Abençoado"
            let subtitle = language == .tr ? "Peygamber Efendimiz'in semaya yükselişi ve namazın müjdelendiği bu kutlu gününüz mübarek olsun." :
                           language == .en ? "Commemorating the miraculous ascension and the gift of prayer. Have a blessed night." :
                           language == .ar ? "ذكرى معراج النبي صلى الله عليه وسلم وهدية الصلاة، تقبل الله منا ومنكم." :
                           language == .de ? "In Erinnerung an die Himmelfahrt und das Geschenk des Gebets." : "Comemorando a ascensão miraculosa e o presente da oração."
            let badge = language == .tr ? "MANEVİ YÜKSELİŞ GECESİ" : "HOLY ASCENSION"

            return SpecialDayInfo(
                title: "\(title) ✨",
                subtitle: subtitle,
                badgeText: badge,
                emoji: "✨",
                category: .kandil,
                subCategory: KandilSubType.mirac.rawValue,
                gradientColors: [Color(hex: "#1E1238"), Color(hex: "#0E0820"), Color(hex: "#080410")],
                borderGradient: [Color(hex: "#9B59B6"), Color.nurGold],
                accentColor: Color(hex: "#D4AF37"),
                actionTitle: language == .tr ? "Miraç Dualarını ve Mesajları Gör →" : "View Duas & Messages →",
                isFriday: alsoFriday,
                eventKey: event.key
            )

        case .beratKandili:
            let fridaySuffix = alsoFriday ? (language == .tr ? " & Cuma" : " & Friday") : ""
            let title = language == .tr ? "Berat Kandili\(fridaySuffix) Mübarek Olsun" :
                        language == .en ? "Laylat al-Bara'ah\(fridaySuffix) Mubarak" :
                        language == .ar ? "ليلة البراءة مباركة" :
                        language == .de ? "Laylat al-Baraat\(fridaySuffix) Mubarak" : "Noite da Absolvição\(fridaySuffix) Abençoada"
            let subtitle = language == .tr ? "Af, mağfiret ve kurtuluş kapılarının sonuna kadar açıldığı Berat geceniz hayırlara vesile olsun." :
                           language == .en ? "A night of forgiveness, mercy and salvation. May your supplications be answered." :
                           language == .ar ? "ليلة المغفرة والرحمة والعتق من النار، جعلها الله ليلة خير وبركة." :
                           language == .de ? "Eine Nacht der Vergebung und Barmherzigkeit. Mögen Ihre Gebete erhört werden." : "Uma noite de perdão e misericórdia."
            let badge = language == .tr ? "AF VE MAĞFİRET GECESİ" : "NIGHT OF FORGIVENESS"

            return SpecialDayInfo(
                title: "\(title) 📜",
                subtitle: subtitle,
                badgeText: badge,
                emoji: "📜",
                category: .kandil,
                subCategory: KandilSubType.berat.rawValue,
                gradientColors: [Color(hex: "#141E30"), Color(hex: "#08101E"), Color(hex: "#040810")],
                borderGradient: [Color(hex: "#F39C12"), Color.nurGold],
                accentColor: Color.nurGold,
                actionTitle: language == .tr ? "Berat Mesajlarını ve Dualarını Keşfet →" : "Explore Duas & Prayers →",
                isFriday: alsoFriday,
                eventKey: event.key
            )

        case .laylatalQadr:
            let title = language == .tr ? "Kadir Geceniz Mübarek Olsun" :
                        language == .en ? "Laylat al-Qadr Mubarak" :
                        language == .ar ? "ليلة القدر مباركة" :
                        language == .de ? "Laylat al-Qadr Mubarak" : "Laylat al-Qadr Abençoada"
            let subtitle = language == .tr ? "“Kadir Gecesi bin aydan daha hayırlıdır.” Kur'an nuruyla aydınlanan bu gece feyizli olsun." :
                           language == .en ? "\"The Night of Decree is better than a thousand months.\" May this sacred night bring peace." :
                           language == .ar ? "«لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ» جعلها الله ليلة رحمة ومغفرة." :
                           language == .de ? "„Die Nacht der Bestimmung ist besser als tausend Monate.“" : "\"A Noite do Decreto é melhor que mil meses.\""
            let badge = language == .tr ? "BİN AYDAN HAYIRLI GECE" : "NIGHT OF POWER"

            return SpecialDayInfo(
                title: "\(title) ⭐",
                subtitle: subtitle,
                badgeText: badge,
                emoji: "⭐",
                category: .kandil,
                subCategory: KandilSubType.kadir.rawValue,
                gradientColors: [Color(hex: "#2B0B4C"), Color(hex: "#160528"), Color(hex: "#090212")],
                borderGradient: [Color(hex: "#E056FD"), Color.nurGold],
                accentColor: Color(hex: "#F1C40F"),
                actionTitle: language == .tr ? "Kadir Gecesi Özel Duaları →" : "Special Duas for Tonight →",
                isFriday: alsoFriday,
                eventKey: event.key
            )

        case .ramadanStart:
            let title = language == .tr ? "Hoş Geldin Ramazan-ı Şerif" :
                        language == .en ? "Ramadan Mubarak" :
                        language == .ar ? "رمضان كريم ومبارك" :
                        language == .de ? "Ramadan Mubarak" : "Ramadã Mubarak"
            let subtitle = language == .tr ? "On bir ayın sultanı Ramazan ayı hanenize bereket, gönlünüze huzur getirsin." :
                           language == .en ? "May the blessed month of Ramadan bring peace, harmony, and joy to your life." :
                           language == .ar ? "أهلاً بشهر الخير والبركات، تقبل الله منا ومنكم الصيام والقيام." :
                           language == .de ? "Möge der gesegnete Monat Ramadan Ihnen Frieden und Segen bringen." : "Que o mês sagrado do Ramadã traga paz e harmonia."
            let badge = language == .tr ? "ON BİR AYIN SULTANI" : "BLESSED RAMADAN"

            return SpecialDayInfo(
                title: "\(title) 🌙",
                subtitle: subtitle,
                badgeText: badge,
                emoji: "🌙",
                category: .specialDays,
                gradientColors: [Color(hex: "#0A2438"), Color(hex: "#051320"), Color(hex: "#02080E")],
                borderGradient: [Color(hex: "#3498DB"), Color.nurGold],
                accentColor: Color(hex: "#5DADE2"),
                actionTitle: language == .tr ? "Ramazan Dualarını Keşfet →" : "Explore Ramadan Content →",
                isFriday: alsoFriday,
                eventKey: event.key
            )

        case .eidAlFitr:
            let title = language == .tr ? "Ramazan Bayramınız Mübarek Olsun" :
                        language == .en ? "Eid al-Fitr Mubarak" :
                        language == .ar ? "عيد الفطر مبارك" :
                        language == .de ? "Eid al-Fitr Mubarak" : "Eid al-Fitr Mubarak"
            let subtitle = language == .tr ? "Sevdiklerinizle birlikte neşe, huzur ve sağlık dolu mutlu bir bayram dileriz." :
                           language == .en ? "Wishing you and your family a joyful, peaceful, and blessed Eid celebration." :
                           language == .ar ? "تقبل الله منا ومنكم صالح الأعمال، وكل عام وأنتم بخير وسعادة." :
                           language == .de ? "Wir wünschen Ihnen und Ihrer Familie ein frohes und gesegnetes Fest." : "Desejando a você e sua família uma celebração abençoada."
            let badge = language == .tr ? "BAYRAM SEVİNCİ" : "EID CELEBRATION"

            return SpecialDayInfo(
                title: "\(title) 🎉",
                subtitle: subtitle,
                badgeText: badge,
                emoji: "🎉",
                category: .bayram,
                subCategory: BayramSubType.ramadan.rawValue,
                gradientColors: [Color(hex: "#103B1E"), Color(hex: "#082010"), Color(hex: "#020C06")],
                borderGradient: [Color(hex: "#27AE60"), Color.nurGold],
                accentColor: Color(hex: "#2ECC71"),
                actionTitle: language == .tr ? "Bayram Tebrik Mesajlarını Gör →" : "View Eid Greetings →",
                isFriday: alsoFriday,
                eventKey: event.key
            )

        case .eidAlAdha:
            let title = language == .tr ? "Kurban Bayramınız Mübarek Olsun" :
                        language == .en ? "Eid al-Adha Mubarak" :
                        language == .ar ? "عيد الأضحى مبارك" :
                        language == .de ? "Eid al-Adha Mubarak" : "Eid al-Adha Mubarak"
            let subtitle = language == .tr ? "Kurbanlarınızın makbul, dualarınızın kabul olduğu hayırlı ve bereketli bir bayram dileriz." :
                           language == .en ? "May your sacrifices be accepted and your home filled with peace and happiness." :
                           language == .ar ? "أعاده الله علينا وعليكم بالخير واليمن والبركات، عيدكم مبارك." :
                           language == .de ? "Mögen Ihre Opfer angenommen werden und Ihr Zuhause mit Frieden erfüllt sein." : "Que seus sacrifícios sejam aceitos e seu lar cheio de paz."
            let badge = language == .tr ? "KURBAN BAYRAMI" : "EID AL-ADHA"

            return SpecialDayInfo(
                title: "\(title) 🌿",
                subtitle: subtitle,
                badgeText: badge,
                emoji: "🌿",
                category: .bayram,
                subCategory: BayramSubType.eidAlAdha.rawValue,
                gradientColors: [Color(hex: "#1E3015"), Color(hex: "#101A0B"), Color(hex: "#060A04")],
                borderGradient: [Color(hex: "#58D68D"), Color.nurGold],
                accentColor: Color(hex: "#58D68D"),
                actionTitle: language == .tr ? "Kurban Bayramı Mesajlarını Gör →" : "View Greetings →",
                isFriday: alsoFriday,
                eventKey: event.key
            )

        case .arafaDay:
            let title = language == .tr ? "Arefe Gününüz Mübarek Olsun" :
                        language == .en ? "Day of Arafah Mubarak" :
                        language == .ar ? "يوم عرفة مبارك" :
                        language == .de ? "Tag von Arafah Mubarak" : "Dia de Arafá Abençoado"
            let subtitle = language == .tr ? "“Duaların en hayırlısı Arefe günü yapılan duadır.” Kalbinizden geçen dualar makbul olsun." :
                           language == .en ? "\"The best supplication is the supplication of the Day of Arafah.\" May your prayers be answered." :
                           language == .ar ? "«خير الدعاء دعاء يوم عرفة» نسأل الله لكم القبول والغفران." :
                           language == .de ? "„Das beste Bittgebet ist das Bittgebet am Tage von Arafah.“" : "\"A melhor súplica é a súplica do Dia de Arafá.\""
            let badge = language == .tr ? "MÜBAREK AREFE GÜNÜ" : "DAY OF ARAFAH"

            return SpecialDayInfo(
                title: "\(title) 🤲",
                subtitle: subtitle,
                badgeText: badge,
                emoji: "🤲",
                category: .bayram,
                subCategory: BayramSubType.arafah.rawValue,
                gradientColors: [Color(hex: "#2E1C0C"), Color(hex: "#1A0E06"), Color(hex: "#0C0602")],
                borderGradient: [Color(hex: "#E67E22"), Color.nurGold],
                accentColor: Color(hex: "#F39C12"),
                actionTitle: language == .tr ? "Arefe Günü Dualarını Gör →" : "View Arafah Duas →",
                isFriday: alsoFriday,
                eventKey: event.key
            )
        }
    }

    // MARK: - Cuma Günü Bilgisi Üretici
    private func buildFridayInfo(language: LanguageCode) -> SpecialDayInfo {
        let title = language == .tr ? "Hayırlı Cumalar" :
                    language == .en ? "Blessed Friday" :
                    language == .ar ? "جمعة مباركة" :
                    language == .de ? "Gesegneten Freitag" : "Sexta-feira Abençoada"
        let subtitle = language == .tr ? "Gönüllerin huzura, duaların kabul kapılarına ulaştığı nurlu bir Cuma günü dileriz." :
                       language == .en ? "May your Friday be filled with peace, blessings, and answered prayers." :
                       language == .ar ? "جعل الله جمعتكم نورا، ويسر لكم كل أمر عسير، وتقبل دعاءكم." :
                       language == .de ? "Möge Ihr Freitag voller Frieden, Segen und erhörter Gebete sein." : "Que sua sexta-feira seja repleta de paz e bênçãos."
        let badge = language == .tr ? "MÜMİNLERİN BAYRAMI" : (language == .en ? "FRIDAY BLESSINGS" : "عيد المؤمنين")

        return SpecialDayInfo(
            title: "\(title) ✨",
            subtitle: subtitle,
            badgeText: badge,
            emoji: "🕌",
            category: .friday,
            gradientColors: [Color(hex: "#0E1626"), Color(hex: "#0A101C"), Color(hex: "#05080E")],
            borderGradient: [Color.nurGold, Color(hex: "#FFE58F").opacity(0.8)],
            accentColor: .nurGold,
            actionTitle: language == .tr ? "Cuma Mesajlarını ve Dualarını Keşfet →" : "Explore Friday Greetings →",
            isFriday: true
        )
    }

    // MARK: - Özel Gün Bildirimi Planlama
    /// Bugün özel gün ise ve henüz bugün bildirim atılmadıysa, ya da genel takvim bildirimlerini kurar
    func scheduleSpecialDayNotifications(language: LanguageCode) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }

        // 1. Haftalık Cuma Bildirimi Planla (Her Cuma Sabah 08:30)
        await scheduleWeeklyFridayNotification(language: language)

        // 2. Bugün aktif özel gün varsa anlık/bugünkü bildirimi gönder
        await checkAndFireTodayNotificationIfNeeded(language: language)
    }

    // MARK: - Her Cuma Sabah 08:30 Bildirimi
    private func scheduleWeeklyFridayNotification(language: LanguageCode) async {
        let center = UNUserNotificationCenter.current()
        let id = "nurvakti_weekly_friday_notification"
        center.removePendingNotificationRequests(withIdentifiers: [id])

        var dateComps = DateComponents()
        dateComps.weekday = 6 // Cuma
        dateComps.hour = 8
        dateComps.minute = 30

        let content = UNMutableNotificationContent()
        content.title = language == .tr ? "🕌 Hayırlı Cumalar!" :
                        language == .en ? "🕌 Blessed Friday!" :
                        language == .ar ? "🕌 جمعة مباركة!" :
                        language == .de ? "🕌 Gesegneten Freitag!" : "🕌 Sexta-feira Abençoada!"
        content.body = language == .tr ? "Duaların kabul olduğu bu mübarek günde sevdiklerinize hayırlı dualar ulaştırın." :
                       language == .en ? "Send warm prayers and blessings to your loved ones on this holy day." :
                       language == .ar ? "تقبل الله طاعتكم وصالح أعمالكم في هذا اليوم المبارك." :
                       language == .de ? "Senden Sie Ihren Lieben an diesem gesegneten Tag gute Wünsche." : "Envie bênçãos aos seus entes queridos neste dia sagrado."
        content.sound = .default
        content.interruptionLevel = .active

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try? await center.add(request)
    }

    // MARK: - Bugünün Özel Gün Bildirimini Tetikle (Günde Max 1 Kez)
    private func checkAndFireTodayNotificationIfNeeded(language: LanguageCode) async {
        guard let special = refreshTodaySpecialDay(language: language) else { return }

        let dateKey = "NurVakti_LastSpecialDayNotifDate"
        let todayStr = ISO8601DateFormatter().string(from: Calendar.current.startOfDay(for: Date()))

        let lastSent = UserDefaults.standard.string(forKey: dateKey)
        if lastSent == todayStr {
            // Bugün zaten gönderildi
            return
        }

        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "\(special.emoji) \(special.title)"
        content.body = special.subtitle
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        // Bildirimi hemen 2 saniye sonra tetikle
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "nurvakti_today_special_\(UUID().uuidString)", content: content, trigger: trigger)

        do {
            try await center.add(request)
            UserDefaults.standard.set(todayStr, forKey: dateKey)
        } catch {
            print("SpecialDayService: Bildirim eklenirken hata: \(error)")
        }
    }
}
