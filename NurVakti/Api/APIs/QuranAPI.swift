import Foundation
import Alamofire

open class QuranAPI {
    
    public static var basePath = "https://api.alquran.cloud/v1"
    
    /**
     Fetch list of surahs.
     */
    open class func getSurahs(completion: @escaping ((_ data: SurahListResponse?, _ error: Error?) -> Void)) {
        let path = "/surah"
        let URLString = basePath + path
        let requestBuilder: RequestBuilder<SurahListResponse>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        requestBuilder.init(method: "GET", URLString: URLString, parameters: nil, isBody: false).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }

    /**
     Fetch surah details with specific edition (translation, tajweed, etc).
     */
    open class func getSurahDetail(number: Int, edition: String, completion: @escaping ((_ data: SurahDetailResponse?, _ error: Error?) -> Void)) {
        let path = "/surah/\(number)/\(edition)"
        let URLString = basePath + path
        let requestBuilder: RequestBuilder<SurahDetailResponse>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        requestBuilder.init(method: "GET", URLString: URLString, parameters: nil, isBody: false).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    /**
     Fetch page details with specific edition.
     */
    open class func getPageDetail(page: Int, edition: String, completion: @escaping ((_ data: SurahDetailResponse?, _ error: Error?) -> Void)) {
        let path = "/page/\(page)/\(edition)"
        let URLString = basePath + path
        let requestBuilder: RequestBuilder<SurahDetailResponse>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        requestBuilder.init(method: "GET", URLString: URLString, parameters: nil, isBody: false).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
}
