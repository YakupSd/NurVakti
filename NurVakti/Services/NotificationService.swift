import Foundation
import Combine
import UserNotifications

final class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
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
    
    // Gelecekteki bildirimleri planla (iOS 64 limitine uygun olarak en yakın 50 bildirim)
    func scheduleAll(prayers: [PrayerTime], 
                     alarms: [AlarmModel],
                     language: LanguageCode) async {
        cancelAll()
        
        struct PendingItem {
            let prayer: PrayerName
            let date: Date
            let minutesBefore: Int
            let sound: AlarmSound
            let identifier: String
        }
        
        var pendingItems: [PendingItem] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmm"
        
        for prayer in prayers {
            let weekdayRaw = Calendar.current.component(.weekday, from: prayer.date)
            let currentWeekday = Weekday(rawValue: weekdayRaw)
            
            for alarm in alarms where alarm.isActive {
                if !alarm.repeatDays.isEmpty,
                   let wd = currentWeekday,
                   !alarm.repeatDays.contains(wd) {
                    continue
                }
                
                let targetDate = prayerDate(for: alarm.prayerName, in: prayer)
                let notifyDate = targetDate.addingTimeInterval(Double(-alarm.minutesBefore * 60))
                
                guard notifyDate > Date() else { continue }
                
                let id = "nurvakti_\(alarm.prayerName.rawValue)_\(dateFormatter.string(from: notifyDate))_\(alarm.minutesBefore)"
                pendingItems.append(PendingItem(
                    prayer: alarm.prayerName,
                    date: notifyDate,
                    minutesBefore: alarm.minutesBefore,
                    sound: alarm.soundType,
                    identifier: id
                ))
            }
        }
        
        // En yakın zamana göre sırala ve iOS 64 limitine takılmamak için ilk 50 bildirimi al
        pendingItems.sort { $0.date < $1.date }
        let topItems = Array(pendingItems.prefix(50))
        
        for item in topItems {
            await schedule(prayer: item.prayer,
                           at: item.date,
                           minutesBefore: item.minutesBefore,
                           sound: item.sound,
                           language: language,
                           identifier: item.identifier)
        }
    }
    
    // Tek bildirim
    func schedule(prayer: PrayerName,
                  at date: Date,
                  minutesBefore: Int,
                  sound: AlarmSound,
                  language: LanguageCode,
                  identifier: String? = nil) async {
        let content = UNMutableNotificationContent()
        content.title = "NurVakti 🕌"
        content.body = notificationBody(prayer: prayer, minutes: minutesBefore, language: language)
        content.interruptionLevel = .timeSensitive
        
        // Ses ayarı
        switch sound {
        case .ezan:
            content.sound = UNNotificationSound(named: UNNotificationSoundName("ezan_short.mp3"))
        case .fajr:
            content.sound = UNNotificationSound(named: UNNotificationSoundName("fajr_short.mp3"))
        case .silent:
            content.sound = nil
        case .system:
            content.sound = .default
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let requestID = identifier ?? UUID().uuidString
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
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
