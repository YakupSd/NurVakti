import Foundation

// MARK: - Aladhan Prayer Times API DTOs
public struct AladhanResponse: Codable {
    public let code: Int
    public let status: String
    public let data: [AladhanDayData]
}

public struct AladhanDayData: Codable {
    public let timings: [String: String]
    public let date: AladhanDate
}

public struct AladhanDate: Codable {
    public let readable: String
    public let timestamp: String
    public let hijri: AladhanHijri
}

public struct AladhanHijri: Codable {
    public let date: String
    public let day: String
    public let weekday: AladhanWeekday
    public let month: AladhanMonth
    public let year: String
}

public struct AladhanWeekday: Codable {
    public let en: String
    public let ar: String?
}

public struct AladhanMonth: Codable {
    public let number: Int
    public let en: String
    public let ar: String?
}
