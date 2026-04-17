import Foundation

public struct AsmaResponse: Codable {
    public let number: Int
    public let name: String
    public let transliteration: String
    public let translation: String
    public let meaning: String
    public let audio: String
}

public struct AsmaBaseResponse: Codable {
    public let code: Int
    public let status: String
    public let data: AsmaDataWrapper
}

public struct AsmaDataWrapper: Codable {
    public let names: [AsmaResponse]
    public let total: Int
}

public class AsmaService {
    public static let shared = AsmaService()
    
    private init() {}
    
    public func fetchNames(language: String = "tr") async throws -> [EsmaulHusna] {
        let key = APIConfig.islamicAPIKey
        
        // If key is still the placeholder or empty, we shouldn't attempt the request
        guard !key.isEmpty && key.count > 10 && !key.lowercased().contains("your_key") else {
            throw NSError(domain: "AsmaService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key Eksik. Lütfen APIConfig.swift dosyasını güncelleyin."])
        }
        
        let urlString = "\(APIConfig.islamicBaseURL)/api/v1/asma-ul-husna/?language=\(language)&api_key=\(key)"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "AsmaService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Geçersiz URL."])
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "AsmaService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Sunucu hatası."])
        }
        
        let baseResponse = try JSONDecoder().decode(AsmaBaseResponse.self, from: data)
        let apiResponses = baseResponse.data.names
        
        // Map API response to our app model
        return apiResponses.map { res in
            EsmaulHusna(
                id: res.number,
                name: res.name,
                title: res.transliteration,
                meanings: [.tr: res.translation, .en: res.translation], // Mapping to current language
                virtue: res.meaning, // Using the long meaning as virtue/fazilet
                audioURL: "\(APIConfig.islamicBaseURL)\(res.audio)"
            )
        }
    }
}
