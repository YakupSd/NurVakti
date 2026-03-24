import Foundation
import CoreLocation

// MARK: - Calculation Method Parameters
struct CalculationParameters {
    let fajrAngle: Double      // Güneş açısı (derece) - Sabah
    let ishaAngle: Double      // Güneş açısı (derece) - Yatsı
    let methodName: String

    /// Türkiye Diyanet İşleri Başkanlığı
    static let diyanet = CalculationParameters(fajrAngle: 18.0, ishaAngle: 17.0, methodName: "Diyanet")
    /// Muslim World League
    static let mwl     = CalculationParameters(fajrAngle: 18.0, ishaAngle: 17.0, methodName: "MWL")
    /// Islamic Society of North America
    static let isna    = CalculationParameters(fajrAngle: 15.0, ishaAngle: 15.0, methodName: "ISNA")
    /// Egypt: General Authority of Survey
    static let egypt   = CalculationParameters(fajrAngle: 19.5, ishaAngle: 17.5, methodName: "Egypt")
    /// Umm al-Qura, Mekke
    static let ummAlQura = CalculationParameters(fajrAngle: 18.5, ishaAngle: 90.0 /* Gayat offset = 90 min */, methodName: "UmmAlQura")
}

// MARK: - Prayer Calculator
/// Astronomik formüllerle (Jean Meeus algoritması temel alınarak) namaz vakitlerini hesaplar.
/// Harici kütüphane gerektirmez.
final class PrayerCalculator {

    static let shared = PrayerCalculator()
    private init() {}

    // MARK: - Public API
    func calculate(for location: CLLocation,
                   date: Date = Date(),
                   method: String = "Diyanet",
                   madhab: Madhab = .hanafi) -> PrayerTime {

        let params = parameters(for: method)
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude

        // Timezone offset (saniye cinsinden → saat)
        let tzOffset = timeZoneOffset(for: location, date: date)

        let times = prayerTimes(date: date,
                                latitude: lat,
                                longitude: lng,
                                timezone: tzOffset,
                                params: params,
                                madhab: madhab)

        let now = Date()
        let hijri = hijriDate(from: date)

        return PrayerTime(
            id: UUID(),
            date: date,
            imsak:   times.imsak,
            fajr:    times.fajr,
            sunrise: times.sunrise,
            dhuhr:   times.dhuhr,
            asr:     times.asr,
            maghrib: times.maghrib,
            isha:    times.isha,
            cityName: "",           // Çağıran taraf doldurur
            hijriDate: hijri,
            calculationMethod: params.methodName
        )
    }

    // MARK: - Private Helpers

    private func parameters(for method: String) -> CalculationParameters {
        switch method.lowercased() {
        case "diyanet", "turkey": return .diyanet
        case "isna":              return .isna
        case "egypt":             return .egypt
        case "ummAlQura", "makkah": return .ummAlQura
        default:                  return .diyanet  // Türkiye varsayılan
        }
    }

    // MARK: - Core Astronomical Calculation
    private struct RawTimes {
        let imsak, fajr, sunrise, dhuhr, asr, maghrib, isha: Date
    }

