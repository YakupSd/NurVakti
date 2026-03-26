import Foundation
import Combine
import UserNotifications

final class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await checkPermission()
            return granted
        } catch {
            return false
        }
    }
    
    func checkPermission() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        DispatchQueue.main.async {
            self.permissionStatus = settings.authorizationStatus
        }
    }
    
    // 30 günlük bildirimleri toplu planla
    func scheduleAll(prayers: [PrayerTime], 
                     alarms: [AlarmModel],
                     language: LanguageCode) async {
        cancelAll()
        for prayer in prayers {
            // Bu gün hangi haftanın günü?
            let weekdayRaw = Calendar.current.component(.weekday, from: prayer.date)
            let currentWeekday = Weekday(rawValue: weekdayRaw)
            
            for alarm in alarms where alarm.isActive {
                // repeatDays doluysa sadece seçili günlerde planla
                if !alarm.repeatDays.isEmpty,
                   let wd = currentWeekday,
                   !alarm.repeatDays.contains(wd) {
                    continue
                }
                
                let targetDate = prayerDate(for: alarm.prayerName, in: prayer)
                let notifyDate = targetDate.addingTimeInterval(Double(-alarm.minutesBefore * 60))
                
                guard notifyDate > Date() else { continue }
                
                await schedule(prayer: alarm.prayerName,
                               at: notifyDate,
                               minutesBefore: alarm.minutesBefore,
                               sound: alarm.soundType,
                               language: language)
            }
        }
    }
    
    // Tek bildirim
    func schedule(prayer: PrayerName,
                  at date: Date,
                  minutesBefore: Int,
                  sound: AlarmSound,
                  language: LanguageCode) async {
        let content = UNMutableNotificationContent()
        content.title = "NurVakti 🕌"
        content.body = notificationBody(prayer: prayer, minutes: minutesBefore, language: language)
        // Time-sensitive seviye: cihaz Odak modu'nda bile görünsün
        content.interruptionLevel = .timeSensitive
        
        // Ses ayarı
        // Not: ezan.mp3 / fajr.mp3 için Resources/Sounds/ klasörüne ses dosyası eklenmelidir.
        switch sound {
        case .ezan:
            content.sound = UNNotificationSound(named: UNNotificationSoundName("ezan.mp3"))
        case .fajr:
            content.sound = UNNotificationSound(named: UNNotificationSoundName("fajr.mp3"))
        case .silent:
            content.sound = nil
        case .system:
            content.sound = .default
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    // Tümünü iptal et
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancel(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    // Bildirim içerikleri 5 dilde
    private func notificationBody(prayer: PrayerName,
                                   minutes: Int,
                                   language: LanguageCode) -> String {
        let pName = prayer.localizedName(for: language)
        switch language {
        case .tr: return minutes == 0 ? "\(pName) vakti girdi." : "\(pName) vaktine \(minutes) dakika kaldı."
        case .ar: return minutes == 0 ? "حان وقت \(pName)" : "بقي \(minutes) دقائق على صلاة \(pName)"
        case .en: return minutes == 0 ? "It's time for \(pName)" : "\(pName) prayer in \(minutes) minutes"
        case .de: return minutes == 0 ? "Es ist Zeit für \(pName)" : "\(pName)-Gebet in \(minutes) Minuten"
        case .pt: return minutes == 0 ? "É hora da oração de \(pName)" : "Oração de \(pName) em \(minutes) minutos"
        }
    }
    
    private func prayerDate(for name: PrayerName, in prayer: PrayerTime) -> Date {
        switch name {
        case .imsak: return prayer.imsak
        case .fajr: return prayer.fajr
        case .sunrise: return prayer.sunrise
        case .dhuhr: return prayer.dhuhr
        case .asr: return prayer.asr
        case .maghrib: return prayer.maghrib
        case .isha: return prayer.isha
        }
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
