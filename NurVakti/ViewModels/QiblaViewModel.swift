import Foundation
import CoreLocation
import Combine

@MainActor
final class QiblaViewModel: ObservableObject {

    // MARK: - Published State
    @Published var heading: Double = 0          // Cihazın manyetik kuzeye açısı (°)
    @Published var qiblaAngle: Double = 0       // Kıble yönü (manyetik kuzeyden saat yönünde °)
    @Published var relativeAngle: Double = 0    // Kıble − Heading (ibrenin dönmesi gereken açı)
    @Published var accuracy: CLLocationDirection = -1  // < 0: geçersiz, ≥ 0: ° cinsinden hata
    @Published var isCalibrating: Bool = false
    @Published var locationError: String? = nil

    // MARK: - Mekke Koordinatları (sabit)
    private let makkahCoord = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)

    // MARK: - Location Manager
    private let locationManager = CLLocationManager()
    private var headingDelegate: HeadingDelegate?

    // MARK: - Init
    init() {
        headingDelegate = HeadingDelegate(vm: self)
        locationManager.delegate = headingDelegate
        locationManager.headingFilter = 1          // Her 1° değişimde güncelle
        locationManager.headingOrientation = .portrait
    }

    // MARK: - Start / Stop
    func startTracking() {
        guard CLLocationManager.headingAvailable() else {
            locationError = "Bu cihazda pusula desteklenmiyor."
            return
        }
        isCalibrating = true
        locationManager.startUpdatingHeading()
        // Kıble açısını hesaplamak için konum al
        if let loc = locationManager.location {
            calculateQiblaAngle(from: loc.coordinate)
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    func stopTracking() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }

    // MARK: - Heading Update
    func updateHeading(_ newHeading: CLHeading) {
        // Manyetik kuzey bilgisi al
        let val = newHeading.magneticHeading
        
        // Gürültü engelleme: Çok küçük değişimleri yok sayma (Opsiyonel)
        if abs(val - heading) > 0.1 {
            heading = val
        }
        
        accuracy = newHeading.headingAccuracy
        
        // Kalibrasyon gereksinimi: Hata payı çok yüksekse (örn > 45) veya negatifse
        isCalibrating = newHeading.headingAccuracy < 0 || newHeading.headingAccuracy > 45
        
        relativeAngle = (qiblaAngle - heading + 360).truncatingRemainder(dividingBy: 360)
    }

    func updateLocation(_ location: CLLocation) {
        calculateQiblaAngle(from: location.coordinate)
        // Konum bir kez yetebilir, ancak hassasiyet için açık bırakılabilir 
        // veya belirli aralıklarla güncellenebilir.
    }

    // MARK: - Kıble Hesabı (Great Circle / Bearing formülü)
    private func calculateQiblaAngle(from coordinate: CLLocationCoordinate2D) {
        let lat1 = coordinate.latitude  * .pi / 180
        let lon1 = coordinate.longitude * .pi / 180
        let lat2 = makkahCoord.latitude  * .pi / 180
        let lon2 = makkahCoord.longitude * .pi / 180

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        var bearing = atan2(y, x) * 180 / .pi
        bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)

        qiblaAngle = bearing
        relativeAngle = (bearing - heading + 360).truncatingRemainder(dividingBy: 360)
    }
}

// MARK: - HeadingDelegate (CLLocationManagerDelegate → @MainActor köprüsü)
private final class HeadingDelegate: NSObject, CLLocationManagerDelegate {
    weak var vm: QiblaViewModel?
    init(vm: QiblaViewModel) { self.vm = vm }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in await vm?.updateHeading(newHeading) }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in await vm?.updateLocation(loc) }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in vm?.locationError = error.localizedDescription }
    }
}
