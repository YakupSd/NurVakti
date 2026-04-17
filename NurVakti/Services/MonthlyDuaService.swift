import Foundation
import SwiftUI
import Combine

@MainActor
final class MonthlyDuaService: ObservableObject {
    public static let shared = MonthlyDuaService()
    
    @Published var monthlyDuas: [PrayerDua] = []
    @Published var isLoading = false
    @Published var lastUpdated: Date?
    
    private let cacheKey = "monthly_duas_cache"
    private let cacheDateKey = "monthly_duas_last_update"
    
    private init() {}
    
    // Called on app launch and by BGTask
    func refreshIfNeeded() async {
        let now = Date()
        let calendar = Calendar.current
        
        // Check if we're in a new month vs last update
        if let lastUpdate = loadCacheDate() {
            let lastMonth = calendar.component(.month, from: lastUpdate)
            let lastYear  = calendar.component(.year,  from: lastUpdate)
            let nowMonth  = calendar.component(.month, from: now)
            let nowYear   = calendar.component(.year,  from: now)
            
            // Same month → use cache, no network call
            if lastMonth == nowMonth && lastYear == nowYear {
                if let cached = loadFromCache(), !cached.isEmpty {
                    monthlyDuas = cached
                    lastUpdated = lastUpdate
                    return
                }
            }
        }
        
        // New month (or first launch or empty cache) → fetch fresh
        await fetchFromAPI()
    }
    
    private func fetchFromAPI() async {
        isLoading = true
        defer { isLoading = false }
        
        let monthIndex = Calendar.current.component(.month, from: Date())
        let ayahPlan = MonthlyAyahPlan.plan(for: monthIndex)
        
        let duas = await MonthlyDuaAPI.shared.fetchMonthlyDuas(plan: ayahPlan)
        
        if !duas.isEmpty {
            saveToCache(duas)
            monthlyDuas = duas
            lastUpdated = Date()
        }
    }
    
    // ── Cache helpers ──
    private func saveToCache(_ duas: [PrayerDua]) {
        guard let data = try? JSONEncoder().encode(duas) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey)
        UserDefaults.standard.set(Date(), forKey: cacheDateKey)
    }
    
    private func loadFromCache() -> [PrayerDua]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let duas = try? JSONDecoder().decode([PrayerDua].self, from: data)
        else { return nil }
        return duas
    }
    
    private func loadCacheDate() -> Date? {
        UserDefaults.standard.object(forKey: cacheDateKey) as? Date
    }
}
