import Foundation
import Combine
import CoreLocation

final class LocationService: NSObject, ObservableObject {
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var cityName: String = ""
    @Published var countryCode: String = ""  // "TR", "DE", "BR" vb.
    @Published var error: LocationError?
    
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.distanceFilter = 1000 // 1 km değişimden azını bildirme
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
                DispatchQueue.main.async {
                    self.cityName = city
                    self.countryCode = placemark.isoCountryCode ?? ""
                }
                return city
            }
        } catch {
            DispatchQueue.main.async {
                self.error = .geocodingFailed
            }
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
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authStatus = manager.authorizationStatus
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.error = .locationUnavailable
        }
    }
}

enum LocationError: LocalizedError {
    case permissionDenied, locationUnavailable, geocodingFailed
    
    var errorDescription: String? {
        // Not: Gerçekte AppConstants üzerinden veya localizable'dan dil bazlı dönmeli
        switch self {
        case .permissionDenied: return "Konum izni reddedildi"
        case .locationUnavailable: return "Konum alınamadı"
        case .geocodingFailed: return "Şehir bilgisi çözümlenemedi"
        }
    }
}
