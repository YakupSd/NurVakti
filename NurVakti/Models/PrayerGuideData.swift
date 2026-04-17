import Foundation

struct PrayerGuideData {
    static let surahNames: [String] = [
        "Fâtiha", "Bakara", "Âl-i İmrân", "Nisâ", "Mâide", "En'âm", "A'râf", "Enfâl", "Tevbe", "Yûnus",
        "Hûd", "Yûsuf", "Ra'd", "İbrâhîm", "Hicr", "Nahl", "İsrâ", "Kehf", "Meryem", "Tâhâ",
        "Enbiyâ", "Hac", "Mü'minûn", "Nûr", "Furkân", "Şuarâ", "Neml", "Kasas", "Ankebût", "Rûm",
        "Lokmân", "Secde", "Ahzâb", "Sebe'", "Fâtır", "Yâsîn", "Sâffât", "Sâd", "Zümer", "Mü'min",
        "Fussılet", "Şûrâ", "Zuhruf", "Duhân", "Câsiye", "Ahkâf", "Muhammed", "Fetih", "Hucurât", "Kâf",
        "Zâriyât", "Tûr", "Necm", "Kamer", "Rahmân", "Vâkıa", "Hadîd", "Mücâdele", "Haşr", "Mümtahine",
        "Saf", "Cuma", "Münâfikûn", "Tegâbun", "Talâk", "Tahrîm", "Mülk", "Kalem", "Hâkka", "Meâric",
        "Nûh", "Cin", "Müzzemmil", "Müddessir", "Kıyâme", "İnsân", "Mürselât", "Nebe'", "Nâziât", "Abese",
        "Tekvîr", "İnfitâr", "Mutaffifîn", "İnşikâk", "Burûc", "Târık", "A'lâ", "Gâşiye", "Fecr", "Beled",
        "Şems", "Leyl", "Duhâ", "İnşirâh", "Tîn", "Alak", "Kadr", "Beyyine", "Zilzâl", "Âdiyât",
        "Kâria", "Tekâsür", "Asr", "Hümeze", "Fîl", "Kureyş", "Mâûn", "Kevser", "Kâfirûn", "Nasr",
        "Tebbet", "İhlâs", "Felak", "Nâs"
    ]
    
    // MARK: - Namaz Adımları (Steps)
    static func getPrayerSteps() -> [PrayerStep] {
        return [
            PrayerStep(
                id: "step_niyet",
                imageName: "Niyet1",
                titles: ["tr": "Niyet", "en": "Intention"],
                descriptions: [
                    "tr": "Kılınacak namaza niyet etmek (Örn: Niyet ettim Allah rızası için bugünkü öğle namazının sünnetini kılmaya).",
                    "en": "Make the intention for the specific prayer you are about to perform."
                ]
            ),
            PrayerStep(
                id: "step_tekbir",
                imageName: "Tekbir",
                titles: ["tr": "İftitah Tekbiri", "en": "Takbir al-Ihram"],
                descriptions: [
                    "tr": "'Allâhu Ekber' diyerek namaza başlamak.",
                    "en": "Raising hands and saying 'Allahu Akbar' to begin the prayer."
                ]
            ),
            PrayerStep(
                id: "step_kiyam",
                imageName: "Kiyam",
                titles: ["tr": "Kıyam", "en": "Qiyam"],
                descriptions: [
                    "tr": "Ayakta durmak ve Kur'an okumak (Fatiha ve ek sure).",
                    "en": "Standing straight and reciting the Qur'an (Fatiha and another surah)."
                ]
            ),
            PrayerStep(
                id: "step_ruku",
                imageName: "Ruku",
                titles: ["tr": "Rükû", "en": "Ruku"],
                descriptions: [
                    "tr": "Elleri dizlere koyarak eğilmek ve 'Sübhâne Rabbiyel Azîm' demek.",
                    "en": "Bowing down with hands on knees and saying 'Subhana Rabbiyal Azeem'."
                ]
            ),
            PrayerStep(
                id: "step_secde",
                imageName: "Secde",
                titles: ["tr": "Secde", "en": "Sujud"],
                descriptions: [
                    "tr": "Alın, burun, eller, dizler ve ayaklar yere değecek şekilde yere kapanmak ve 'Sübhâne Rabbiyel Â'lâ' demek.",
                    "en": "Prostrating on the ground and saying 'Subhana Rabbiyal A'la'."
                ]
            ),
            PrayerStep(
                id: "step_oturus",
                imageName: "KadeiAhire",
                titles: ["tr": "Ka'de-i Ahîre", "en": "Final Sitting"],
                descriptions: [
                    "tr": "Son rekatta oturup Ettehiyyatü, Salli-Barik ve Rabbena dualarını okumak.",
                    "en": "Sitting in the final unit to recite Tashahhud and Salawat."
                ]
            ),
            PrayerStep(
                id: "step_selam",
                imageName: "Selam",
                titles: ["tr": "Selam", "en": "Taslim"],
                descriptions: [
                    "tr": "'Esselâmu aleykum ve rahmetullâh' diyerek önce sağa, sonra sola selam vermek.",
                    "en": "Turning the head to the right then left, saying 'Assalamu Alaikum wa Rahmatullah'."
                ]
            )
        ]
    }
    
