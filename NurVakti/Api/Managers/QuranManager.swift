import Foundation
import UIKit

public class QuranManager {
    
    public init() {}
    
    /// Surah listesini çeker (loading overlay yok — cache-first yapıda çalışır)
    public func getSurahs(
        onSuccess: @escaping (SurahListResponse) -> Void,
        onFailure: @escaping (ApplicationErrorType?) -> Void
    ) {
        QuranAPI.getSurahs { response, error in
            if let res = response {
                onSuccess(res)
            } else {
                onFailure(.noResponse(desc: error?.localizedDescription ?? "Unknown", code: nil))
            }
        }
    }
    
    /// Surah detayını çeker (loading overlay kaldırıldı — hata durumunda takılma sorunu çözüldü)
    public func getSurahDetail(
        number: Int,
        edition: String,
        showLoading: Bool = false,
        onSuccess: @escaping (SurahDetailResponse) -> Void,
        onFailure: @escaping (ApplicationErrorType?) -> Void
    ) {
        QuranAPI.getSurahDetail(number: number, edition: edition) { response, error in
            if let res = response {
                onSuccess(res)
            } else {
                let desc = error?.localizedDescription ?? "Bilinmeyen hata"
                print("QuranManager: getSurahDetail error — \(desc)")
                onFailure(.noResponse(desc: desc, code: nil))
            }
        }
    }
    
    /// Sayfa detayını çeker (loading overlay kaldırıldı)
    public func getPageDetail(
        page: Int,
        edition: String,
        showLoading: Bool = false,
        onSuccess: @escaping (SurahDetailResponse) -> Void,
        onFailure: @escaping (ApplicationErrorType?) -> Void
    ) {
        QuranAPI.getPageDetail(page: page, edition: edition) { response, error in
            if let res = response {
                onSuccess(res)
            } else {
                let desc = error?.localizedDescription ?? "Bilinmeyen hata"
                print("QuranManager: getPageDetail error — \(desc)")
                onFailure(.noResponse(desc: desc, code: nil))
            }
        }
    }
}
