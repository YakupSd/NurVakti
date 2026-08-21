import SwiftUI

struct DailyRoutineCard: View {
    let slot: RoutineSlot          // .morning or .evening
    let items: [DuaLibraryItem]
    let completedCount: Int
    @EnvironmentObject var library: DuaLibraryService
    @EnvironmentObject var audio: AudioManager
    @EnvironmentObject var loc: LocalizationManager
    
    var totalCount: Int { items.count }
    var progress: Double { 
        totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0 
    }
    var isComplete: Bool { completedCount == totalCount && totalCount > 0 }
    
    var slotTitle: String {
        slot == .morning 
            ? loc.localizedString("routine.morning")
            : loc.localizedString("routine.evening")
    }
    
    var slotIcon: String { slot == .morning ? "sunrise.fill" : "moon.stars.fill" }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.nurGold.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: slotIcon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.nurGold)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(slotTitle)
                            .nurFont(15, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                        
                        Text(isComplete 
                            ? loc.localizedString("routine.complete")
                            : "\(completedCount)/\(totalCount) " + loc.localizedString("routine.remaining"))
                            .nurFont(11)
                            .foregroundColor(isComplete ? .green : Color(hex: "1A1A2E").opacity(0.5))
                    }
                }
                
                Spacer()
                
                // Progress Badge
                if isComplete {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text(loc.localizedString("routine.complete"))
                            .nurFont(10, weight: .bold)
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    Text("\(completedCount)/\(totalCount)")
                        .nurFont(12, weight: .bold, design: .rounded)
                        .foregroundColor(.nurGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.nurGold.opacity(0.12))
                        .cornerRadius(8)
                }
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(hex: "1A1A2E").opacity(0.06))
                        .frame(height: 5)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.nurGold, Color(hex: "D4AF37")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geo.size.width * CGFloat(progress)), height: 5)
                }
            }
            .frame(height: 5)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
            
            // Dua Rows
            if !items.isEmpty {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        DuaRoutineRow(
                            item: item,
                            onMarkRead: {
                                HapticManager.shared.selectionChanged()
                                library.markAsRead(item)
                            },
                            onPlay: {
                                audio.playPrayerDua(item.dua)
                            }
                        )
                        
                        if item.id != items.last?.id {
                            Divider().opacity(0.06)
                        }
                    }
                }
                .padding(.top, 4)
            } else {
                // Empty routine state
                Button(action: {
                    NotificationCenter.default.post(name: Notification.Name("OpenDuaLibrary"), object: slot)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text(loc.localizedString("routine.addDuas"))
                            .nurFont(12, weight: .semibold)
                    }
                    .foregroundColor(.nurGold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.nurGold.opacity(0.08))
                    .cornerRadius(12)
                }
                .buttonStyle(BouncyButtonStyle())
                .padding(.top, 4)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 3)
        .padding(.horizontal, 14)
    }
}