    static func getNamazDuas() -> [PrayerDua] {
        return [
            PrayerDua(
                id: "namaz_subhaneke",
                audioFileName: "SubhanekeDuasi",
                arabicText: "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلَا إِلَهَ غَيْرُكَ",
                transliteration: "Sübhânekellâhumme ve bi hamdik ve tebârekesmük ve teâlâ ceddük ve lâ ilâhe ğayruk.",
                titles: ["tr": "Sübhaneke", "en": "Subhanaka"],
                meanings: [
                    "tr": "Allah'ım! Sen eksik sıfatlardan uzaksın. Seni daima böyle tenzih eder ve överim. Senin adın mübarektir. Varlığın her şeyden üstündür. Senden başka ilah yoktur.",
                    "en": "Glory be to You, O Allah, and all praise is due to You. Blessed is Your name and high is Your majesty. There is no deity besides You."
                ],
                category: .prayer
            ),
            PrayerDua(
                id: "namaz_ettehiyyatu",
                audioFileName: "Ettehiyyatü_Duası",
                arabicText: "التَّحِيَّاتُ لِلّٰهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللّٰهِ وَبَرَكَاتُهُ السَّلَامُ عَلَيْنَا وَعَلَىٰ عِبَادِ اللّٰهِ الصَّالِحِينَ أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللّٰهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
                transliteration: "Et-tehiyyâtu lillâhi vessalevâtu vettayyibât. Es-selâmu aleyke eyyuhen-nebiyyu ve rahmetullâhi ve berekâtuh. Es-selâmu aleynâ ve alâ ibâdillâhis-salihîn. Eşhedu en lâ ilâhe illallâh ve eşhedu enne Muhammeden abduhu ve rasûluh.",
                titles: ["tr": "Ettehiyyatü", "en": "At-Tayyibat"],
                meanings: [
                    "tr": "Dil, beden ve mal ile yapılan bütün ibadetler Allah'adır. Ey Peygamber! Selam, Allah'ın rahmeti ve bereketleri senin üzerine olsun. Selam bizim üzerimize ve Allah'ın salih kulları üzerine olsun. Şahitlik ederim ki Allah'tan başka ilah yoktur. Yine şahitlik ederim ki Muhammed, O'nun kulu ve peygamberidir.",
                    "en": "All compliments, prayers and pure words are due to Allah. Peace be upon you, O Prophet, and the mercy of Allah and His blessings..."
                ],
                category: .prayer
            ),
            PrayerDua(
                id: "namaz_salli",
                audioFileName: "Salli_Duası",
                arabicText: "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
                transliteration: "Allahümme salli alâ Muhammedin ve alâ âli Muhammed kemâ salleyte alâ İbrâhîme ve alâ âli İbrâhîm, inneke hamîdun mecîd.",
                titles: ["tr": "Allahümme Salli", "en": "Allahumma Salli"],
                meanings: [
                    "tr": "Allah'ım! Hz. İbrahim'e ve ailesine salat ettiğin gibi Hz. Muhammed'e ve ailesine de salat eyle. Şüphesiz Sen, övülmeye layıksın, şanı yücesin.",
                    "en": "O Allah, confer Your blessings upon Muhammad..."
                ],
                category: .prayer
            ),
            PrayerDua(
                id: "namaz_barik",
                audioFileName: "Barik_Duası",
                arabicText: "اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
                transliteration: "Allahümme barik alâ Muhammedin ve alâ âli Muhammed kemâ bârakte alâ İbrâhîme ve alâ âli İbrâhîm, inneke hamîdun mecîd.",
                titles: ["tr": "Allahümme Barik", "en": "Allahumma Barik"],
                meanings: [
                    "tr": "Allah'ım! Hz. İbrahim'e ve ailesine bereket ihsan ettiğin gibi Hz. Muhammed'e ve ailesine de bereket ihsan eyle. Şüphesiz Sen, övülmeye layıksın, şanı yücesin.",
                    "en": "O Allah, bless Muhammad..."
                ],
                category: .prayer
            ),
            PrayerDua(
                id: "namaz_rabbena",
                arabicText: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ. رَبَّنَا اغْفِرْ لِي وَلِوَALİDEYYE VE LİL-MÜ'MİNİNE YEVMEYA KŪMÜL HISAB",
                transliteration: "Rabbenâ âtinâ... Rabbenâğfirlî...",
                titles: ["tr": "Rabbena Duaları", "en": "Rabbana Duas"],
                meanings: [
                    "tr": "Rabbimiz! Bize dünyada da iyilik, ahirette de iyilik ver ve bizi cehennem azabından koru. Rabbimiz! Hesabın görüleceği gün beni, annemi, babamı ve tüm müminleri bağışla.",
                    "en": "Our Lord, give us in this world [that which is] good..."
                ],
                category: .rabbena
            ),
            PrayerDua(
                id: "namaz_kunut",
                arabicText: "اللَّهُمَّ إِنَّا نَسْتَعِينُكَ وَنَسْتَغْفِرُكَ وَنَسْتَهْدِيكَ وَنÜ'MİNÜ BİKE VE NETEVEKKELÜ ALEYKE VE NÜSNİ ALEYKEL-HAYRA KÜLLEHÜ NEŞKÜRÜKE VE LÂ NEKFÜRÜKE VE NAHLA'Ü VE NETRÜKÜ MEN YEFCURUKE. ALLAHÜMME İYYAKE NA'BÜDÜ VE LEKE NÜSALLİ VE NESCÜDÜ VE İLEYKE NES'Â VE NAHFİDÜ NERCŪ RAHMETEKE VE NAHŞÂ AZÂBEKE İNNE AZÂBEKE BİL-KÜFFÂRİ MÜLHIK",
                transliteration: "Allahümme innâ nesteînuke... Allahümme iyyâke na'budu...",
                titles: ["tr": "Kunut Duaları (1-2)", "en": "Qunut Duas"],
                meanings: [
                    "tr": "Allah'ım! Senden yardım dileriz, Senden mağfiret dileriz... Allah'ım! Biz yalnız Sana kulluk ederiz, Senin rızan için namaz kılar ve secde ederiz...",
                    "en": "O Allah, we seek Your help..."
                ],
                category: .prayer
            ),
            PrayerDua(
                id: "namaz_amentu",
                arabicText: "آمَنْتُ بِاللّٰهِ وَمَلَائِكETİHİ VE KÜTUBİHİ VE RUSÜLİHİ VEL-YEVMİL-ÂHİRİ VE BİLKADERİ HAYRİHİ VE ŞERRİHİ MİNELLAHİ TEÂLÂ VEL-BA'SÜ BA'DEL-MEVTİ HAKK... EŞHEDÜ EN LÂ İLÂHE İLLALLÂH VE EŞHEDÜ ENNE MUHAMMEDEN ABDÜHŪ VE RASŪLÜH",
                transliteration: "Âmentü billâhi ve melâiketihî ve kütubihî ve rusülihî...",
                titles: ["tr": "Âmentü", "en": "Amantu"],
                meanings: [
                    "tr": "Allah'a, meleklerine, kitaplarına, peygamberlerine, ahiret gününe, hayır ve şerrin Allah'tan geldiğine (kadere) iman ettim. Öldükten sonra dirilmek haktır. Şahitlik ederim ki Allah'tan başka ilah yoktur ve yine şahitlik ederim ki Muhammed O'nun kulu ve elçisidir.",
                    "en": "I believe in Allah, His angels, His books..."
                ],
                category: .prayer
            )
        ]
    }
    
