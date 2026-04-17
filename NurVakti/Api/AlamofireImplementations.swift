import Foundation
import Alamofire

open class RequestBuilder<T: Decodable> {
    public let method: String
    public let URLString: String
    public let parameters: [String: Any]?
    public let isBody: Bool
    public let headers: [String: String]

    required public init(method: String, URLString: String, parameters: [String: Any]?, isBody: Bool, headers: [String: String] = [:]) {
        self.method = method
        self.URLString = URLString
        self.parameters = parameters
        self.isBody = isBody
        self.headers = headers
    }

    open func execute(_ completion: @escaping (_ response: Response<T>?, _ error: Error?) -> Void) { }
}

public struct Response<T> {
    public let body: T?
    public let statusCode: Int
}

open class AlamofireRequestBuilder<T: Decodable>: RequestBuilder<T> {
    open override func execute(_ completion: @escaping (Response<T>?, Error?) -> Void) {
        let httpMethod = HTTPMethod(rawValue: method.uppercased())
        let encoding: ParameterEncoding = isBody ? JSONEncoding.default : URLEncoding.default
        
        AF.request(URLString, method: httpMethod, parameters: parameters, encoding: encoding, headers: HTTPHeaders(headers))
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    completion(Response(body: value, statusCode: response.response?.statusCode ?? 200), nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
}
