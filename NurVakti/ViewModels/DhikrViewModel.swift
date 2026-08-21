import Foundation
import Combine
import SwiftUI
import WidgetKit

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
    private let audioManager = AudioManager.shared
    
    private let persistService: PersistenceService
    
    init(persistService: PersistenceService? = nil) {
        let actualPersistService = persistService ?? .shared
        self.persistService = actualPersistService
        var items = actualPersistService.dhikrItems
        
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
        // --- Mevcut Dualar ---
        let ayetElKursi = DuaItem(
            id: UUID(),
            title: [.tr: "Ayet-el Kürsi", .en: "Ayat al-Kursi"],
            arabicText: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ",
            transliteration: [.tr: "Allâhu lâ ilâhe illâ huvel hayyul kayyûm, lâ te'huzuhu sinetun velâ nevm, lehu mâ fissemâvâti ve mâ fil'ard, menzellezî yeşfeu indehu illâ bi'iznih, ya'lemu mâ beyne eydîhim vemâ halfehum, velâ yuhîtûne bişey'im min ilmihî illâ bimâ şâe vesia kursiyyuhussemâvâti vel'ard, velâ yeûduhu hıfzuhumâ ve huvel aliyyul azîm.", .en: "Allahu la ilaha illa huwal hayyul qayyum..."],
            translation: [.tr: "Allah, O'ndan başka ilah yoktur. Diridir, kaimdir. O'nu ne bir uyuklama ne de bir uyku tutar. Göklerde ve yerde ne varsa hepsi O'nundur. İzni olmadan huzurunda şefaat edecek olan kimdir? O, kullarının önlerinde ve arkalarında ne varsa hepsini bilir. Onlar ise, O'nun dilediği kadarından başka ilminden hiçbir şeyi kavrayamazlar. O'nun kürsisi, bütün gökleri ve yeri kaplayıp kuşatmıştır. Gökleri ve yeri koruyup gözetmek O'na güç gelmez. O, yücedir, büyüktür.", .en: "Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence..."],
            category: .morning,
            surahNumber: 2,
            ayahNumber: 255
        )
        
        let felak = DuaItem(
            id: UUID(),
            title: [.tr: "Felak", .en: "Al-Falaq"],
            arabicText: "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ (1) مِنْ شَرِّ مَا خَلَقَ (2) وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ (3) وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ (4) وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ (5)",
            transliteration: [.tr: "Kul eûzu birabbil felak. Min şerri mâ halak. Ve min şerri ğâsikın izâ vekab. Ve min şerrin-neffâsâti fil ukad. Ve min şerri hâsidin izâ hased.", .en: "Qul a'udhu bi rabbil-falaq..."],
            translation: [.tr: "De ki: Yarattığı şeylerin kötülüğünden, karanlığı çöktüğü zaman gecenin kötülüğünden, düğümlere üfleyenlerin kötülüğünden, haset ettiği zaman hasetçinin kötülüğünden, sabah aydınlığının Rabbine sığınırım.", .en: "Say, \"I seek refuge in the Lord of daybreak..."],
            category: .morning,
            surahNumber: 113 // No ayahNumber = Full Surah
        )

        let nas = DuaItem(
            id: UUID(),
            title: [.tr: "Nas", .en: "An-Nas"],
            arabicText: "قُلْ أَعُوذُ بِرَبِّ النَّاسِ (1) مَلِكِ النَّاسِ (2) إِلَهِ النَّاسِ (3) مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ (4) الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ (5) مِنَ الْجِنَّةِ وَالنَّاسِ (6)",
            transliteration: [.tr: "Kul eûzu birarbin-nâs. Melikin-nâs. İlâhin-nâs. Min şerril vesvâsil hannâs. Ellezî yüvesvisü fî sudûrin-nâs. Minel cinneti ven-nâs.", .en: "Qul a'udhu bi rabbin-nas..."],
            translation: [.tr: "De ki: İnsanların Rabbine, insanların hükümdarına, insanların ilâhına; o sinsi vesvesecinin şerrinden Allah’a sığınırım. O ki insanların göğüslerine vesvese verir, o hem cinlerden hem de insanlardandır.", .en: "Say, \"I seek refuge in the Lord of mankind..."],
            category: .morning,
            surahNumber: 114 // No ayahNumber = Full Surah
        )
        
        // --- Yeni Eklenen Dualar ---
        let seyyidulIstigfar = DuaItem(
            id: UUID(),
            title: [.tr: "Seyyidü'l İstiğfar", .en: "The Master of Forgiveness"],
            arabicText: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ",
            transliteration: [.tr: "Allahümme ente Rabbî lâ ilâhe illâ ente halaktenî ve ene abdüke ve ene alâ ahdike ve va’dike masta’ta’tü. Eûzü bike min şerri mâ sana’tü. Ebûü leke bi-ni’metike aleyye ve ebûü leke bi-zenbî fağfir-lî feinnehû lâ yağfirü’z-zünûbe illâ ente.", .en: "Allahumma anta Rabbi la ilaha illa anta, khalaqtani wa ana 'abduka..."],
            translation: [.tr: "Allah'ım! Sen benim Rabbimsin. Senden başka ilâh yoktur. Beni Sen yarattın ve ben Senin kulunum. Gücüm yettiğince Sana verdiğim ahd ve va'dim üzereyim. Yaptıklarımın şerrinden Sana sığınırım...", .en: "O Allah, You are my Lord, none has the right to be worshipped except You. You created me and I am Your servant..."],
            category: .morning,
            audioArabicURL: "https://www.duas.org/audio/Day/Seyyidul_Istighfar.mp3"
        )
        
        let korunmaDuasi = DuaItem(
            id: UUID(),
            title: [.tr: "Korunma Duası", .en: "Dua for Protection"],
            arabicText: "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
            transliteration: [.tr: "Bismillâhillezî lâ yedurru measmihî şey’un fil-ardı velâ fissemâi ve hüvessemîul alîm.", .en: "Bismillahilladhi la yadurru ma'asmihi shay'un fil-ardi wala fis-sama'i..."],
            translation: [.tr: "İsmiyle yerde ve gökte hiçbir şeyin zarar veremeyeceği Allah’ın adıyla ki, O her şeyi işitir ve bilir.", .en: "In the name of Allah, with whose name nothing on earth or in the sky can harm..."],
            category: .morning,
            audioArabicURL: "https://www.duas.org/audio/Protection/Protection_Dua.mp3"
        )
        
        let rabbena = DuaItem(
            id: UUID(),
            title: [.tr: "Rabbena Duaları", .en: "Rabbana Prayers"],
            arabicText: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ. رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ",
            transliteration: [.tr: "Rabbenâ âtinâ fid-dünyâ haseneten ve fil-âhireti haseneten ve kınâ azâben-nâr. Rabbenâğfirlî ve livâlideyye ve lil-mü'minîne yevme yekūmül-hisâb.", .en: "Rabbana atina fid-dunya hasanatan..."],
            translation: [.tr: "Rabbimiz, bize dünyada da iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru. Rabbimiz! Hesabın görüleceği gün beni, anamı, babamı ve müminleri bağışla.", .en: "Our Lord, give us in this world [that which is] good and in the Hereafter [that which is] good..."],
            category: .general,
            surahNumber: 2,
            ayahNumber: 201
        )
        
        let yunusDua = DuaItem(
            id: UUID(),
            title: [.tr: "Yunus (a.s) Duası", .en: "Dua of Prophet Yunus"],
            arabicText: "لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ",
            transliteration: [.tr: "Lâ ilâhe illâ ente sübhâneke innî küntü minez-zâlimîn.", .en: "La ilaha illa anta subhanaka inni kuntu minaz-zalimin."],
            translation: [.tr: "Senden başka ilah yoktur. Seni eksikliklerden uzak tutarım. Ben kuşkusuz (nefsine) zulmedenlerden oldum.", .en: "There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers."],
            category: .general,
            surahNumber: 21,
            ayahNumber: 87
        )
        
        let hasbiyallahu = DuaItem(
            id: UUID(),
            title: [.tr: "Hasbiyallâhu", .en: "Hasbiyallahu"],
            arabicText: "حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ ۖ عَلَيْهِ تَوَكَّلْتُ ۖ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ",
            transliteration: [.tr: "Hasbiyallâhu lâ ilâhe illâ hûve aleyhi tevekkeltü ve hüve rabbül-arşil-azîm.", .en: "Hasbiyallahu la ilaha illa huwa 'alayhi tawakkaltu..."],
            translation: [.tr: "Bana Allah yeter. O'ndan başka ilah yoktur. Ben O'na tevekkül ettim. O, yüce Arş'ın sahibidir.", .en: "Sufficient for me is Allah; there is no deity except Him..."],
            category: .morning,
            audioArabicURL: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1364.mp3",
            surahNumber: 9,
            ayahNumber: 129
        )
        
        let amenerrasulu = DuaItem(
            id: UUID(),
            title: [.tr: "Amenerrasulü", .en: "Amanar Rasulu"],
            arabicText: "آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ...",
            transliteration: [.tr: "Âmenerrasûlu bimâ unzile ileyhi mirrabbihî..."],
            translation: [.tr: "Peygamber, Rabbinden kendisine indirilene iman etti, müminler de iman ettiler...", .en: "The Messenger has believed in what was revealed to him..."],
            category: .evening,
            surahNumber: 2,
            ayahNumber: 285
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
        
        morningDuas = [ayetElKursi, felak, nas, seyyidulIstigfar, korunmaDuasi, hasbiyallahu]
        eveningDuas = [amenerrasulu, hasrSon, yunusDua, rabbena]
    }
    
    func playDuaAudio(for item: DuaItem) {
        audioManager.playDua(item: item)
    }

    func stopAudio() {
        audioManager.stop()
    }
    
    func increment() {
        // Active item artır
        activeItem.increment()
        
        // Haptic feedback — her dokunuşta hafif titreşim (tesbih hissi)
        if activeItem.isCompleted && activeItem.currentCount == activeItem.targetCount {
            HapticManager.shared.dhikrDone()
        } else {
            HapticManager.shared.light()
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
        
        // Widget verisini yaz
        let lang = LocalizationManager.shared.currentLanguage
        let name = activeItem.meanings[lang] ?? activeItem.meanings[.tr] ?? "Zikir"
        NurWidgetData.updateDhikr(
            name: name,
            count: activeItem.currentCount,
            target: activeItem.targetCount
        )
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Günlük Sıfırlama
    /// Uygulama her açıldığında çağrılır.
    /// Eğer son sıfırlama bugün değilse, tüm dhikrlerin günlük sayılarını sıfırlar.
    func resetDailyIfNeeded() {
        let key = "dhikr_last_reset_date"
        let lastReset = UserDefaults.standard.object(forKey: key) as? Date
        let today = Calendar.current.startOfDay(for: Date())
        
        guard lastReset == nil || lastReset! < today else { return }
        
        // Sıfırla: currentCount = 0, dailyCompletions güncelle
        for i in dhikrItems.indices {
            if dhikrItems[i].currentCount > 0 {
                // Bugünkü tamamlanma sayısını güncelle
                dhikrItems[i].dailyCompletions += 1
                dhikrItems[i].currentCount = 0
            }
        }
        
        // Aktif item'ı da sıfırla
        if activeItem.currentCount > 0 {
            activeItem.dailyCompletions += 1
            activeItem.currentCount = 0
        }
        
        UserDefaults.standard.set(today, forKey: key)
        persistService.saveDhikr(dhikrItems)
        WidgetCenter.shared.reloadAllTimelines()
        print("DhikrViewModel: 🔄 Günlük sıfırlama yapıldı.")
    }
    
    func languageDidChange(_ code: LanguageCode) {
        // Gerekli metin güncellemeleri
    }
}