    // MARK: - Namaz Sureleri (Surahs)
    static func getPrayerSurahs() -> [PrayerDua] {
        return [
            PrayerDua(
                id: "surah_ihlas",
                audioFileName: "112",
                arabicText: "قُلْ هُوَ اللّٰهُ أَحَدٌ (1) اَللّٰهُ الصَّمَدُ (2) لَمْ يَلِدْ وَلَمْ يُولَدْ (3) وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ (4)",
                transliteration: "Kul huvallâhu ehad. Allâhus-samed. Lem yelid ve lem yûled. Ve lem yekun lehu kufuven ehad.",
                titles: ["tr": "İhlâs Suresi", "en": "Surah Al-Ikhlas"],
                meanings: [
                    "tr": "De ki: O Allah tektir. Allah sameddir. Doğurmamış ve doğmamıştır. O'nun hiçbir dengi yoktur.", 
                    "en": "Say, \"He is Allah, [who is] One...\""
                ],
                category: .quranAyah
            ),
            PrayerDua(
                id: "surah_felak",
                audioFileName: "113",
                arabicText: "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ (1) مِنْ شَرِّ مَا خَلَقَ (2) وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ (3) وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ (4) وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ (5)",
                transliteration: "Kul eûzu birabbil felak. Min şerri mâ halak. Ve min şerri ğâsikın izâ vekab. Ve min şerrin-neffâsâti fil ukad. Ve min şerri hâsidin izâ hased.",
                titles: ["tr": "Felak Suresi", "en": "Surah Al-Falaq"],
                meanings: [
                    "tr": "De ki: Yarattığı şeylerin kötülüğünden, karanlığı çöktüğü zaman gecenin kötülüğünden, düğümlere üfleyenlerin kötülüğünden, haset ettiği zaman hasetçinin kötülüğünden, sabah aydınlığının Rabbine sığınırım.", 
                    "en": "Say, \"I seek refuge in the Lord of daybreak...\""
                ],
                category: .quranAyah
            ),
            PrayerDua(
                id: "surah_nas",
                audioFileName: "114",
                arabicText: "قُلْ أَعُوذُ بِرَبِّ النَّاسِ (1) مَلِكِ النَّاسِ (2) إِلٰهِ النَّاسِ (3) مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ (4) اَلَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ (5) مِنَ الْجِنَّةِ وَالنَّاسِ (6)",
                transliteration: "Kul eûzu birabbin-nâs. Melikin-nâs. İlâhin-nâs. Min scherril vesvâsil hannâs. Ellezî yüvesvisü fî sudûrin-nâs. Minel cinneti ven-nâs.",
                titles: ["tr": "Nâs Suresi", "en": "Surah An-Nas"],
                meanings: [
                    "tr": "De ki: İnsanların Rabbine, insanların hükümdarına, insanların ilâhına; o sinsi vesvesecinin şerrinden Allah’a sığınırım. O ki insanların göğüslerine vesvese verir, o hem cinlerden hem de insanlardandır.", 
                    "en": "Say, \"I seek refuge in the Lord of mankind...\""
                ],
                category: .quranAyah
            )
        ]
    }
    
