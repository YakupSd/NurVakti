import SwiftUI

struct DuaRoutineRow: View {
    let item: DuaLibraryItem
    let onMarkRead: () -> Void
    let onPlay: () -> Void
    @EnvironmentObject var audio: AudioManager
    
    var isPlaying: Bool { audio.isPlaying }
    
    var body: some View {
        HStack(spacing: 10) {
            // Check circle
            Button(action: onMarkRead) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            item.userState.isReadToday 
                                ? Color.green 
                                : Color.nurGold.opacity(0.4), 
                            lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if item.userState.isReadToday {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
            .buttonStyle(.plain)
            
            // Dua info
            VStack(alignment: .leading, spacing: 2) {
                Text(item.dua.title(for: .tr))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(
                        item.userState.isReadToday 
                            ? .white.opacity(0.4) 
                            : .white.opacity(0.85))
                Text(item.dua.arabicText.prefix(30) + "...")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.3))
                    .environment(\.layoutDirection, .rightToLeft)
            }
            
            Spacer()
            
            // Play button
            Button(action: onPlay) {
                ZStack {
                    Circle()
                        .fill(isPlaying 
                            ? Color.nurGold.opacity(0.25) 
                            : Color.nurGold.opacity(0.1))
                        .frame(width: 28, height: 28)
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.nurGold)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
