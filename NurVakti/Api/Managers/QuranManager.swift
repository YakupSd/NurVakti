import Foundation
import UIKit

public class QuranManager {
    
    public init() {}
    
    let noResponseErrorMessage = "Lütfen internet bağlantınızı kontrol edin."
    let okButtonText = "Tamam"
    var loadingView: LoadingView?
    
    public func getSurahs(
        onSuccess: @escaping (SurahListResponse) -> Void,
        onFailure: @escaping (ApplicationErrorType?) -> Void
    ) {
        // Optional: Show loading for surah list if needed
        QuranAPI.getSurahs { response, error in
            if let res = response {
                onSuccess(res)
            } else {
                onFailure(.noResponse(desc: error?.localizedDescription ?? "Unknown", code: nil))
            }
        }
    }
    
    public func getSurahDetail(
        number: Int,
        edition: String,
        showLoading: Bool = true,
        onSuccess: @escaping (SurahDetailResponse) -> Void,
        onFailure: @escaping (ApplicationErrorType?) -> Void
    ) {
        if showLoading {
            DispatchQueue.main.async {
                self.loadingView = LoadingView()
                self.loadingView?.dashboardLoadingTopMostView()
            }
        }
        
        QuranAPI.getSurahDetail(number: number, edition: edition) { response, error in
            if showLoading {
                DispatchQueue.main.async {
                    self.loadingView?.dismiss()
                }
            }
            
            if let res = response {
                onSuccess(res)
            } else {
                if let err = error {
                    DispatchQueue.main.async {
                        let errorPopup = ServerErrorPopup(message: self.noResponseErrorMessage, buttonText: self.okButtonText)
                        UIApplication.topMostViewController()?.present(errorPopup, animated: true)
                    }
                    onFailure(.noResponse(desc: err.localizedDescription, code: nil))
                }
            }
        }
    }
    
    public func getPageDetail(
        page: Int,
        edition: String,
        showLoading: Bool = true,
        onSuccess: @escaping (SurahDetailResponse) -> Void,
        onFailure: @escaping (ApplicationErrorType?) -> Void
    ) {
        if showLoading {
            DispatchQueue.main.async {
                self.loadingView = LoadingView()
                self.loadingView?.dashboardLoadingTopMostView()
            }
        }
        
        QuranAPI.getPageDetail(page: page, edition: edition) { response, error in
            if showLoading {
                DispatchQueue.main.async {
                    self.loadingView?.dismiss()
                }
            }
            
            if let res = response {
                onSuccess(res)
            } else {
                if let err = error {
                    DispatchQueue.main.async {
                        let errorPopup = ServerErrorPopup(message: self.noResponseErrorMessage, buttonText: self.okButtonText)
                        UIApplication.topMostViewController()?.present(errorPopup, animated: true)
                    }
                    onFailure(.noResponse(desc: err.localizedDescription, code: nil))
                }
            }
        }
    }
}
