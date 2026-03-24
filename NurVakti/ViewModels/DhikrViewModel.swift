import Foundation
import Combine
import SwiftUI

@MainActor
final class DhikrViewModel: ObservableObject {
    @Published var dhikrItems: [DhikrItem] = []
    @Published var activeItem: DhikrItem {
        didSet {
            saveItems()
        }
    }
    @Published var activeIndex: Int = 0
    @Published var showingAddSheet: Bool = false
    @Published var dailyStats: [UUID: Int] = [:]
    
    @Published var morningDuas: [DuaItem] = []
    @Published var eveningDuas: [DuaItem] = []
    
    // Geçici State (Yeni Zikir Ekleme için)
    @Published var newDhikrName: String = ""
    @Published var newDhikrArabic: String = ""
    @Published var newDhikrTarget: String = "33"
    
    private let persistService: PersistenceService
    
    init(persistService: PersistenceService = .shared) {
        self.persistService = persistService
        var items = persistService.dhikrItems
        
        // Eksik anlamları tamamla (Eski veriler için)
        for i in 0..<items.count {
            if !items[i].isCustom && items[i].meanings.isEmpty {
                items[i].meanings[.tr] = items[i].type.meaning(for: .tr)
                items[i].meanings[.en] = items[i].type.meaning(for: .en)
            }
        }
        self.dhikrItems = items
        
        // İlk item'ı aktif yap
        if let first = items.first {
            self.activeItem = first
        } else {
            self.activeItem = DhikrItem(id: UUID(), type: .subhanallah, arabicText: "سبحان الله", transliterationTR: "", meanings: [.tr: "Allah noksan sıfatlardan uzaktır"], targetCount: 33, currentCount: 0, isCustom: false, vibrateOnCount: true, dailyCompletions: 0, totalCompletions: 0)
        }
        
        loadDuas()
    }
    
    private func loadDuas() {
        let ayetElKursi = DuaItem(
            id: UUID(),
            title: [.tr: "Ayet-el Kürsi", .en: "Ayat al-Kursi"],
            arabicText: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ",
            transliteration: [.tr: "Allâhu lâ ilâhe illâ huvel hayyul kayyûm, lâ te'huzuhu sinetun velâ nevm, lehu mâ fissemâvâti ve mâ fil'ard, menzellezî yeşfeu indehu illâ bi'iznih, ya'lemu mâ beyne eydîhim vemâ halfehum, velâ yuhîtûne bişey'im min ilmihî illâ bimâ şâe vesia kursiyyuhussemâvâti vel'ard, velâ yeûduhu hıfzuhumâ ve huvel aliyyul azîm.", .en: "Allahu la ilaha illa huwal hayyul qayyum, la ta'khudhuhu sinatun wala nawm..."],
            translation: [.tr: "Allah, O'ndan başka ilah yoktur. Diridir, kaimdir. O'nu ne bir uyuklama ne de bir uyku tutar. Göklerdeki ve yerdeki her şey O'nundur. İzni olmadan O'nun katında şefaatte bulunacak kimdir? O, kullarının önlerindekileri ve arkalarındakileri bilir. Onlar O'nun ilminden, kendisinin dilediği kadarından başka bir şey kavrayamazlar. O'nun kürsüsü gökleri ve yeri kaplamıştır. Onları korumak O'na ağır gelmez. O, yücedir, büyüktür.", .en: "Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence..."],
            category: .morning,
            audioArabicURL: "https://server8.mp3quran.net/afs/002255.mp3"
        )
        
        let felakNas = DuaItem(
            id: UUID(),
            title: [.tr: "Felak & Nas", .en: "Al-Falaq & An-Nas"],
            arabicText: "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ... قُلْ أَعُوذُ بِرَبِّ النَّاسِ...",
            transliteration: [.tr: "Kul eûzu birabbil felak... Kul eûzu birabbin nâs...", .en: "Qul a'udhu bi rabbil-falaq... Qul a'udhu bi rabbin-nas..."],
            translation: [.tr: "De ki: Yarattığı şeylerin kötülüğünden, karanlığı çöktüğü zaman gecenin kötülüğünden, düğümlere üfleyenlerin kötülüğünden, haset ettiği zaman hasetçinin kötülüğünden, sabah aydınlığının Rabbine sığınırım. De ki: Cinlerden ve insanlardan; insanların kalplerine vesvese veren sinsi vesvesecinin kötülüğünden, insanların Rabbine, insanların Melik'ine, insanların İlah'ına sığınırım.", .en: "Say, \"I seek refuge in the Lord of daybreak... Say, \"I seek refuge in the Lord of mankind..."],
            category: .morning,
            audioArabicURL: "https://server8.mp3quran.net/afs/113.mp3"
        )
        
        let amenerrasulu = DuaItem(
            id: UUID(),
            title: [.tr: "Amenerrasulü", .en: "Amanar Rasulu"],
            arabicText: "آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِّن رُّسُلِهِ ۚ وَقَالُوا سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ",
            transliteration: [.tr: "Âmenerrasûlu bimâ unzile ileyhi mirrabbihî vel mu'minûn, kullun âmene billâhi ve melâiketihî ve kutubihî ve rusulih, lâ nuferriku beyne ehadim mirrusulih, ve kâlû semi'nâ ve ata'nâ gufrâneke rabbenâ ve ileykel masîr.", .en: "Amanar-rasulu bima unzila ilayhi..."],
            translation: [.tr: "Peygamber, Rabbinden kendisine indirilene iman etti, müminler de (iman ettiler). Her biri; Allah'a, meleklerine, kitaplarına ve peygamberlerine iman ettiler ve şöyle dediler: \"Onun peygamberlerinden hiçbirini (diğerinden) ayırt etmeyiz.\" Şöyle de dediler: \"İşittik ve itaat ettik. Ey Rabbimiz! Senden bağışlama dileriz. Sonunda dönüş yalnız sanadır.\"", .en: "The Messenger has believed in what was revealed to him..."],
            category: .evening,
            audioArabicURL: "https://server8.mp3quran.net/afs/002285.mp3"
        )
        
        let hasrSon = DuaItem(
            id: UUID(),
            title: [.tr: "Lev Enzelna", .en: "Lew Enzelna"],
            arabicText: "لَوْ أَنزَلْنَا هَٰذَا الْقُرْآنَ عَلَىٰ جَبَلٍ لَّرَأَيْتَهُ خَاشِعًا مُّتَصَدِّعًا مِّنْ خَشْيَةِ اللَّهِ ۚ وَتِلْكَ الْأَمْثَالُ نَضْرِبُهَا لِلنَّاسِ لَعَلَّهُمْ يَتَفَكَّرُونَ",
            transliteration: [.tr: "Lev enzelnâ hâzel kur'âne alâ cebelin leraeytehû hâşian mutesaddian min haşyetillâh, ve tilkel emsâlu nadribuhâ linnâsi leallehum yetefekkerûn.", .en: "Law anzalna hadhal-qur'ana..."],
            translation: [.tr: "Eğer biz bu Kur'an'ı bir dağın üzerine indirseydik, muhakkak ki onu Allah korkusundan baş eğerek, parça parça olmuş görürdün. Biz bu misalleri insanlara düşünsünler diye veriyoruz.", .en: "If We had sent down this Qur'an upon a mountain..."],
            category: .evening,
            audioArabicURL: "https://server11.mp3quran.net/yasser/059021.mp3"
        )
        
        morningDuas = [ayetElKursi, felakNas]
        eveningDuas = [amenerrasulu, hasrSon]
    }
    