    // MARK: - Namaz Sonrası Dualar (Post-Prayer)
    static func getPostPrayerDuas() -> [PrayerDua] {
        return [
            PrayerDua(
                id: "post_aytel_kursi",
                audioFileName: "002255",
                arabicText: "اللّٰهُ لَا إِلٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهُمَا وَهو الْعَلِيُّ الْعَظِيمُ",
                transliteration: "Allâhu lâ ilâhe illâ huvel hayyul kayyûm...",
                titles: ["tr": "Ayetel Kürsi", "en": "Ayat al-Kursi"],
                meanings: [
                    "tr": "Allah, O'ndan başka ilah yoktur. Diridir, kaimdir. O'nu ne bir uyuklama ne de bir uyku tutar. Göklerde ve yerde ne varsa hepsi O'nundur...",
                    "en": "Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence..."
                ],
                category: .quranAyah
            ),
            PrayerDua(
                id: "post_entes_selam",
                audioFileName: "entesselam",
                arabicText: "اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ",
                transliteration: "Allahümme entes-selâmü ve minkes-selâmü tebârekte yâ zel-celâli vel-ikrâm.",
                titles: ["tr": "Allahümme Entesselam", "en": "Allahumma Antas-Salam"],
                meanings: [
                    "tr": "Allah'um! Sen selam ve esenlik verensin. Selam ve esenlik Sendendir. Ey celal ve ikram sahibi olan Rabbimiz! Sen hayır ve bereketi çok olansın.",
                    "en": "O Allah, You are Peace..."
                ],
                category: .prayer
            )
        ]
    }
    
