import Foundation
import Combine
import SwiftUI
import UserNotifications
import CoreLocation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var selectedLanguage: LanguageCode = .tr
    @Published var locationStatus: CLAuthorizationStatus = .notDetermined
    @Published var notifStatus: UNAuthorizationStatus = .notDetermined
    @Published var isRequestingLocation: Bool = false
    @Published var isRequestingNotif: Bool = false
    @Published var isCompleted: Bool = false

    private let locationService: LocationService
    private let notifService: NotificationService
    private var cancellables = Set<AnyCancellable>()

    init(locationService: LocationService = LocationService(),
         notifService: NotificationService = .shared) {
        self.locationService = locationService
        self.notifService = notifService
        
        // Konum izni verildiğinde otomatik ilerle
        locationService.$authStatus
            .dropFirst() // İlk değeri (notDetermined) atla
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self?.locationStatus = status
                    self?.goNext()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Sayfa İlerleme
    func goNext() {
        if currentPage < 2 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                currentPage += 1
            }
        } else {
            finishOnboarding()
        }
    }

    func goBack() {
        if currentPage > 0 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                currentPage -= 1
            }
        }
    }

    // MARK: - Sayfa 1: Dil Seçimi
    func selectLanguage(_ code: LanguageCode) {
        selectedLanguage = code
        LocalizationManager.shared.setLanguage(code)
    }

    // MARK: - Sayfa 2: Konum İzni
    func requestLocation() async {
        isRequestingLocation = true
        locationService.requestPermission()
        
        // Sistem diyaloğu kapandıktan sonra minik bir gecikme
        try? await Task.sleep(nanoseconds: 500_000_000)
        isRequestingLocation = false
        
        // Eğer sink zaten tetiklendiyse goNext() çalışmış olacak.
        // Ama manuel kontrol de ekleyelim garanti olsun (özellikle izin zaten vatsa)
        let status = locationService.authStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            goNext()
        }
    }

    func skipLocation() {
        goNext()
    }

    // MARK: - Sayfa 3: Bildirim İzni
    func requestNotification() async {
        isRequestingNotif = true
        let granted = await notifService.requestPermission()
        notifStatus = granted ? .authorized : .denied
        isRequestingNotif = false
        // İzin verilsin ya da verilmesin ilerle
        try? await Task.sleep(nanoseconds: 800_000_000)
        finishOnboarding()
    }

    func skipNotification() {
        finishOnboarding()
    }

    // MARK: - Tamamla
    private func finishOnboarding() {
        var settings = PersistenceService.shared.settings
        settings.language = selectedLanguage
        settings.hasCompletedOnboarding = true
        PersistenceService.shared.saveSettings(settings)

        withAnimation(.easeOut(duration: 0.4)) {
            isCompleted = true
        }
        // ContentView bu notification'ı dinliyor → tabView'a geçiş
        NotificationCenter.default.post(name: .init("OnboardingCompleted"), object: nil)
    }
}
