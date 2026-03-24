import BackgroundTasks
import CoreLocation

// MARK: - BackgroundRefreshService
// Kullanıcı seyahat ediyorsa arka planda namaz vakitleri güncellenir.
//
// KURULUM (Xcode'da manuel yapılacaklar):
//   1. Target → Signing & Capabilities → + Background Modes
//      ☑ Background fetch
//      ☑ Background processing
//   2. Info.plist'e ekle:
//      BGTaskSchedulerPermittedIdentifiers → [com.nurvakti.prayerRefresh]

final class BackgroundRefreshService {
    static let shared = BackgroundRefreshService()
    private init() {}

    static let taskIdentifier = "com.nurvakti.prayerRefresh"

    // Konum değişim eşiği (km) — bu kadar hareket etmeden güncelleme yapma
    private let locationThresholdKm: Double = 25.0

    // MARK: - Kayıt (AppDelegate'te çağrılır)
    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.taskIdentifier, using: nil) { task in
            self.handle(task: task as! BGAppRefreshTask)
        }
    }

    // MARK: - Planlama
    func scheduleIfNeeded() {
        // Mevcut pending requestleri kontrol et
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            let alreadyScheduled = requests.contains {
                $0.identifier == Self.taskIdentifier
            }
            guard !alreadyScheduled else { return }
            self.schedule()
        }
    }

    private func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        // Minimum 15 dakika aralık — pil tüketimi dengesi
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch BGTaskScheduler.Error.unavailable {
            // Simülatörde BGTask çalışmaz, sorun değil
            print("BackgroundRefresh: BGTask unavailable (simulator?)")
        } catch {
            print("BackgroundRefresh: Schedule error — \(error)")
        }
    }

    // MARK: - Task Handler
    private func handle(task: BGAppRefreshTask) {
        // Bir sonraki görevi şimdiden planla
        scheduleIfNeeded()

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        Task {
            let updated = await refreshPrayerTimesIfNeeded()
            task.setTaskCompleted(success: updated)
        }
    }

    // MARK: - Güncelleme Mantığı
    @discardableResult
    private func refreshPrayerTimesIfNeeded() async -> Bool {
        let settings = PersistenceService.shared.settings

        // Manuel şehir kullanan kullanıcı için arka plan gereksiz
        guard !settings.useManualLocation else { return false }

        // Pil dostu: Mevcut konum ile son kayıtlı konumu karşılaştır
        guard let currentLocation = await fetchCurrentLocation() else { return false }
        let lastLocation = PersistenceService.shared.lastKnownLocation

        if let last = lastLocation {
            let distance = currentLocation.distance(from: last) / 1000 // km
            guard distance >= locationThresholdKm else {
                return false // Yeterince hareket yok, güncelleme yapma
            }
        }

        // Konumu kaydet
        PersistenceService.shared.saveLastKnownLocation(currentLocation)

        // Prayer time servisini tetikle
        let prayerService = PrayerTimeService()
        let method = settings.calculationMethod
        let madhab = settings.madhab
        prayerService.calculate(for: currentLocation, method: method, madhab: madhab)

        return true
    }

    private func fetchCurrentLocation() async -> CLLocation? {
        // Basit one-shot konum talebi
        return await withCheckedContinuation { continuation in
            let helper = OneTimeLocationFetcher {
                continuation.resume(returning: $0)
            }
            helper.start()
            // Weak reference sorununu önlemek için retain ediyoruz
            _ = helper
        }
    }
}

// MARK: - OneTimeLocationFetcher (yardımcı)
private final class OneTimeLocationFetcher: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let completion: (CLLocation?) -> Void
    private var resolved = false

    init(completion: @escaping (CLLocation?) -> Void) {
        self.completion = completion
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func start() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !resolved else { return }
        resolved = true
        completion(locations.last)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard !resolved else { return }
        resolved = true
        completion(nil)
    }
}
