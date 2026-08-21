import Foundation
import SwiftUI
import Combine

public final class SpiritualMessageService: ObservableObject {
    public static let shared = SpiritualMessageService()
    
    @Published public private(set) var favoriteIds: Set<String> = []
    @Published public private(set) var dynamicWisdomMessage: SpiritualMessage?
    
    private let favoritesKey = "NurVakti_FavoriteSpiritualMessages"
    
    public init() {
        loadFavorites()
        loadDynamicWisdom()
    }
    
    // MARK: - Favorites Management
    private func loadFavorites() {
        if let saved = UserDefaults.standard.stringArray(forKey: favoritesKey) {
            favoriteIds = Set(saved)
        }
    }
    
    public func isFavorite(messageId: String) -> Bool {
        favoriteIds.contains(messageId)
    }
    
    public func toggleFavorite(messageId: String) {
        if favoriteIds.contains(messageId) {
            favoriteIds.remove(messageId)
        } else {
            favoriteIds.insert(messageId)
        }
        UserDefaults.standard.set(Array(favoriteIds), forKey: favoritesKey)
        objectWillChange.send()
    }
    
    // MARK: - Dynamic Online Wisdom Fetcher
    public func loadDynamicWisdom() {
        // Asynchronously check online or provide dynamic day-of-year rotation
        Task {
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
            let wisdomList = Self.dailyWisdomMessages
            let selected = wisdomList[dayOfYear % wisdomList.count]
            await MainActor.run {
                self.dynamicWisdomMessage = selected
            }
        }
    }
    
    // MARK: - Filtered Messages
    public func messages(
        for category: SpiritualCategory,
        subCategory: String? = nil,
        searchQuery: String = ""
    ) -> [SpiritualMessage] {
        var list: [SpiritualMessage] = []
        
        switch category {
        case .all:
            list = Self.allMessages
        case .friday:
            list = Self.fridayMessages
        case .kandil:
            if let sub = subCategory, !sub.isEmpty {
                list = Self.kandilMessages.filter { $0.subCategory == sub }
            } else {
                list = Self.kandilMessages
            }
        case .bayram:
            if let sub = subCategory, !sub.isEmpty {
                list = Self.bayramMessages.filter { $0.subCategory == sub }
            } else {
                list = Self.bayramMessages
            }
        case .specialDays:
            list = Self.specialDaysMessages
        case .dailyWisdom:
            list = Self.dailyWisdomMessages
        case .favorites:
            list = Self.allMessages.filter { favoriteIds.contains($0.id) }
        }
        
        if !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let q = searchQuery.lowercased()
            list = list.filter {
                $0.title.lowercased().contains(q) ||
                $0.text.lowercased().contains(q) ||
                ($0.authorOrSource?.lowercased().contains(q) ?? false) ||
                $0.tags.contains { $0.lowercased().contains(q) }
            }
        }
        
