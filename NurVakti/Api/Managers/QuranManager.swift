import Foundation
import UIKit

public class QuranManager {
    
    public init() {}
    
    // MARK: - Callback API (geriye dönük uyumluluk)
    
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
    
    /// Surah detayını çeker
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
    
    /// Sayfa detayını çeker
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
    
    // MARK: - Async/Await API (tercih edilen modern yöntem)
    
    public func getSurahsAsync() async throws -> SurahListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            getSurahs { response in
                continuation.resume(returning: response)
            } onFailure: { error in
                continuation.resume(throwing: error ?? ApplicationErrorType.noResponse(desc: "Unknown", code: nil))
            }
        }
    }
    
    public func getSurahDetailAsync(number: Int, edition: String) async throws -> SurahDetailResponse {
        return try await withCheckedThrowingContinuation { continuation in
            getSurahDetail(number: number, edition: edition) { response in
                continuation.resume(returning: response)
            } onFailure: { error in
                continuation.resume(throwing: error ?? ApplicationErrorType.noResponse(desc: "Unknown", code: nil))
            }
        }
    }
    
    public func getPageDetailAsync(page: Int, edition: String) async throws -> SurahDetailResponse {
        return try await withCheckedThrowingContinuation { continuation in
            getPageDetail(page: page, edition: edition) { response in
                continuation.resume(returning: response)
            } onFailure: { error in
                continuation.resume(throwing: error ?? ApplicationErrorType.noResponse(desc: "Unknown", code: nil))
            }
        }
    }
}
