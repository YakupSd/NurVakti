import Foundation

public enum ApplicationErrorType: Error {
    case notSuccessful(desc: String, code: String?)
    case noResponse(desc: String, code: String?)
    case unauthorized
}

public struct ResultInfo: Codable {
    public var type: String?
    public var details: [String?]?
    public var message: String?
    public var logMessage: String?
    public var values: [String: String]?
    public var title: String?
    public var info: String?
    public var code: String?

    public enum CodingKeys: String, CodingKey {
        case type = "Type"
        case details = "Details"
        case message = "Message"
        case logMessage = "LogMessage"
        case values = "Values"
        case title = "Title"
        case info = "Info"
        case code = "Code"
    }
}

public enum ErrorCode: String {
    case noResponse = "Action.NoResponse"
    case sessionExpired = "401"
}

public extension Error {
    var isUnAuthorized: Bool {
        return (self as NSError).code == 401
    }
    
    var httpStatusCode: Int? {
        return (self as NSError).code
    }
}