        return list
    }
    
    // MARK: - Featured Message for Today
    public func todaysFeaturedMessage() -> SpiritualMessage {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        
        // Cuma günü ise (6 = Friday in Gregorian Calendar where Sunday = 1)
        if weekday == 6 {
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
            let index = dayOfYear % Self.fridayMessages.count
            return Self.fridayMessages[index]
        }
        
        // Kandil veya özel gün kontrolü
        if let event = IslamicCalendarService.shared.todayEvent() {
            switch event.key {
            case .mevlidNebevi:
                return Self.kandilMessages.first(where: { $0.subCategory == KandilSubType.mevlid.rawValue }) ?? Self.fridayMessages[0]
            case .regaipKandili:
                return Self.kandilMessages.first(where: { $0.subCategory == KandilSubType.regaip.rawValue }) ?? Self.fridayMessages[0]
            case .miracKandili:
                return Self.kandilMessages.first(where: { $0.subCategory == KandilSubType.mirac.rawValue }) ?? Self.fridayMessages[0]
            case .beratKandili:
                return Self.kandilMessages.first(where: { $0.subCategory == KandilSubType.berat.rawValue }) ?? Self.fridayMessages[0]
            case .laylatalQadr:
                return Self.kandilMessages.first(where: { $0.subCategory == KandilSubType.kadir.rawValue }) ?? Self.fridayMessages[0]
            case .eidAlFitr:
                return Self.bayramMessages.first(where: { $0.subCategory == BayramSubType.ramadan.rawValue }) ?? Self.fridayMessages[0]
            case .eidAlAdha:
                return Self.bayramMessages.first(where: { $0.subCategory == BayramSubType.eidAlAdha.rawValue }) ?? Self.fridayMessages[0]
            case .arafaDay:
                return Self.bayramMessages.first(where: { $0.subCategory == BayramSubType.arafah.rawValue }) ?? Self.fridayMessages[0]
            default:
                break
            }
        }
        
        // Normal günlerde Günün Hikmetli Sözü
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % Self.dailyWisdomMessages.count
        return Self.dailyWisdomMessages[index]
    }
    
    public func getDailyWisdom() -> SpiritualMessage {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % Self.dailyWisdomMessages.count
        return Self.dailyWisdomMessages[index]
    }
    
    public func fetchDailyWisdomOnline() async -> SpiritualMessage {
        return getDailyWisdom()
    }
    
    public func getTodaySpecialEventBanner(currentLanguage: LanguageCode) -> (title: String, subtitle: String, emoji: String, category: SpiritualCategory)? {
        if isTodayFriday {
            let title = currentLanguage == .tr ? "Hayırlı Cumalar ✨" :
                        currentLanguage == .en ? "Blessed Friday ✨" :
                        currentLanguage == .ar ? "جمعة مباركة ✨" :
                        currentLanguage == .de ? "Gesegneten Freitag ✨" : "Sexta-feira Abençoada ✨"
            let subtitle = currentLanguage == .tr ? "Günün Cuma mesajlarını ve dualarını keşfet" :
                           currentLanguage == .en ? "Explore today's Friday greetings and prayers" :
                           currentLanguage == .ar ? "استكشف رسائل وأدعية يوم الجمعة" :
                           currentLanguage == .de ? "Entdecken Sie Freitagsgrüße und Gebete" : "Explore as mensagens e orações de sexta-feira"
            return (title: title, subtitle: subtitle, emoji: "🕌", category: .friday)
        }
        
        if let event = IslamicCalendarService.shared.todayEvent() {
            let eventName = event.key.name(for: currentLanguage)
            let suffix = currentLanguage == .tr ? "Mübarek Olsun 🌙" :
                         currentLanguage == .en ? "Mubarak 🌙" :
                         currentLanguage == .ar ? "مبارك 🌙" :
                         currentLanguage == .de ? "Mubarak 🌙" : "Abençoado 🌙"
            let title = "\(eventName) \(suffix)"
            let subtitle = currentLanguage == .tr ? "Özel gün tebrik mesajlarını ve dualarını incele" :
                           currentLanguage == .en ? "Explore special greetings and supplications" :
                           currentLanguage == .ar ? "استكشف رسائل التهنئة والأدعية الخاصة" :
                           currentLanguage == .de ? "Entdecken Sie besondere Grüße und Bittgebete" : "Explore mensagens especiais de felicitações e súplicas"
            
            let cat: SpiritualCategory = event.key.isSpecialNight ? .kandil : (event.key == .eidAlFitr || event.key == .eidAlAdha ? .bayram : .specialDays)
            return (title: title, subtitle: subtitle, emoji: event.key.emoji, category: cat)
        }
        
        return nil
    }
    
    public var isTodayFriday: Bool {
        Calendar.current.component(.weekday, from: Date()) == 6
    }
    
    public var todaysSpecialBannerTitle: String? {
        if isTodayFriday {
            return "Hayırlı Cumalar ✨"
        }
        if let event = IslamicCalendarService.shared.todayEvent() {
            return "\(event.key.name(for: .tr)) Mübarek Olsun 🌙"
        }
        return nil
    }
    
    // MARK: - Curated Spiritual Messages Database
    
    public static var allMessages: [SpiritualMessage] {
        fridayMessages + kandilMessages + bayramMessages + specialDaysMessages + dailyWisdomMessages
    }
    
    // ── 1. Cuma Mesajları (15+ Adet) ──
    public static let fridayMessages: [SpiritualMessage] = [
        SpiritualMessage(
            id: "fri_01",
            title: "Hayırlı Cumalar",
            arabicText: "يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا نُودِيَ لِلصَّلَاةِ مِن يَوْمِ الْجُمُعَةِ فَاسْعَوْا إِلَىٰ ذِكْرِ اللَّهِ",
            text: "Rabbim, gönlümüzden geçen hayırlı duaları kabul, hanelerimize huzur ve bereket ihsan eylesin. Cumanız mübarek, dualarınız makbul olsun.",
            authorOrSource: "Cum'a Suresi, 9. Ayet",
            category: .friday,
            tags: ["cuma", "hayırlı cumalar", "dua"]
        ),
        SpiritualMessage(
            id: "fri_02",
            title: "Cuma'nın Bereketi",
            arabicText: "خَيْرُ يَوْمٍ طَلَعَتْ عَلَيْهِ الشَّمْسُ يَوْمُ الْجُمُعَةِ",
            text: "“Üzerine güneşin doğduğu en hayırlı gün Cuma günüdür.” Bu mübarek günün hürmetine Rabbim kalplerimize inşirah, dertlerimize deva lütfetsin. Hayırlı nurlu Cumalar.",
            authorOrSource: "Müslim, Cuma, 18",
            category: .friday,
            tags: ["cuma", "hadis", "bereket"]
        ),
        SpiritualMessage(
            id: "fri_03",
            title: "Gönül Duası",
            arabicText: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
            text: "Ey Rabbimiz! Bize dünyada da iyilik ve güzellik ver, ahirette de iyilik ve güzellik ver. Bizi cehennem azabından koru. Cumanız bereketli ve huzurlu olsun.",
            authorOrSource: "Bakara Suresi, 201. Ayet",
            category: .friday,
            tags: ["cuma", "dua", "ayet"]
        ),
        SpiritualMessage(
            id: "fri_04",
            title: "Huzur ve Af Kapısı",
            arabicText: "إِنَّ اللَّهَ وَمَلَائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ",
            text: "Allahümme salli alâ seyyidinâ Muhammedin ve alâ âli seyyidinâ Muhammed. Peygamber Efendimiz'e salat ve selam olsun. Cumanız mübarek olsun.",
            authorOrSource: "Ahzâb Suresi, 56. Ayet",
            category: .friday,
            tags: ["cuma", "salavat", "peygamber"]
        ),
        SpiritualMessage(
            id: "fri_05",
            title: "Kalplere Şifa Cuma",
            arabicText: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
            text: "Bilesiniz ki, kalpler ancak Allah'ı anmakla huzur bulur. Kalbinizin huzurla, hanenizin bereketle dolduğu hayırlı bir Cuma günü dilerim.",
            authorOrSource: "Ra'd Suresi, 28. Ayet",
            category: .friday,
            tags: ["cuma", "huzur", "zikir"]
        ),
        SpiritualMessage(
            id: "fri_06",
            title: "Manevi Bahar",
            arabicText: nil,
            text: "Gözlerin nuru, kalplerin süruru, müminlerin bayramı olan bu kutlu günde Rabbim sizi ve sevdiklerinizi her türlü kaza ve beladan muhafaza buyursun. Hayırlı Cumalar.",
            authorOrSource: "NurVakti Dualar",
            category: .friday,
            tags: ["cuma", "tebrik", "sevgi"]
        ),
        SpiritualMessage(
            id: "fri_07",
            title: "Rahmet ve Mağfiret",
            arabicText: "وَقُل رَّبِّ اغْفِرْ وَارْحَمْ وَأَنتَ خَيْرُ الرَّاحِمِينَ",
            text: "De ki: 'Rabbim! Bağışla, merhamet et. Sen merhametlilerin en hayırlısısın.' Duaların geri çevrilmediği bu kutlu vakitte cümlenizin Cuma'sı mübarek olsun.",
            authorOrSource: "Mü'minûn Suresi, 118. Ayet",
            category: .friday,
            tags: ["cuma", "merhamet", "dua"]
        ),
        SpiritualMessage(
            id: "fri_08",
            title: "Selam ve Muhabbetle",
            arabicText: nil,
            text: "Dua kapılarının ardına kadar açıldığı bu mübarek Cuma gününde, dualarınızda yer bulmak dileğiyle... Cumanız mübarek olsun.",
            authorOrSource: "NurVakti İklimi",
            category: .friday,
            tags: ["cuma", "kısa", "samimi"]
        ),
        SpiritualMessage(
            id: "fri_09",
            title: "Gönüllerin Bayramı",
            arabicText: "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
            text: "Şüphesiz her güçlükle beraber bir kolaylık vardır. Darlıkların feraha, karanlıkların nura kavuştuğu hayırlı Cumalar dilerim.",
            authorOrSource: "İnşirah Suresi, 6. Ayet",
            category: .friday,
            tags: ["cuma", "inşirah", "ferahlık"]
        ),
        SpiritualMessage(
            id: "fri_10",
            title: "Nurlu Vakitler",
            arabicText: nil,
            text: "Allah'ım! Bize hakkı hak olarak gösterip ona uymayı, bâtılı da bâtıl gösterip ondan sakınmayı nasip eyle. Cumanız hayırlara vesile olsun.",
            authorOrSource: "Hadis-i Şerif Meali",
            category: .friday,
            tags: ["cuma", "hidayet", "hadis"]
        ),
        SpiritualMessage(
            id: "fri_11",
            title: "Cuma Niyazı",
            arabicText: "رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا",
            text: "Rabbimiz! Bizi doğru yola eriştirdikten sonra kalplerimizi saptırma, katından bize bir rahmet bağışla. Hayırlı ve bereketli Cumalar.",
            authorOrSource: "Âl-i İmrân Suresi, 8. Ayet",
            category: .friday,
            tags: ["cuma", "istikamet", "dua"]
        ),
        SpiritualMessage(
            id: "fri_12",
            title: "Hayırlı Dualar",
            arabicText: nil,
            text: "Bugün ettiğiniz tüm dualar semaya yükselsin, kabul kapılarından geçip hanenize rahmet olarak geri dönsün. Cuma günümüz mübarek olsun.",
            authorOrSource: "NurVakti Gönül Pınarı",
            category: .friday,
            tags: ["cuma", "rahmet", "kabul"]
        )
    ]
    
    // ── 2. Kandil Mesajları (Mevlid, Regaip, Miraç, Berat, Kadir Gecesi) ──
    public static let kandilMessages: [SpiritualMessage] = [
        // Mevlid Kandili
        SpiritualMessage(
            id: "kandil_mevlid_01",
            title: "Mevlid Kandili Mübarek Olsun",
            arabicText: "وَمَا أَرْسَلْنَاكَ إِلَّا رَحْمَةً لِّلْعَالَمِينَ",
            text: "Âlemlere rahmet olarak gönderilen Sevgili Peygamberimiz Hz. Muhammed Mustafa (s.a.v.)'in dünyayı şereflendirdiği bu kutlu gecede, Mevlid Kandiliniz mübarek olsun.",
            authorOrSource: "Enbiyâ Suresi, 107. Ayet",
            category: .kandil,
            subCategory: KandilSubType.mevlid.rawValue,
            tags: ["mevlid", "kandil", "peygamber", "salavat"]
        ),
        SpiritualMessage(
            id: "kandil_mevlid_02",
            title: "Gönüllerin Efendisi",
            arabicText: "اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ",
            text: "O'nun ahlakıyla ahlaklanmayı, sünnet-i seniyyesine sarılmayı ve şefaatine nail olmayı Rabbim cümlemize lütfeylesin. Mevlid Geceniz hayırlara vesile olsun.",
            authorOrSource: "Salavat-ı Şerife",
            category: .kandil,
            subCategory: KandilSubType.mevlid.rawValue,
            tags: ["mevlid", "kandil", "şefaat"]
        ),
        
        // Regaip Kandili
        SpiritualMessage(
            id: "kandil_regaip_01",
            title: "Regaip Kandiliniz Mübarek Olsun",
            arabicText: "اللَّهُمَّ بَارِكْ لَنَا فِي رَجَبَ وَشَعْبَانَ وَبَلِّغْنَا رَمَضَانَ",
            text: "“Allah'ım! Recep ve Şaban aylarını bizim için mübarek kıl ve bizi Ramazan'a ulaştır.” Üç ayların ilk müjdecisi olan Regaip Kandiliniz mübarek olsun.",
            authorOrSource: "Ahmed b. Hanbel, Müsned, I, 259",
            category: .kandil,
            subCategory: KandilSubType.regaip.rawValue,
            tags: ["regaip", "üç aylar", "kandil", "ramazan"]
        ),
        SpiritualMessage(
            id: "kandil_regaip_02",
            title: "Rahmet ve Mağfiret Müjdesi",
            arabicText: nil,
            text: "Rağbetimizin yalnızca Rabbimize olduğu, dualarımızın kabul, günahlarımızın mağfiret kılındığı nurlu bir Regaip Kandili dilerim.",
            authorOrSource: "NurVakti İklimi",
            category: .kandil,
            subCategory: KandilSubType.regaip.rawValue,
            tags: ["regaip", "kandil", "dua"]
        ),
        
        // Miraç Kandili
        SpiritualMessage(
            id: "kandil_mirac_01",
            title: "Miraç Kandili Mübarek Olsun",
            arabicText: "سُبْحَانَ الَّذِي أَسْرَىٰ بِعَبْدِهِ لَيْلًا مِّنَ الْمَسْجِدِ الْحَرَامِ إِلَى الْمَسْجِدِ الْأَقْصَى",
            text: "Peygamber Efendimiz'in semaya yükselişi ve namazın müjdelendiği bu mübarek gecede, manevi yükseliş ve kurtuluş niyazıyla Miraç Kandilinizi tebrik ederiz.",
            authorOrSource: "İsrâ Suresi, 1. Ayet",
            category: .kandil,
            subCategory: KandilSubType.mirac.rawValue,
            tags: ["mirac", "kandil", "namaz", "yükseliş"]
        ),
        SpiritualMessage(
            id: "kandil_mirac_02",
            title: "Namaz Müminin Miracıdır",
            arabicText: nil,
            text: "Gönüllerin huzura erdiği, ellerin semaya açıldığı Miraç Gecesi'nde Rabbim dualarınızı kabul, kalbinizi iman nuruyla mamur eylesin.",
            authorOrSource: "Manevi Sohbetler",
            category: .kandil,
            subCategory: KandilSubType.mirac.rawValue,
            tags: ["mirac", "kandil", "namaz"]
        ),
        
        // Berat Kandili
        SpiritualMessage(
            id: "kandil_berat_01",
            title: "Berat Kandiliniz Mübarek Olsun",
            arabicText: "إِنَّا أَنزَلْنَاهُ فِي لَيْلَةٍ مُّبَارَكَةٍ",
            text: "Af, mağfiret ve kurtuluş kapılarının sonuna kadar açıldığı Berat Kandili'nde Rabbim hepimize günahlardan arınmış ak bir berat nasip eylesin.",
            authorOrSource: "Duhân Suresi, 3. Ayet",
            category: .kandil,
            subCategory: KandilSubType.berat.rawValue,
            tags: ["berat", "kandil", "af", "mağfiret"]
        ),
        SpiritualMessage(
            id: "kandil_berat_02",
            title: "Gönüllerin Arınma Gecesi",
            arabicText: nil,
            text: "İlahi rahmetin sağanak sağanak yağdığı bu müstesna gecede, dualarınız kabul, kalbiniz nurlu, Berat Kandiliniz mübarek olsun.",
            authorOrSource: "NurVakti",
            category: .kandil,
            subCategory: KandilSubType.berat.rawValue,
            tags: ["berat", "kandil", "tövbe"]
        ),
        
        // Kadir Gecesi
        SpiritualMessage(
            id: "kandil_kadir_01",
            title: "Kadir Geceniz Mübarek Olsun",
            arabicText: "لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ",
            text: "“Kadir Gecesi bin aydan daha hayırlıdır.” Kur'an-ı Kerim'in indirildiği bu kutlu gecede, bağışlanma ve ebedi kurtuluşa ermeniz dileğiyle. Kadir Geceniz mübarek olsun.",
            authorOrSource: "Kadr Suresi, 3. Ayet",
            category: .kandil,
            subCategory: KandilSubType.kadir.rawValue,
            tags: ["kadir", "kadir gecesi", "kuran", "kandil"]
        ),
        SpiritualMessage(
            id: "kandil_kadir_02",
            title: "Kadir Gecesi Duası",
            arabicText: "اللَّهُمَّ إِنَّكَ عَفُوٌّ كَرِيمٌ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي",
            text: "“Allah'ım! Sen çok affedicisin, ikram sahibisin, affetmeyi seversin, beni de affet.” Kadir Geceniz feyizli ve bereketli olsun.",
            authorOrSource: "Tirmizî, Deavât, 84",
            category: .kandil,
            subCategory: KandilSubType.kadir.rawValue,
            tags: ["kadir", "dua", "af", "tirmizi"]
        )
    ]
    
    // ── 3. Bayram Mesajları (Ramazan, Kurban, Arefe) ──
    public static let bayramMessages: [SpiritualMessage] = [
        SpiritualMessage(
            id: "bayram_ramazan_01",
            title: "Ramazan Bayramınız Mübarek Olsun",
            arabicText: "تَقَبَّلَ اللَّهُ مِنَّا وَمِنْكُمْ",
            text: "Birlik, beraberlik ve sevgiyle dolu; dargınlıkların unutulduğu, hanelerimizin neşeyle dolup taştığı huzurlu bir Ramazan Bayramı dilerim. Bayramınız mübarek olsun.",
            authorOrSource: "Geleneksel Bayram Duası",
            category: .bayram,
            subCategory: BayramSubType.ramadan.rawValue,
            tags: ["ramazan bayramı", "bayram", "tebrik", "sevinç"]
        ),
        SpiritualMessage(
            id: "bayram_ramazan_02",
            title: "Bayram Sevinci",
            arabicText: nil,
            text: "Rabbim tuttuğumuz oruçları, yaptığımız ibadetleri kabul buyursun. Sevdiklerinizle birlikte sağlıklı, neşeli ve nurlu nice bayramlara ulaşmanız dileğiyle.",
            authorOrSource: "NurVakti",
            category: .bayram,
            subCategory: BayramSubType.ramadan.rawValue,
            tags: ["ramazan bayramı", "bayram", "aile"]
        ),
        SpiritualMessage(
            id: "bayram_kurban_01",
            title: "Kurban Bayramınız Mübarek Olsun",
            arabicText: "لَن يَنَالَ اللَّهَ لُحُومُهَا وَلَا دِمَاؤُهَا وَلَٰكِن يَنَالُهُ التَّقْوَىٰ مِنكُمْ",
            text: "“Onların ne etleri ne de kanları Allah'a ulaşır; fakat O'na sadece sizin takvanız ulaşır.” Kurbanlarınızın makbul, Bayramınızın hayırlı ve bereketli olmasını dilerim.",
            authorOrSource: "Hac Suresi, 37. Ayet",
            category: .bayram,
            subCategory: BayramSubType.eidAlAdha.rawValue,
            tags: ["kurban bayramı", "kurban", "takva", "bayram"]
        ),
        SpiritualMessage(
            id: "bayram_kurban_02",
            title: "Kurban ve Teslimiyet",
            arabicText: nil,
            text: "Hz. İbrahim'in sadakati, Hz. İsmail'in teslimiyetiyle süslenen bu mübarek Kurban Bayramı'nın İslam alemine barış, huzur ve esenlik getirmesini niyaz ederim.",
            authorOrSource: "NurVakti İklimi",
            category: .bayram,
            subCategory: BayramSubType.eidAlAdha.rawValue,
            tags: ["kurban", "bayram", "teslimiyet"]
        ),
        SpiritualMessage(
            id: "bayram_arefe_01",
            title: "Arefe Gününüz Mübarek Olsun",
            arabicText: "خَيْرُ الدُّعَاءِ دُعَاءُ يَوْمِ عَرَفَةَ",
            text: "“Duaların en hayırlısı Arefe günü yapılan duadır.” Kalplerinizin af ile, hanelerinizin sürur ile dolduğu bereketli bir Arefe günü dilerim.",
            authorOrSource: "Tirmizî, Deavât, 122",
            category: .bayram,
            subCategory: BayramSubType.arafah.rawValue,
            tags: ["arefe", "dua", "bayram müjdesi"]
        )
    ]
    
    // ── 4. Özel Günler (Üç Aylar, Aşure Günü, Hicri Yılbaşı) ──
    public static let specialDaysMessages: [SpiritualMessage] = [
        SpiritualMessage(
            id: "special_ucaylar_01",
            title: "Üç Aylarınız Mübarek Olsun",
            arabicText: "اللَّهُمَّ بَارِكْ لَنَا فِي رَجَبَ وَشَعْبَانَ وَبَلِّغْنَا رَمَضَانَ",
            text: "Rahmet, mağfiret ve bereket mevsimi olan Üç Aylar'ın (Recep, Şaban, Ramazan) gönüllerimize huzur, hanelerimize nur getirmesini dilerim.",
            authorOrSource: "Hadis-i Şerif",
            category: .specialDays,
            tags: ["üç aylar", "recep", "şaban", "ramazan"]
        ),
        SpiritualMessage(
            id: "special_hicri_01",
            title: "Hicri Yılbaşınız Mübarek Olsun",
            arabicText: "إِلَّا تَنصُرُوهُ فَقَدْ نَصَرَهُ اللَّهُ",
            text: "Hicret; karanlıktan aydınlığa, bâtıldan hakka yönelişin sembolüdür. Yeni Hicri yılınızın sağlık, barış ve hidayet getirmesini temenni ederim.",
            authorOrSource: "Tevbe Suresi, 40. Ayet",
            category: .specialDays,
            tags: ["hicri yılbaşı", "muharrem", "yeni yıl"]
        ),
        SpiritualMessage(
            id: "special_asure_01",
            title: "Aşure Gününüz Mübarek Olsun",
            arabicText: nil,
            text: "Muharrem ayının 10. günü olan Aşure Günü'nün bereket, kardeşlik ve paylaşıma vesile olmasını diler; şehitlerin efendisi Hz. Hüseyin ve Kerbela şehitlerini rahmetle anarız.",
            authorOrSource: "NurVakti Manevi Miras",
            category: .specialDays,
            tags: ["aşure", "muharrem", "birlik"]
        )
    ]
    
    // ── 5. Günün Sözü & Hikmetli Sözler (Hz. Ali, Mevlana, Yunus Emre, Gazali vb.) ──
    public static let dailyWisdomMessages: [SpiritualMessage] = [
        SpiritualMessage(
            id: "wisdom_hzali_01",
            title: "Hikmet Pınarı",
            arabicText: nil,
            text: "“İnsanların solukları, ecellerine doğru attıkları adımlarıdır. Gönlünü temiz tut ki amelinin nuru artsın.”",
            authorOrSource: "Hz. Ali (r.a.)",
            category: .dailyWisdom,
            tags: ["hikmet", "hz ali", "nasihat"]
        ),
        SpiritualMessage(
            id: "wisdom_mevlana_01",
            title: "Gönül Gözü",
            arabicText: nil,
            text: "“Dünle beraber gitti, cancağızım, ne kadar söz varsa düne ait. Şimdi yeni şeyler söylemek lazım.”",
            authorOrSource: "Mevlânâ Celâleddîn-i Rûmî",
            category: .dailyWisdom,
            tags: ["mevlana", "gönül", "hikmet"]
        ),
        SpiritualMessage(
            id: "wisdom_yunus_01",
            title: "Sevgi ve Muhabbet",
            arabicText: nil,
            text: "“Sevelim, sevilelim; bu dünya kimseye kalmaz. Gelin tanış olalım, işi kolay kılalım.”",
            authorOrSource: "Yunus Emre",
            category: .dailyWisdom,
            tags: ["yunus emre", "sevgi", "tasavvuf"]
        ),
        SpiritualMessage(
            id: "wisdom_gazali_01",
            title: "Kalp ve Amel",
            arabicText: nil,
            text: "“Niyeti halis olanın ameli az olsa da bereketi çok olur. Kalbini dünya hırsından arındıran, hakiki huzura erer.”",
            authorOrSource: "İmâm-ı Gazâlî (r.a.)",
            category: .dailyWisdom,
            tags: ["gazali", "niyet", "ihlas"]
        ),
        SpiritualMessage(
            id: "wisdom_hasanbasri_01",
            title: "Vaktin Kıymeti",
            arabicText: nil,
            text: "“Ey Âdemoğlu! Sen günlerden ibaretsin; bir günün geçtiğinde, bir parçan da eksilmiş demektir.”",
            authorOrSource: "Hasan-ı Basrî (r.a.)",
            category: .dailyWisdom,
            tags: ["hasan basri", "vakit", "ömür"]
        ),
        SpiritualMessage(
            id: "wisdom_hzali_02",
            title: "Sabır ve Şükür",
            arabicText: nil,
            text: "“Sabır, imanın başıdır; başı olmayan bir vücutta hayır olmadığı gibi, sabrı olmayanda da iman kemale ermez.”",
            authorOrSource: "Hz. Ali (r.a.)",
            category: .dailyWisdom,
            tags: ["sabır", "iman", "hz ali"]
        ),
        SpiritualMessage(
            id: "wisdom_mevlana_02",
            title: "Dua Kapısı",
            arabicText: nil,
            text: "“Kapı açılır, sen yeter ki vurmayı bil! Ne zaman, bilmem! Yeter ki o kapıda durmayı bil!”",
            authorOrSource: "Mevlânâ Celâleddîn-i Rûmî",
            category: .dailyWisdom,
            tags: ["mevlana", "dua", "ümit"]
        ),
        SpiritualMessage(
            id: "wisdom_geylani_01",
            title: "İhlas ve Tevekkül",
            arabicText: nil,
            text: "“Halktan ümidini kesip yalnız Hakk'a bağlanan kul, hem dünyada izzete hem ahirette saadete kavuşur.”",
            authorOrSource: "Abdülkâdir Geylânî (k.s.)",
            category: .dailyWisdom,
            tags: ["ihlas", "tevekkül", "tasavvuf"]
        ),
        SpiritualMessage(
            id: "wisdom_fudayl_01",
            title: "Gönül Zenginliği",
            arabicText: nil,
            text: "“Mütevazı ol; tevazu insanı yükseltir, kibir ise alçaltır. Hakiki zenginlik, kanaat dolu bir kalptir.”",
            authorOrSource: "Fudayl b. İyâz (r.a.)",
            category: .dailyWisdom,
            tags: ["tevazu", "kanaat", "hikmet"]
        ),
        SpiritualMessage(
            id: "wisdom_hzebubekir_01",
            title: "İstikamet",
            arabicText: nil,
            text: "“Amelinde Allah'ın rızasını gözet. Zira O'nun rızası olmayan hiçbir sözde ve amelde hayır yoktur.”",
            authorOrSource: "Hz. Ebubekir Sıddık (r.a.)",
            category: .dailyWisdom,
            tags: ["istikamet", "rıza", "sahabe"]
        )
    ]
}
