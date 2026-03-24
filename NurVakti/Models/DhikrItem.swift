import Foundation

struct DhikrItem: Codable, Identifiable, Hashable {
    let id: UUID
    var type: ZikirType
    var arabicText: String          // Arapça metin
    var transliterationTR: String   // Türkçe okunuş
    var meanings: [LanguageCode: String]  // 5 dilde anlam
    var targetCount: Int
    var currentCount: Int
    var isCustom: Bool
    var vibrateOnCount: Bool
    var dailyCompletions: Int
    var totalCompletions: Int
    
    var progress: Double {
        guard targetCount > 0 else { return 0 }
        return Double(currentCount) / Double(targetCount)
    }
    
    var isCompleted: Bool { currentCount >= targetCount }
    
    mutating func increment() {
        if currentCount >= targetCount {
            currentCount = 1
        } else {
            currentCount += 1
        }
        
        if currentCount == targetCount {
            dailyCompletions += 1
            totalCompletions += 1
        }
    }
    
    mutating func reset() {
        currentCount = 0
    }
}

extension DhikrItem {
    static func loadAll() -> [DhikrItem] {
        PersistenceService.shared.load(key: "dhikr_items", as: [DhikrItem].self) ?? []
    }
    
    static func saveAll(_ items: [DhikrItem]) {
        PersistenceService.shared.save(items, key: "dhikr_items")
    }
    
    func save() {
        var all = DhikrItem.loadAll()
        if let index = all.firstIndex(where: { $0.id == self.id }) {
            all[index] = self
        } else {
            all.append(self)
        }
        DhikrItem.saveAll(all)
    }
}
