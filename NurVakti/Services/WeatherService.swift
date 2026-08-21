import Foundation
import CoreLocation
import Combine

// MARK: - Weather Service (Open-Meteo API + 3-Hour Smart Cache)
@MainActor
final class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    @Published var currentWeather: WeatherData?
    @Published var isLoading: Bool = false
    
    private let cacheKey = "cached_weather_data"
    private let cacheTTL: TimeInterval = 3 * 3600 // 3 hours (Max 4-6 API calls per day)
    
    init() {
        loadCachedWeather()
    }
    
    // MARK: - Fetch Weather for Coordinate
    func fetchWeather(for coordinate: CLLocationCoordinate2D, forceRefresh: Bool = false) async {
        // 1. Check Cache Validity
        if !forceRefresh, let cached = currentWeather {
            let elapsed = Date().timeIntervalSince(cached.lastUpdated)
            if elapsed < cacheTTL {
                // Cache is fresh, no API call needed
                return
            }
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // 2. Build Open-Meteo URL (Free, Keyless, Fast)
        let lat = String(format: "%.4f", coordinate.latitude)
        let lon = String(format: "%.4f", coordinate.longitude)
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,weather_code,cloud_cover,is_day,precipitation"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return
            }
            
            let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            let current = decoded.current
            
            let condition = mapWeatherCode(current.weather_code)
            
            let weather = WeatherData(
                temperature: current.temperature_2m,
                condition: condition,
                cloudCoverPercent: Double(current.cloud_cover),
                precipitation: current.precipitation,
                isDay: current.is_day == 1,
                lastUpdated: Date()
            )
            
            self.currentWeather = weather
            saveCachedWeather(weather)
            
        } catch {
            print("WeatherService fetch error: \(error.localizedDescription)")
            // If offline, existing cached weather or fallback continues seamlessly
        }
    }
    
    // MARK: - WMO Weather Code Mapper
    private func mapWeatherCode(_ code: Int) -> WeatherCondition {
        switch code {
        case 0:
            return .clear
        case 1, 2:
            return .partlyCloudy
        case 3:
            return .overcast
        case 45, 48:
            return .fog
        case 51, 53, 55, 56, 57:
            return .drizzle
        case 61, 63, 80, 81:
            return .rain
        case 65, 66, 67, 82:
            return .heavyRain
        case 71, 73, 75, 77, 85, 86:
            return .snow
        case 95, 96, 99:
            return .thunderstorm
        default:
            return .clear
        }
    }
    
    // MARK: - Cache Helpers
    private func saveCachedWeather(_ weather: WeatherData) {
        if let encoded = try? JSONEncoder().encode(weather) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }
    
    private func loadCachedWeather() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let decoded = try? JSONDecoder().decode(WeatherData.self, from: data) else {
            return
        }
        self.currentWeather = decoded
    }
}

// MARK: - Open-Meteo DTO
private struct OpenMeteoResponse: Codable {
    let current: OpenMeteoCurrent
}

private struct OpenMeteoCurrent: Codable {
    let temperature_2m: Double
    let weather_code: Int
    let cloud_cover: Int
    let is_day: Int
    let precipitation: Double
}
