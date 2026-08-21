import Foundation
import CoreLocation
import CoreMotion
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
    @Published var distanceToMakkahKm: Double = 0
    
    // CoreMotion - Bubble Level / Flatness check
    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    @Published var isPhoneFlat: Bool = true

    // MARK: - Mekke Koordinatları
    private let makkahCoord = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)

    // MARK: - Managers
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    private var headingDelegate: HeadingDelegate?

    // MARK: - Init
    init() {
        headingDelegate = HeadingDelegate(vm: self)
        locationManager.delegate = headingDelegate
        locationManager.headingFilter = 1
        locationManager.headingOrientation = .portrait
    }

    // MARK: - Start / Stop Tracking
    func startTracking() {
        guard CLLocationManager.headingAvailable() else {
            locationError = "Bu cihazda pusula desteklenmiyor."
            return
        }
        isCalibrating = true
        locationManager.startUpdatingHeading()
        
        if let loc = locationManager.location {
            calculateQibla(from: loc)
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        startMotionTracking()
    }

    func stopTracking() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
        motionManager.stopDeviceMotionUpdates()
    }

    // MARK: - Device Motion for Bubble Level
    private func startMotionTracking() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 0.05
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self = self, let motion = motion else { return }
            let p = motion.attitude.pitch * 180 / .pi
            let r = motion.attitude.roll * 180 / .pi
            self.pitch = p
            self.roll = r
            
            // Flat if pitch is within [-20, 20] and roll is within [-20, 20]
            self.isPhoneFlat = abs(p) < 22 && abs(r) < 22
        }
    }

    private var hasTriggeredAlignedHaptic = false

    // MARK: - Heading Update
    func updateHeading(_ newHeading: CLHeading) {
        let val = newHeading.magneticHeading
        
        if abs(val - heading) > 0.1 {
            heading = val
        }
        
        accuracy = newHeading.headingAccuracy
        isCalibrating = newHeading.headingAccuracy < 0 || newHeading.headingAccuracy > 45
        
        let rel = (qiblaAngle - heading + 360).truncatingRemainder(dividingBy: 360)
        relativeAngle = rel
        
        let isAligned = rel < 3.5 || rel > 356.5
        if isAligned && !hasTriggeredAlignedHaptic {
            hasTriggeredAlignedHaptic = true
            HapticManager.shared.success()
        } else if !isAligned {
            hasTriggeredAlignedHaptic = false
        }
    }

    func updateLocation(_ location: CLLocation) {
        calculateQibla(from: location)
    }

    // MARK: - Kıble & Mesafe Hesabı
    private func calculateQibla(from location: CLLocation) {
        let coordinate = location.coordinate
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

        // Distance in km
        let makkahLoc = CLLocation(latitude: makkahCoord.latitude, longitude: makkahCoord.longitude)
        let meters = location.distance(from: makkahLoc)
        distanceToMakkahKm = meters / 1000.0
    }
    
    // MARK: - Direction Assistant Helpers
    var turnInstruction: (text: String, isRight: Bool, delta: Double) {
        let rel = relativeAngle
        let lang = LocalizationManager.shared.currentLanguage
        
        if rel < 3.5 || rel > 356.5 {
            let aligned: String
            switch lang {
            case .tr: aligned = "Kıbleye Hizalandı"
            case .en: aligned = "Aligned with Qibla"
            case .ar: aligned = "تم التوجه للقبلة"
            case .de: aligned = "Auf die Qibla ausgerichtet"
            case .pt: aligned = "Alinhado com a Qibla"
            }
            return (aligned, true, 0)
        } else if rel <= 180 {
            let right: String
            switch lang {
            case .tr: right = String(format: "%.0f° Sağa Dönün", rel)
            case .en: right = String(format: "Turn %.0f° Right", rel)
            case .ar: right = String(format: "أدر %.0f° لليمين", rel)
            case .de: right = String(format: "%.0f° nach Rechts drehen", rel)
            case .pt: right = String(format: "Vire %.0f° à Direita", rel)
            }
            return (right, true, rel)
        } else {
            let leftDelta = 360 - rel
            let left: String
            switch lang {
            case .tr: left = String(format: "%.0f° Sola Dönün", leftDelta)
            case .en: left = String(format: "Turn %.0f° Left", leftDelta)
            case .ar: left = String(format: "أدر %.0f° لليسار", leftDelta)
            case .de: left = String(format: "%.0f° nach Links drehen", leftDelta)
            case .pt: left = String(format: "Vire %.0f° à Esquerda", leftDelta)
            }
            return (left, false, leftDelta)
        }
    }
    
    var formattedDistance: String {
        guard distanceToMakkahKm > 0 else { return "···" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let numStr = formatter.string(from: NSNumber(value: distanceToMakkahKm)) ?? "\(Int(distanceToMakkahKm))"
        return "\(numStr) km"
    }
}

// MARK: - HeadingDelegate
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
