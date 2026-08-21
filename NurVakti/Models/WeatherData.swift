import Foundation

// MARK: - Weather Condition Enum
enum WeatherCondition: String, Codable, CaseIterable {
    case clear          // Açık / Güneşli
    case partlyCloudy   // Parçalı Bulutlu
    case overcast       // Kapalı / Çok Bulutlu
    case drizzle        // Çisenti
    case rain           // Yağmurlu
    case heavyRain      // Şiddetli Yağmur
    case thunderstorm   // Gök Gürültülü Fırtına
    case snow           // Karlı
    case heavySnow      // Yoğun Karlı
    case fog            // Sisli / Puslu
    
    var icon: String {
        switch self {
        case .clear:        return "sun.max.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .overcast:     return "cloud.fill"
        case .drizzle:      return "cloud.drizzle.fill"
        case .rain:         return "cloud.rain.fill"
        case .heavyRain:    return "cloud.heavyrain.fill"
        case .thunderstorm: return "cloud.bolt.rain.fill"
        case .snow:         return "snowflake"
        case .heavySnow:    return "cloud.snow.fill"
        case .fog:          return "cloud.fog.fill"
        }
    }
    
    var localizedNameTr: String {
        switch self {
        case .clear:        return "Açık"
        case .partlyCloudy: return "Parçalı Bulutlu"
        case .overcast:     return "Kapalı"
        case .drizzle:      return "Çisenti"
        case .rain:         return "Yağmurlu"
        case .heavyRain:    return "Şiddetli Yağmur"
        case .thunderstorm: return "Gök Gürültülü Fırtına"
        case .snow:         return "Karlı"
        case .heavySnow:    return "Yoğun Karlı"
        case .fog:          return "Sisli"
        }
    }
}

// MARK: - Weather Data Model
struct WeatherData: Codable {
    let temperature: Double       // Celcius
    let condition: WeatherCondition
    let cloudCoverPercent: Double // 0 - 100
    let precipitation: Double     // mm
    let isDay: Bool
    let lastUpdated: Date
    
    var formattedTemperature: String {
        "\(Int(round(temperature)))°C"
    }
    
    static var placeholder: WeatherData {
        WeatherData(
            temperature: 22.0,
            condition: .clear,
            cloudCoverPercent: 20.0,
            precipitation: 0.0,
            isDay: true,
            lastUpdated: Date()
        )
    }
}
