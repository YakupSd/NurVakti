import Foundation
import Alamofire

open class PrayerAPI {
    
    /**
     Fetch monthly prayer times from Aladhan API.
     
     - parameter latitude: (query)
     - parameter longitude: (query)
     - parameter method: (query)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getCalendar(latitude: Double, longitude: Double, method: Int, completion: @escaping ((_ data: AladhanResponse?, _ error: Error?) -> Void)) {
        getCalendarWithRequestBuilder(latitude: latitude, longitude: longitude, method: method).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }

    /**
     - GET /calendar
     - parameter latitude: (query)
     - parameter longitude: (query)
     - parameter method: (query)
     - returns: RequestBuilder<AladhanResponse> 
     */
    open class func getCalendarWithRequestBuilder(latitude: Double, longitude: Double, method: Int) -> RequestBuilder<AladhanResponse> {
        let path = "/calendar"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "method": method
        ]
        
        let targetURL = URLComponents(string: URLString)
        let requestBuilder: RequestBuilder<AladhanResponse>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (targetURL?.string ?? URLString), parameters: parameters, isBody: false)
    }
}