    // MARK: - Mevsimsel/Aylık Dualar (Seasonal)
    enum HijriMonth: Int {
        case muharram = 1, safar, rabiAlAwwal, rabiAlThani, jumadaAlAwwal, jumadaAlThani, rajab, shaban, ramadan, shawwal, dhuAlQidah, dhuAlHijjah
        
        var name: [String: String] {
            switch self {
            case .muharram: return ["tr": "Muharrem", "en": "Muharram"]
            case .safar: return ["tr": "Safer", "en": "Safar"]
            case .rabiAlAwwal: return ["tr": "Rebiülevvel", "en": "Rabi' al-Awwal"]
            case .rabiAlThani: return ["tr": "Rebiülahir", "en": "Rabi' al-Thani"]
            case .jumadaAlAwwal: return ["tr": "Cemaziyelevvel", "en": "Jumada al-Awwal"]
            case .jumadaAlThani: return ["tr": "Cemaziyelahir", "en": "Jumada al-Thani"]
            case .rajab: return ["tr": "Recep (Üç Aylar)", "en": "Rajab"]
            case .shaban: return ["tr": "Şaban (Üç Aylar)", "en": "Sha'ban"]
            case .ramadan: return ["tr": "Ramazan", "en": "Ramadan"]
            case .shawwal: return ["tr": "Şevval", "en": "Shawwal"]
            case .dhuAlQidah: return ["tr": "Zilkade", "en": "Dhu al-Qi'dah"]
            case .dhuAlHijjah: return ["tr": "Zilhicce", "en": "Dhu al-Hijjah"]
            }
        }
    }
    
    static func getCurrentHijriMonth() -> HijriMonth {
        let islamicCalendar = Calendar(identifier: .islamicUmmAlQura)
        let month = islamicCalendar.component(.month, from: Date())
        return HijriMonth(rawValue: month) ?? .ramadan
    }
    
