import Foundation

final class MonthlyDuaAPI {
    static let shared = MonthlyDuaAPI()
    private init() {}
    
    // Fetches all ayahs for the given month plan
    func fetchMonthlyDuas(plan: [(surah: Int, ayah: Int)]) async -> [PrayerDua] {
        var duas: [PrayerDua] = []
        
        // Fetch in batches of 5 (avoid rate limiting)
        for batch in plan.chunked(into: 5) {
            await withTaskGroup(of: PrayerDua?.self) { group in
                for (surah, ayah) in batch {
                    group.addTask {
                        await self.fetchAyahAsDua(surah: surah, ayah: ayah)
                    }
                }
                for await dua in group {
                    if let dua { duas.append(dua) }
                }
            }
            // Small delay between batches
            try? await Task.sleep(nanoseconds: 300_000_000)
        }
        
        return duas
    }
    
    private func fetchAyahAsDua(surah: Int, ayah: Int) async -> PrayerDua? {
        // Reuse HomeViewModel's fetcher for 5-language support
        let content = await HomeViewModel.shared.loadDailyAyah(surah: surah, ayah: ayah)
        
        let audioID = String(format: "%03d%03d", surah, ayah)
        
        return PrayerDua(
            id: UUID().uuidString,
            audioFileName: audioID,
            arabicText: content.arabicText,
            transliteration: "",
            titles: content.translations.mapValues { _ in content.source },
            meanings: content.translations
        )
    }
}
