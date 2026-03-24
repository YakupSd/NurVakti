import Foundation
import Combine
import UIKit
import UserNotifications

@MainActor
final class AlarmViewModel: ObservableObject {
    @Published var alarms: [AlarmModel] = []
    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined
    @Published var showPermissionAlert: Bool = false
    
    private let persistService: PersistenceService
    private let notifService: NotificationService
    
    init(persistService: PersistenceService = .shared, notifService: NotificationService = .shared) {
        self.persistService = persistService
        self.notifService = notifService
        self.alarms = persistService.alarms
    }
    
    func onAppear() async {
        await notifService.checkPermission()
        self.permissionStatus = notifService.permissionStatus
        self.alarms = persistService.alarms
    }
    
    func toggleAlarm(_ alarm: AlarmModel) async {
        if permissionStatus != .authorized {
            showPermissionAlert = true
            return
        }
        
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index].isActive.toggle()
            saveAndReschedule()
        }
    }
    
    func updateMinutesBefore(_ minutes: Int, for alarmID: UUID) {
        if let index = alarms.firstIndex(where: { $0.id == alarmID }) {
            alarms[index].minutesBefore = minutes
            saveAndReschedule()
        }
    }
    
    func updateSound(_ sound: AlarmSound, for alarmID: UUID) {
        if let index = alarms.firstIndex(where: { $0.id == alarmID }) {
            alarms[index].soundType = sound
            saveAndReschedule()
        }
    }
    
    private func saveAndReschedule() {
        persistService.saveAlarms(alarms)
        // Bildirimleri yeniden planlamak için NotificationService çağrılmalı
        // Task { await notifService.scheduleAll(...) }
    }
    
    func requestPermission() async {
        let granted = await notifService.requestPermission()
        if granted {
            self.permissionStatus = .authorized
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
