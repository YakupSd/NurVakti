import Foundation
import Combine
import CoreLocation

@MainActor
final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var cityName: String = ""
    @Published var countryCode: String = ""  // "TR", "DE", "BR" vb.
    @Published var error: LocationError?
    
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 500 // 500 metre değişimleri bildir
        self.authStatus = manager.authorizationStatus
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        manager.stopUpdatingLocation()
    }
    
    // Reverse geocode → şehir + ülke kodu
    func resolveCity(for location: CLLocation) async -> String {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                let city = placemark.locality ?? placemark.administrativeArea ?? ""
                if !city.isEmpty {
                    self.cityName = city
                    self.countryCode = placemark.isoCountryCode ?? ""
                }
                return city
            }
        } catch {
            self.error = .geocodingFailed
        }
        return ""
    }
    
    // Manuel konum desteği (yaşlı kullanıcı şehir adı girerse)
    func setManualCity(_ name: String, coordinate: CLLocationCoordinate2D) {
        self.cityName = name
        self.currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authStatus = status
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = location
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.error = .locationUnavailable
        }
    }
}

enum LocationError: LocalizedError {
    case permissionDenied, locationUnavailable, geocodingFailed
    
    var errorDescription: String? {
        let lang = LocalizationManager.shared.currentLanguage
        switch self {
        case .permissionDenied:
            switch lang {
            case .tr: return "Konum izni reddedildi"
            case .en: return "Location permission denied"
            case .ar: return "تم رفض إذن الموقع"
            case .de: return "Standortberechtigung verweigert"
            case .pt: return "Permissão de localização negada"
            }
        case .locationUnavailable:
            switch lang {
            case .tr: return "Konum alınamadı"
            case .en: return "Location unavailable"
            case .ar: return "الموقع غير متاح"
            case .de: return "Standort nicht verfügbar"
            case .pt: return "Localização indisponível"
            }
        case .geocodingFailed:
            switch lang {
            case .tr: return "Şehir bilgisi çözümlenemedi"
            case .en: return "City information could not be resolved"
            case .ar: return "تعذر تحديد معلومات المدينة"
            case .de: return "Stadtinformation konnte nicht aufgelöst werden"
            case .pt: return "Não foi possível resolver as informações da cidade"
            }
        }
    }
}
