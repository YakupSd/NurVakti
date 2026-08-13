import Foundation

/// 30 günlük namaz vakitleri cache'inin metadata bilgisi.
/// Cache'in hangi konum, metod ve tarih aralığı için oluşturulduğunu tutar.
/// Bu sayede gereksiz API çağrıları önlenir.
struct PrayerCacheMetadata: Codable {
    /// Cache'in oluşturulma zamanı
    let createdAt: Date
    /// Cache'in oluşturulduğu konum (enlem)
    let latitude: Double
    /// Cache'in oluşturulduğu konum (boylam)
    let longitude: Double
    /// Hesaplama metodu (ör: "diyanet", "isna")
    let method: String
    /// Cache'teki ilk günün tarihi
    let startDate: Date
    /// Cache'teki son günün tarihi
    let endDate: Date
}