    func increment() {
        // Active item artır
        activeItem.increment()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Titreşim (Aygıt bazlı titreşim için özel paket gerekebilir, burada placeholder)
        if activeItem.vibrateOnCount && activeItem.currentCount % 33 == 0 {
            // UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
        // Tamamlandıysa persist et
        if activeItem.isCompleted && activeItem.currentCount == activeItem.targetCount {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            // Konfeti tetikleyici (View tarafında handles)
        }
        
        saveItems()
    }
    
    func reset() {
        activeItem.reset()
        saveItems()
    }
    
    func selectDhikr(_ item: DhikrItem) {
        if let index = dhikrItems.firstIndex(where: { $0.id == item.id }) {
            self.activeIndex = index
            self.activeItem = item
        }
    }
    
    func addCustomDhikr(name: [LanguageCode: String], arabicText: String, target: Int) {
        let newItem = DhikrItem(id: UUID(), 
                                type: .custom, 
                                arabicText: arabicText, 
                                transliterationTR: "", 
                                meanings: name, 
                                targetCount: target, 
                                currentCount: 0, 
                                isCustom: true, 
                                vibrateOnCount: true, 
                                dailyCompletions: 0, 
                                totalCompletions: 0)
        dhikrItems.append(newItem)
        self.activeItem = newItem // Yeni ekleneni hemen aktif yap
        saveItems()
    }
    
    func deleteDhikr(id: UUID) {
        dhikrItems.removeAll { $0.id == id }
        saveItems()
    }
    
    func resetNewDhikrFields() {
        newDhikrName = ""
        newDhikrArabic = ""
        newDhikrTarget = "33"
    }
    
    func saveNewDhikr() -> Bool {
        guard !newDhikrName.isEmpty, let target = Int(newDhikrTarget) else {
            return false
        }
        
        addCustomDhikr(name: [.tr: newDhikrName], arabicText: newDhikrArabic, target: target)
        resetNewDhikrFields()
        return true
    }
    
    private func saveItems() {
        // Update list with current active state
        if let index = dhikrItems.firstIndex(where: { $0.id == activeItem.id }) {
            dhikrItems[index] = activeItem
        }
        persistService.saveDhikr(dhikrItems)
    }
    
    func languageDidChange(_ code: LanguageCode) {
        // Gerekli metin güncellemeleri
    }
}
