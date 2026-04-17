import Foundation

public struct MonthlyAyahPlan {
    // Returns 30 (surah, ayah) pairs for given month
    // Thematically curated by month
    public static func plan(for month: Int) -> [(surah: Int, ayah: Int)] {
        switch month {
        case 1:  return januaryPlan
        case 2:  return februaryPlan
        case 3:  return marchPlan
        case 4:  return aprilPlan
        case 5:  return mayPlan
        case 6:  return junePlan
        case 7:  return julyPlan
        case 8:  return augustPlan
        case 9:  return ramadanPlan
        case 10: return octoberPlan
        case 11: return novemberPlan
        case 12: return decemberPlan
        default: return defaultPlan
        }
    }
    
    private static let januaryPlan: [(Int, Int)] = [
        (2, 186), (2, 255), (3, 173), (39, 53), (94, 5), (107, 1), (112, 1), (113, 1), (114, 1), (1, 1),
        (2, 5), (2, 152), (2, 153), (2, 285), (2, 286), (3, 8), (3, 26), (3, 31), (7, 54), (7, 180),
        (13, 28), (14, 7), (17, 80), (17, 110), (18, 10), (20, 25), (20, 114), (21, 87), (23, 118), (25, 74)
    ]
    
    private static let februaryPlan = defaultPlan
    private static let marchPlan = defaultPlan
    private static let aprilPlan = defaultPlan
    private static let mayPlan = defaultPlan
    private static let junePlan = defaultPlan
    private static let julyPlan = defaultPlan
    private static let augustPlan = defaultPlan
    
    private static let ramadanPlan: [(Int, Int)] = [
        (2, 183), (2, 185), (97, 1), (97, 3), (2, 186), (2, 187), (2, 184), (17, 9), (17, 82), (16, 89),
        (4, 174), (5, 15), (5, 16), (2, 2), (3, 138), (10, 57), (14, 1), (14, 52), (25, 1), (15, 9),
        (54, 17), (73, 4), (29, 45), (3, 191), (3, 192), (3, 193), (3, 194), (17, 78), (17, 79), (44, 3)
    ]
    
    private static let octoberPlan = defaultPlan
    private static let novemberPlan = defaultPlan
    private static let decemberPlan = defaultPlan
    
    private static let defaultPlan: [(Int, Int)] = [
        (1, 1), (2, 255), (2, 285), (2, 286), (3, 190), (3, 191), (18, 10), (33, 56), (36, 1), (36, 83),
        (55, 1), (55, 13), (67, 1), (112, 1), (113, 1), (114, 1), (109, 1), (110, 1), (94, 5), (94, 6),
        (17, 80), (17, 82), (21, 87), (20, 25), (7, 204), (2, 152), (2, 153), (39, 53), (13, 28), (14, 7)
    ]
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
