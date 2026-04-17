import Foundation

public struct DhikrItem: Codable, Identifiable, Hashable {
    public let id: UUID
    public var type: ZikirType
    public var arabicText: String          // Arapça metin
    public var transliterationTR: String   // Türkçe okunuş
    public var meanings: [LanguageCode: String]  // 5 dilde anlam
    public var targetCount: Int
    public var currentCount: Int
    public var isCustom: Bool
    public var vibrateOnCount: Bool
    public var dailyCompletions: Int
    public var totalCompletions: Int
    
    public init(id: UUID = UUID(), type: ZikirType, arabicText: String, transliterationTR: String, meanings: [LanguageCode : String], targetCount: Int, currentCount: Int, isCustom: Bool, vibrateOnCount: Bool, dailyCompletions: Int, totalCompletions: Int) {
        self.id = id
        self.type = type
        self.arabicText = arabicText
        self.transliterationTR = transliterationTR
        self.meanings = meanings
        self.targetCount = targetCount
        self.currentCount = currentCount
        self.isCustom = isCustom
        self.vibrateOnCount = vibrateOnCount
        self.dailyCompletions = dailyCompletions
        self.totalCompletions = totalCompletions
    }
    
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
