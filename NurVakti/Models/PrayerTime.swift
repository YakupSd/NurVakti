import Foundation

public struct PrayerTime: Codable, Identifiable {
    public let id: UUID
    public let date: Date
    public let imsak: Date
    public let fajr: Date
    public let sunrise: Date
    public let dhuhr: Date
    public let asr: Date
    public let maghrib: Date
    public let isha: Date
    public let cityName: String
    public let hijriDate: HijriDate
    public let calculationMethod: String
    
    public init(id: UUID = UUID(), date: Date, imsak: Date, fajr: Date, sunrise: Date, dhuhr: Date, asr: Date, maghrib: Date, isha: Date, cityName: String, hijriDate: HijriDate, calculationMethod: String) {
        self.id = id
        self.date = date
        self.imsak = imsak
        self.fajr = fajr
        self.sunrise = sunrise
        self.dhuhr = dhuhr
        self.asr = asr
        self.maghrib = maghrib
        self.isha = isha
        self.cityName = cityName
        self.hijriDate = hijriDate
        self.calculationMethod = calculationMethod
    }
}

public struct HijriDate: Codable {
    public let day: Int
    public let month: Int         // 1-12
    public let year: Int
    
    public init(day: Int, month: Int, year: Int) {
        self.day = day
        self.month = month
        self.year = year
    }
    
    // 5 dilde ay ismi döndüren func
    public func monthName(for language: LanguageCode) -> String {
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
    
    public func formatted(for language: LanguageCode) -> String {
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
