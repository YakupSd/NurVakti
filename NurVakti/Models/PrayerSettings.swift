import Foundation

struct PrayerSettings: Codable, Identifiable, Hashable {
    var id = UUID()
    
    var calculationMethod: String = "Diyanet"
    var madhab: Madhab = .hanafi
    
    struct NotificationPreference: Codable, Hashable {
        var isEnabled: Bool = true
        var offsetMinutes: Int = 0 // Pozitif: geç, Negatif: erken
    }
}

extension PrayerSettings {
    func encodeToJSON() -> Data? {
        try? JSONEncoder().encode(self)
    }
    
    static func decodeFromJSON(_ data: Data) -> PrayerSettings? {
        try? JSONDecoder().decode(PrayerSettings.self, from: data)
    }
}
