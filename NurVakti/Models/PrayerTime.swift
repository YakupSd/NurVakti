import Foundation

struct PrayerTime: Codable, Identifiable {
    let id: UUID
    let date: Date
    let imsak: Date
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date
    let cityName: String
    let hijriDate: HijriDate
    let calculationMethod: String
}

struct HijriDate: Codable {
    let day: Int
    let month: Int         // 1-12
    let year: Int
    
    // 5 dilde ay ismi döndüren func
    func monthName(for language: LanguageCode) -> String {
        let monthsAr = ["محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة", "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"]
        let monthsTr = ["Muharrem", "Safer", "Rebiülevvel", "Rebiülahir", "Cemaziyelevvel", "Cemaziyelahir", "Recep", "Şaban", "Ramazan", "Şevval", "Zilkade", "Zilhicce"]
        let monthsEn = ["Muharram", "Safar", "Rabi' al-awwal", "Rabi' al-thani", "Jumada al-ula", "Jumada al-akhira", "Rajab", "Sha'ban", "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"]
        let monthsDe = ["Muharram", "Safar", "Rabi' al-awwal", "Rabi' al-thani", "Dschumada l-ula", "Dschumada l-achira", "Radschab", "Schaban", "Ramadan", "Schawwal", "Dhu l-qa'da", "Dhu l-hiddscha"]
        let monthsPt = ["Muharram", "Safar", "Rabi al-Awwal", "Rabi al-Thani", "Jumada al-Ula", "Jumada al-Akhira", "Rajab", "Sha'ban", "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"]
        
        let index = max(0, min(month - 1, 11))
        switch language {
        case .tr: return monthsTr[index]
        case .ar: return monthsAr[index]
        case .en: return monthsEn[index]
        case .de: return monthsDe[index]
        case .pt: return monthsPt[index]
        }
    }
    
    // Formatlı string: "15 Ramazan 1446" / "١٥ رمضان ١٤٤٦"
    func formatted(for language: LanguageCode) -> String {
        let mName = monthName(for: language)
        if language == .ar {
            let dayAr = formatArabicNumber(day)
            let yearAr = formatArabicNumber(year)
            return "\(dayAr) \(mName) \(yearAr)"
        } else {
            return "\(day) \(mName) \(year)"
        }
    }
    
    private func formatArabicNumber(_ number: Int) -> String {
        let arabicNumbers = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
        return String(number).compactMap { Int(String($0)) }.map { arabicNumbers[$0] }.joined()
    }
}

extension PrayerTime {
    static func load() -> PrayerTime? {
        PersistenceService.shared.load(key: "last_prayer_time", as: PrayerTime.self)
    }
    
    func save() {
        PersistenceService.shared.save(self, key: "last_prayer_time")
    }
}