    private func prayerTimes(date: Date,
                             latitude: Double,
                             longitude: Double,
                             timezone: Double,
                             params: CalculationParameters,
                             madhab: Madhab) -> RawTimes {

        let jd = julianDay(from: date)
        let sunCoords = sunCoordinates(jd: jd)
        let declination = sunCoords.declination
        let eqOfTime = sunCoords.equationOfTime // Dakika cinsinden

        // Astronomik Öğle (Transit)
        // Formula: 12 + Timezone - Longitude/15 - EqTime/60
        // Düzce (31.03E, +3): 12 + 3 - (31.03/15) - (EqT/60) ≈ 15 - 2.06 - EqT/60 ≈ 12.94 local hours.
        let baseDhuhr = 12.0 + timezone - (longitude / 15.0) - (eqOfTime / 60.0)

        func hourAngle(angle: Double) -> Double {
            let a = toRad(angle)
            let lat = toRad(latitude)
            let cosHA = (sin(a) - sin(lat) * sin(declination)) / (cos(lat) * cos(declination))
            guard cosHA >= -1.0 && cosHA <= 1.0 else { return Double.nan }
            return toDeg(acos(cosHA)) / 15.0
        }

        let sunriseHA = hourAngle(angle: -0.8333)
        let imsakHA = hourAngle(angle: -params.fajrAngle)
        let ishaHA = hourAngle(angle: -params.ishaAngle)
        let asrHA = asrHourAngle(madhab: madhab, declination: declination, latitude: latitude)

        let dhuhr = baseDhuhr
        let imsakParsed = baseDhuhr - imsakHA
        let imsak = imsakParsed - (10.0 / 60.0) // Diyanet temkin
        let sunrise = baseDhuhr - sunriseHA
        let asr = baseDhuhr + asrHA
        let maghrib = baseDhuhr + sunriseHA
        let isha = baseDhuhr + ishaHA

        func toDate(_ hours: Double) -> Date {
            guard !hours.isNaN && !hours.isInfinite else {
                return Calendar.current.startOfDay(for: date)
            }
            var h = hours.truncatingRemainder(dividingBy: 24.0)
            while h < 0 { h += 24.0 }
            while h >= 24 { h -= 24.0 }
            
            let totalSeconds = Int(round(h * 3600))
            let hour = totalSeconds / 3600
            let minute = (totalSeconds % 3600) / 60
            let second = totalSeconds % 60
            
            var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            components.hour = hour
            components.minute = minute
            components.second = second
            // ÖNEMLİ: baseDhuhr içinde zaten timezone ekli olduğu için 
            // components'ı UTC (offset 0) olarak belirlemeliyiz, yoksa sistem bir kez daha ekler.
            components.timeZone = TimeZone(secondsFromGMT: 0)
            return Calendar.current.date(from: components) ?? date
        }

        return RawTimes(
            imsak:   toDate(imsak),
            fajr:    toDate(imsakParsed),
            sunrise: toDate(sunrise),
            dhuhr:   toDate(dhuhr),
            asr:     toDate(asr),
            maghrib: toDate(maghrib),
            isha:    toDate(isha)
        )
    }

    private func asrHourAngle(madhab: Madhab, declination: Double, latitude: Double) -> Double {
        let shadowFactor: Double = madhab == .hanafi ? 2.0 : 1.0
        let lat = toRad(latitude)
        let angle = atan(1.0 / (shadowFactor + tan(abs(lat - declination))))
        let cosHA = (sin(angle) - sin(lat) * sin(declination)) / (cos(lat) * cos(declination))
        guard cosHA >= -1.0 && cosHA <= 1.0 else { return Double.nan }
        return toDeg(acos(cosHA)) / 15.0
    }

    private func julianDay(from date: Date) -> Double {
        let cal = Calendar(identifier: .gregorian)
        let year = cal.component(.year, from: date)
        let month = cal.component(.month, from: date)
        let day = cal.component(.day, from: date)
        
        var y = Double(year)
        var m = Double(month)
        if m <= 2 { y -= 1; m += 12 }
        let a = floor(y / 100.0)
        let b = 2 - a + floor(a / 4.0)
        return floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + Double(day) + b - 1524.5
    }

    private struct SolarCoords {
        let declination: Double
        let equationOfTime: Double
    }

    private func sunCoordinates(jd: Double) -> SolarCoords {
        let d = jd - 2451545.0
        let g = 357.529 + 0.98560028 * d
        let q = 280.459 + 0.98564736 * d
        let L = q + 1.915 * sin(toRad(g)) + 0.020 * sin(toRad(2 * g))
        let e = 23.439 - 0.00000036 * d
        
        let dd = asin(sin(toRad(e)) * sin(toRad(L)))  // radyan
        
        let RA = toDeg(atan2(cos(toRad(e)) * sin(toRad(L)), cos(toRad(L)))) / 15.0
        let EqT = (q / 15.0 - RA) * 4.0 // dakika
        
        return SolarCoords(declination: dd, equationOfTime: EqT)
    }

    private func timeZoneOffset(for location: CLLocation, date: Date) -> Double {
        let tz = TimeZone.current
        return Double(tz.secondsFromGMT(for: date)) / 3600.0
    }

    private func toRad(_ deg: Double) -> Double { deg * .pi / 180.0 }
    private func toDeg(_ rad: Double) -> Double { rad * 180.0 / .pi }

    func hijriDate(from date: Date) -> HijriDate {
        let cal = Calendar(identifier: .islamicUmmAlQura)
        let comps = cal.dateComponents([.day, .month, .year], from: date)
        return HijriDate(day: comps.day ?? 1, month: comps.month ?? 1, year: comps.year ?? 1446)
    }
}
