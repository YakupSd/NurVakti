import Foundation

// MARK: - İslami Özel Günler
// Foundation'ın Calendar(identifier: .islamicCivil) ile hesaplanır.
// Her gün için Hicri ay + gün çifti sabit; yıl hesaplaması runtime'da yapılır.

struct IslamicEvent: Identifiable {
    let id: UUID = UUID()
    let key: IslamicEventKey
    let hijriMonth: Int   // 1-12
    let hijriDay: Int
    let durationDays: Int // 1 = tek gece/gün, 30 = tüm Ramazan

    /// Bu yılki Gregorian tarih (tahmini — Hicri takvim astronomik hesap gerektirir)
    func gregorianDate(for hijriYear: Int) -> Date? {
        var islamicCal = Calendar(identifier: .islamicCivil)
        islamicCal.timeZone = TimeZone.current
        var components = DateComponents(calendar: islamicCal)
        components.year  = hijriYear
        components.month = hijriMonth
        components.day   = hijriDay
        components.hour  = 0
        components.minute = 0
        return islamicCal.date(from: components)
    }
}

enum IslamicEventKey: String, CaseIterable {
    case regaipKandili     // Recep 1. perşembe
    case miracKandili      // Recep 27
    case beratKandili      // Şaban 15
    case ramadanStart      // Ramazan 1
    case laylatalQadr      // Ramazan 27 (Kadir Gecesi)
    case eidAlFitr         // Şevval 1
    case arafaDay          // Zilhicce 9
    case eidAlAdha         // Zilhicce 10
    case mevlidNebevi      // Rebiülevvel 12

    func name(for language: LanguageCode) -> String {
        switch (self, language) {
        case (.regaipKandili, .tr):  return "Regaip Kandili"
        case (.regaipKandili, .en):  return "Raghaib Night"
        case (.regaipKandili, .ar):  return "ليلة الرغائب"
        case (.regaipKandili, .de):  return "Regaib-Nacht"
        case (.regaipKandili, .pt):  return "Noite de Raghaib"

        case (.miracKandili, .tr):   return "Miraç Kandili"
        case (.miracKandili, .en):   return "Isra & Mi'raj"
        case (.miracKandili, .ar):   return "الإسراء والمعراج"
        case (.miracKandili, .de):   return "Isra und Miradsch"
        case (.miracKandili, .pt):   return "Isra e Miraj"

        case (.beratKandili, .tr):   return "Berat Kandili"
        case (.beratKandili, .en):   return "Laylat al-Bara'ah"
        case (.beratKandili, .ar):   return "ليلة البراءة"
        case (.beratKandili, .de):   return "Laylat al-Baraat"
        case (.beratKandili, .pt):   return "Noite da Absolvição"

        case (.ramadanStart, .tr):   return "Ramazan Başlangıcı"
        case (.ramadanStart, .en):   return "Start of Ramadan"
        case (.ramadanStart, .ar):   return "بداية رمضان"
        case (.ramadanStart, .de):   return "Beginn des Ramadan"
        case (.ramadanStart, .pt):   return "Início do Ramadã"

        case (.laylatalQadr, .tr):   return "Kadir Gecesi"
        case (.laylatalQadr, .en):   return "Laylat al-Qadr"
        case (.laylatalQadr, .ar):   return "ليلة القدر"
        case (.laylatalQadr, .de):   return "Laylat al-Qadr"
        case (.laylatalQadr, .pt):   return "Laylat al-Qadr"

        case (.eidAlFitr, .tr):      return "Ramazan Bayramı"
        case (.eidAlFitr, .en):      return "Eid al-Fitr"
        case (.eidAlFitr, .ar):      return "عيد الفطر"
        case (.eidAlFitr, .de):      return "Eid al-Fitr"
        case (.eidAlFitr, .pt):      return "Eid al-Fitr"

        case (.arafaDay, .tr):       return "Arefe Günü"
        case (.arafaDay, .en):       return "Day of Arafah"
        case (.arafaDay, .ar):       return "يوم عرفة"
        case (.arafaDay, .de):       return "Tag von Arafah"
        case (.arafaDay, .pt):       return "Dia de Arafá"

        case (.eidAlAdha, .tr):      return "Kurban Bayramı"
        case (.eidAlAdha, .en):      return "Eid al-Adha"
        case (.eidAlAdha, .ar):      return "عيد الأضحى"
        case (.eidAlAdha, .de):      return "Eid al-Adha"
        case (.eidAlAdha, .pt):      return "Eid al-Adha"

        case (.mevlidNebevi, .tr):   return "Mevlid Kandili"
        case (.mevlidNebevi, .en):   return "Prophet's Birthday"
        case (.mevlidNebevi, .ar):   return "المولد النبوي"
        case (.mevlidNebevi, .de):   return "Mawlid an-Nabi"
        case (.mevlidNebevi, .pt):   return "Mawlid an-Nabi"

        default: return self.rawValue
        }
    }

    var emoji: String {
        switch self {
        case .regaipKandili:  return "🌙"
        case .miracKandili:   return "✨"
        case .beratKandili:   return "📜"
        case .ramadanStart:   return "🌙"
        case .laylatalQadr:   return "⭐"
        case .eidAlFitr:      return "🎉"
        case .arafaDay:       return "🤲"
        case .eidAlAdha:      return "🌿"
        case .mevlidNebevi:   return "💚"
        }
    }

    var isSpecialNight: Bool {
        switch self {
        case .regaipKandili, .miracKandili, .beratKandili, .laylatalQadr: return true
        default: return false
        }
    }
}
