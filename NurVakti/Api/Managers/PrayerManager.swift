import Foundation
import UIKit

public class PrayerManager {
    
    public init() {}
    
    /// API'den aylık namaz vakitlerini çeker.
    /// Cache-first strateji sayesinde bu fonksiyon artık sadece gerçekten gerektiğinde çağrılır.
    /// LoadingView overlay kaldırıldı — veri cache'ten anında yüklenir, API çağrısı sessiz arka planda yapılır.
    public func getPrayerTimes(
        latitude: Double,
        longitude: Double,
        method: Int,
        onSuccess: @escaping (AladhanResponse) -> Void,
        onFailure: @escaping (ApplicationErrorType?) -> Void
    ) {
        PrayerAPI.getCalendar(latitude: latitude, longitude: longitude, method: method) { (response: AladhanResponse?, error: Error?) in
            if let res = response {
                if res.code == 200 {
                    onSuccess(res)
                } else {
                    let errorMessage = "Sunucu hatası: \(res.status)"
                    print("PrayerManager: \(errorMessage)")
                    onFailure(.notSuccessful(desc: errorMessage, code: "\(res.code)"))
                }
            } else if let err = error {
                if err.isUnAuthorized {
                    onFailure(.unauthorized)
                } else {
                    print("PrayerManager: Ağ hatası — \(err.localizedDescription)")
                    onFailure(.noResponse(desc: err.localizedDescription, code: nil))
                }
            } else {
                onFailure(.noResponse(desc: "Bilinmeyen hata", code: nil))
            }
        }
    }
}
