import Foundation
import Alamofire

public class JSONEncodingHelper {

    public class func encodingParameters(forEncodableObject encodableObj: Any?) -> [String: Any]? {
        guard let encodableObj = encodableObj else {
            return nil
        }
        guard let data = try? JSONSerialization.data(withJSONObject: encodableObj, options: []) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }

    public class func encodingParameters<T: Encodable>(forEncodableObject encodableObj: T?) -> [String: Any]? {
        guard let encodableObj = encodableObj else {
            return nil
        }
        guard let data = try? JSONEncoder().encode(encodableObj) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }
}