    static func getSeasonalPrayers() -> [PrayerDua] {
        let month = getCurrentHijriMonth()
        var specialDuas: [PrayerDua] = []
        
        switch month {
        case .rajab, .shaban:
            specialDuas.append(contentsOf: [
                PrayerDua(
                    id: "seasonal_uc_aylar",
                    arabicText: "اَللّٰهُمَّ بَارِكْ لَنَا فيِ رَجَبَ وَ شَعْبَانَ وَ بَلِّغْنَا رَمَضَانَ",
                    transliteration: "Allâhumme bârik lenâ fî recebe ve şa'bân ve belliğnâ ramadân.",
                    titles: ["tr": "Üç Aylar Duası", "en": "Three Months Dua"],
                    meanings: [
                        "tr": "Allah'ım! Recep ve Şaban aylarını hakkımızda mübarek eyle, bizi Ramazan ayına ulaştır.",
                        "en": "O Allah, bless us in Rajab and Sha'ban..."
                    ],
                    category: .morningEvening
                )
            ])
        case .ramadan:
            specialDuas.append(contentsOf: [
                PrayerDua(
                    id: "seasonal_iftar",
                    arabicText: "اللَّهُمَّ لَكَ صُمْتُ وَبِكَ آمَنْتُ وَعَلَيْكَ تَوَكَّلْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ",
                    transliteration: "Allahümme leke sumtü ve bike âmentü ve aleyke tevekkeltü ve alâ rızkıke eftartü.",
                    titles: ["tr": "İftar Duası", "en": "Iftar Dua"],
                    meanings: [
                        "tr": "Allah'ım! Senin rızan için oruç tuttum, Sana inandım, Sana güvendim ve Senin rızkınla orucumu açtım.",
                        "en": "O Allah, I fasted for You..."
                    ],
                    category: .daily
                ),
                PrayerDua(
                    id: "seasonal_teravih_niyet",
                    audioFileName: nil,
                    arabicText: "نويت أن أصلي صلاة التراويح سنتة لله تعالى",
                    transliteration: "Niyet ettim Allah rızası için vaktin sünneti olan teravih namazını kılmaya.",
                    titles: ["tr": "Teravih Niyeti", "en": "Tarawih Intention"],
                    meanings: [
                        "tr": "Niyet ettim Allah rızası için teravih namazını kılmaya, uydum imama.",
                        "en": "I intend to perform Tarawih for Allah..."
                    ]
                )
            ])
        case .shawwal, .dhuAlHijjah:
            specialDuas.append(contentsOf: [
                PrayerDua(
                    id: "seasonal_tesrik_tekbiri",
                    arabicText: "اَللّٰهُ اَكْبَرُ اَللّٰهُ اَكْبَرُ لَا اِلٰهَ اِلَّا اللّٰهُ وَاللّٰهُ اَكْبَرُ اَللّٰهُ اَكْبَرُ وَلِلّٰهِ الْحَمْدُ",
                    transliteration: "Allâhu ekber Allâhu ekber, lâ ilâhe illellâhu vallâhu ekber. Allâhu ekber ve lillâhil-hamd.",
                    titles: ["tr": "Teşrik Tekbiri", "en": "Takbir al-Tashreeq"],
                    meanings: [
                        "tr": "Allah en büyüktür, Allah en büyüktür. Allah'tan başka ilah yoktur. Allah en büyüktür, Allah en büyüktür. Hamd Allah'a mahsustur.",
                        "en": "Allah is the greatest..."
                    ],
                    category: .prayer
                )
            ])
        default:
            specialDuas.append(contentsOf: [
                PrayerDua(
                    id: "seasonal_daily_dhikr",
                    arabicText: "لَا اِلٰهَ اِلَّا اللّٰهُ وَحْدَهُ لَا شَرٖيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهو عَلَىٰ كُلِّ شَيْءٍ قَدٖيرٌ",
                    transliteration: "Lâ ilâhe illellâhü vahdehû lâ şerîke leh...",
                    titles: ["tr": "Günlük Zikir", "en": "Daily Dhikr"],
                    meanings: [
                        "tr": "Allah'tan başka ilah yoktur, O tektir, ortağı yoktur. Mülk O'nundur, hamd O'nadır. O her şeye kadirdir.",
                        "en": "There is no deity but Allah..."
                    ],
                    category: .daily
                )
            ])
        }
        
        return specialDuas
    }
    
    static func getEidPrayerSteps() -> [PrayerStep] {
        return [
            PrayerStep(
                id: "step_eid_niyet",
                imageName: "Niyet1",
                titles: ["tr": "Niyet ve Tekbir", "en": "Intention & Takbir"],
                descriptions: ["tr": "Niyet ettim Allah rızası için Bayram namazını kılmaya, uydum hazır olan imama.", "en": "Make intention for Eid prayer behind the Imam."]
            ),
            PrayerStep(
                id: "step_eid_takbirs_1",
                imageName: "Tekbir",
                titles: ["tr": "Ekstra Tekbirler (1. Rekat)", "en": "Extra Takbirs"],
                descriptions: ["tr": "Sübhaneke'den sonra imamla birlikte eller kulaklara kaldırılarak 3 kez tekbir alınır. İlk ikisinde eller yana salınır, üçüncüsünde bağlanır.", "en": "After Subhanaka, raise hands 3 times with the Imam..."]
            ),
            PrayerStep(
                id: "step_eid_takbirs_2",
                imageName: "Tekbir",
                titles: ["tr": "Ekstra Tekbirler (2. Rekat)", "en": "Extra Takbirs (2nd Raka)"],
                descriptions: ["tr": "Rükuya gitmeden önce yine 3 kez eller kaldırılarak tekbir alınır ve eller yana salınır. Dördüncü tekbirle rükuya gidilir.", "en": "Before Ruku, perform 3 extra takbirs..."]
            )
        ]
    }
    
