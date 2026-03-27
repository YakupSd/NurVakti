import SwiftUI

enum SkyPhase: String, CaseIterable {
    case deepNight      = "Deep Night"      // 03:00 – 04:30
    case preDawn        = "Pre-Dawn"        // 04:30 – 05:30
    case dawn           = "Dawn / Fajr"     // 05:30 – 06:30
    case sunrise        = "Sunrise"         // 06:30 – 07:30
    case morning        = "Morning"         // 07:30 – 11:00
    case midday         = "Midday"          // 11:00 – 13:00
    case afternoon      = "Afternoon"       // 13:00 – 15:30
    case lateAfternoon  = "Late Afternoon"  // 15:30 – 17:00
    case sunset         = "Sunset / Maghrib"// 17:00 – 18:30
    case dusk           = "Dusk / Isha"     // 18:30 – 19:30
    case earlyNight     = "Early Night"     // 19:30 – 21:00
    case night          = "Night"           // 21:00 – 03:00

    var startHour: Double {
        switch self {
        case .deepNight:     return 3.0
        case .preDawn:       return 4.5
        case .dawn:          return 5.5
        case .sunrise:       return 6.5
        case .morning:       return 7.5
        case .midday:        return 11.0
        case .afternoon:     return 13.0
        case .lateAfternoon: return 15.5
        case .sunset:        return 17.0
        case .dusk:          return 18.5
        case .earlyNight:    return 19.5
        case .night:         return 21.0
        }
    }

    static func current(for hour: Double) -> (current: SkyPhase, next: SkyPhase, progress: Double) {
        let sortedPhases = SkyPhase.allCases.sorted { $0.startHour < $1.startHour }
        
        // Find current phase based on hour
        var current: SkyPhase = sortedPhases.last!
        var next: SkyPhase = sortedPhases.first!
        
        for i in 0..<sortedPhases.count {
            let phase = sortedPhases[i]
            if hour >= phase.startHour {
                current = phase
                next = sortedPhases[(i + 1) % sortedPhases.count]
            }
        }
        
        // Calculate progress within the phase
        let start = current.startHour
        var end = next.startHour
        
        // Handle night transition wrapping 24h
        var h = hour
        if end < start {
            end += 24.0
            if h < start { h += 24.0 }
        }
        
        let duration = end - start
        let elapsed = h - start
        let progress = max(0, min(1, elapsed / duration))
        
        return (current, next, progress)
    }
}
