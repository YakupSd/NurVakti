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
            ? loc.localizedString("routine.morning")   // "Sabah Rutini"
            : loc.localizedString("routine.evening")   // "Akşam Rutini"
    }
    
    var slotIcon: String { slot == .morning ? "sunrise.fill" : "moon.stars.fill" }
    
    var body: some View {
        NurCard(icon: slotIcon, iconColor: .nurGold) {
            VStack(spacing: 0) {
                // ── Header ──────────────────────
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(slotTitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "1A1A2E"))
                        Text(isComplete 
                            ? loc.localizedString("routine.complete")
                            : "\(completedCount)/\(totalCount) " + 
                              loc.localizedString("routine.remaining"))
                            .font(.system(size: 10))
                            .foregroundColor(isComplete ? .green : Color(hex: "1A1A2E").opacity(0.4))
                    }
                    Spacer()
                    // Completion badge
                    if isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 18))
                    } else {
                        Text("\(completedCount)/\(totalCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.nurGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.nurGold.opacity(0.15))
                            .cornerRadius(6)
                    }
                }
                .padding(.bottom, 8)
                
                // ── Progress bar ────────────────
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(ColorColor(hex: "1A1A2E").opacity(0.08))
                        Capsule()
                            .fill(LinearGradient(
                                colors: [.nurGold, Color(hex:"#FFD700")],
                                startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 3)
                .padding(.bottom, 10)
                .animation(.easeInOut(duration: 0.4), value: progress)
                
                // ── Dua rows ────────────────────
                ForEach(items) { item in
                    DuaRoutineRow(
                        item: item,
                        onMarkRead: { library.markAsRead(item) },
                        onPlay: { 
                            audio.playPrayerDua(item.dua)
                        }
                    )
                    if item.id != items.last?.id {
                        Divider().opacity(0.08)
                    }
                }
                
                // ── Edit routine link ────────────
                if items.isEmpty {
                    Button {
                        // Navigate to DuaLibraryView
                        NotificationCenter.default.post(
                            name: Notification.Name("OpenDuaLibrary"), 
                            object: slot)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 11))
                            Text(loc.localizedString("routine.addDuas"))
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.nurGold.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                }
            }
        }
    }
}
