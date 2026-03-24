import Foundation

struct ZakatAssets: Codable {
    var cash: Double = 0
    var goldGrams: Double = 0
    var silverGrams: Double = 0
    var tradeGoods: Double = 0
    var receivables: Double = 0 // Alacaklar
    var debts: Double = 0      // Borçlar
    
    // Estimates (can be refined or made adjustable)
    static let goldPricePerGram: Double = 2500.0 // Örnek TL fiyatı
    static let silverPricePerGram: Double = 30.0
    static let nisabGoldGrams: Double = 85.0
    
    var totalValue: Double {
        let goldValue = goldGrams * ZakatAssets.goldPricePerGram
        let silverValue = silverGrams * ZakatAssets.silverPricePerGram
        return cash + goldValue + silverValue + tradeGoods + receivables - debts
    }
    
    var nisabThreshold: Double {
        return ZakatAssets.nisabGoldGrams * ZakatAssets.goldPricePerGram
    }
    
    var isEligible: Bool {
        return totalValue >= nisabThreshold
    }
    
    var zakatDue: Double {
        return isEligible ? (totalValue * 0.025) : 0
    }
}
