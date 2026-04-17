import Foundation

public class SwaggerClientAPI {
    public static var basePath = "https://api.aladhan.com/v1"
    public static var requestBuilderFactory: RequestBuilderFactory = AlamofireRequestBuilderFactory()
}

public protocol RequestBuilderFactory {
    func getBuilder<T: Decodable>() -> RequestBuilder<T>.Type
}

public class AlamofireRequestBuilderFactory: RequestBuilderFactory {
    public func getBuilder<T: Decodable>() -> RequestBuilder<T>.Type {
        return AlamofireRequestBuilder<T>.self
    }
}
