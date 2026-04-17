import Foundation

// MARK: - Quran API Response DTOs

public struct SurahListResponse: Codable {
    public let code: Int
    public let status: String
    public let data: [SurahDTO]
}

public struct SurahDTO: Codable {
    public let number: Int
    public let name: String
    public let englishName: String
    public let numberOfAyahs: Int
    public let revelationType: String
}

public struct SurahDetailResponse: Codable {
    public let code: Int
    public let status: String
    public let data: SurahDetailData
}

public struct SurahDetailData: Codable {
    public let number: Int
    public let ayahs: [AyahDTO]
}

public struct AyahDTO: Codable {
    public let number: Int
    public let text: String
    public let numberInSurah: Int
    public let surah: SurahDTO?
}