    // MARK: - Detaylı Namaz Sonrası Tesbihat
    static func getDetailedTesbihat() -> [PrayerDua] {
        return [
            PrayerDua(
                id: "detailed_salat_munciye",
                audioFileName: "salati_munciye",
                arabicText: "اَللّٰهُمَّ صَلِّ عَلٰى سَيِّدِنَا مُـحَمَّدٍ وَعَلٰٓى اٰلِ سَيِّدِنَا مُـحَمَّدٍ",
                transliteration: "Allâhümme Salli alâ seyyidinâ Muhammedin ve alâ âli seyyidinâ Muhammed",
                titles: ["tr": "Salât-ı Münciye / Salavat", "en": "Salawat"],
                meanings: [
                    "tr": "Allahım! Efendimiz Hz. Muhammed’in şeref ve mertebesini yücelt. O'na ve ailesine rahmet eyle.",
                    "en": "O Allah, confer Your blessings upon our leader Muhammad..."
                ],
                category: .daily
            ),
            PrayerDua(
                id: "detailed_tesbih_dua",
                audioFileName: "Namaz_tesbihatı",
                arabicText: "سُبْحَانَ اللّٰهِ وَالْحَمْدُ لِلّٰهِ وَلَا اِلٰهَ اِلَّا اللّٰهُ وَاللّٰهُ اَكْبَرُ وَلَا حَوْلَ وَلَا قُوَّةَ اِلَّا بِاللّٰهِ الْعَلِيِّ الْعَظٖيمِ",
                transliteration: "Sübhânellâhi ve’l-hamdü lillâhi ve lâ ilâhe illellâhü ve’l-lâhü ekber ve lâ havle ve lâ kuvvete illâ billâhi’l-aliyyi’l-azîm",
                titles: ["tr": "Tesbih Duası", "en": "Tasbih Dua"],
                meanings: [
                    "tr": "Şanı yüce Allah’ı tesbih ve tenzih ederim. O bütün noksanlıklardan uzaktır. Hamd Allah’a mahsustur. Allah’tan başka hiçbir ilah yoktur. Allah en büyüktür. Emirlerine uymak, yasaklardan sakınmak için gereken güç ve kuvvet ancak Allah’tandır.",
                    "en": "Glory be to Allah, and praise be to Allah..."
                ],
                category: .daily
            ),
            PrayerDua(
                id: "detailed_aytel_kursi",
                audioFileName: "002255",
                arabicText: "اللّٰهُ لَا إِلٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهما وَهو الْعَلِيُّ الْعَظِيمُ",
                transliteration: "Allâhu lâ ilâhe illâ huvel hayyul kayyûm...",
                titles: ["tr": "Ayetel Kürsi", "en": "Ayat al-Kursi"],
                meanings: [
                    "tr": "Allah, O'ndan başka ilah yoktur. Diridir, kaimdir. O'nu ne bir uyuklama ne de bir uyku tutar. Göklerde ve yerde ne varsa hepsi O'nundur...",
                    "en": "Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence..."
                ],
                category: .quranAyah
            ),
            PrayerDua(
                id: "detailed_subhanallah",
                audioFileName: "subhanallah",
                arabicText: "سُبْحَانَ اللّٰهِ",
                transliteration: "Sübhânellâh",
                titles: ["tr": "33x Sübhânellâh", "en": "33x Subhanallah"],
                meanings: ["tr": "Allah’ı noksan sıfatlardan tenzih ederim.", "en": "Glory be to Allah."],
                category: .daily
            ),
            PrayerDua(
                id: "detailed_elhamdulillah",
                audioFileName: "elhamdulillah",
                arabicText: "اَلْحَمْدُ لِلّٰهِ",
                transliteration: "Elhamdü lillâh",
                titles: ["tr": "33x Elhamdü lillâh", "en": "33x Alhamdulillah"],
                meanings: ["tr": "Her türlü övgü Allah’a mahsustur.", "en": "Praise be to Allah."],
                category: .daily
            ),
            PrayerDua(
                id: "detailed_allahu_ekber",
                audioFileName: "allahu_ekber",
                arabicText: "اَللّٰهُ اَكْبَرُ",
                transliteration: "Allâhu Ekber",
                titles: ["tr": "33x Allâhu Ekber", "en": "33x Allahu Akbar"],
                meanings: ["tr": "Allah en büyüktür.", "en": "Allah is the Greatest."],
                category: .daily
            )
        ]
    }
    
    // Aggregated list for DuaLibrary
    static var allDuas: [PrayerDua] {
        getNamazDuas() + getPrayerSurahs() + getPostPrayerDuas() + getSeasonalPrayers() + getDetailedTesbihat()
    }
}
