import Foundation
import UIKit

public class PrayerManager {
    
    public init() {}
    
    let noResponseErrorMessage = "Lütfen internet bağlantınızı kontrol edin." // LocalizableUtils.shared.getGeneralValue(section: .result, key: "Action.NoResponse.Message")
    let okButtonText = "Tamam" // LocalizableUtils.shared.getGeneralValue(section: .label, key: "Common.OK")
    var loadingView: LoadingView?
    
    public func getPrayerTimes(
        latitude: Double,
        longitude: Double,
        method: Int,
        onSuccess: @escaping (AladhanResponse) -> Void,
        onFailure: @escaping (ApplicationErrorType?) -> Void
    ) {
        DispatchQueue.main.async { [self] in
            loadingView = LoadingView()
            loadingView?.dashboardLoadingTopMostView()
        }
        
        PrayerAPI.getCalendar(latitude: latitude, longitude: longitude, method: method) { (response: AladhanResponse?, error: Error?) in
            DispatchQueue.main.async {
                if let loadingView = self.loadingView {
                    loadingView.dismiss()
                }
            }
            
            if let res = response {
                if res.code == 200 {
                    onSuccess(res)
                } else {
                    let errorMessage = "Sunucu hatası: \(res.status)"
                    DispatchQueue.main.async {
                        let errorPopup = ServerErrorPopup(message: errorMessage, buttonText: self.okButtonText)
                        UIApplication.topMostViewController()?.present(errorPopup, animated: true)
                    }
                    onFailure(.notSuccessful(desc: errorMessage, code: "\(res.code)"))
                }
            } else {
                if let err = error {
                    if err.isUnAuthorized {
                        onFailure(.unauthorized)
                    } else {
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
}
