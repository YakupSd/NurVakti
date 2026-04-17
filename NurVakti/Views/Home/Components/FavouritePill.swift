import SwiftUI

struct FavouritePill: View {
    let item: DuaLibraryItem
    let onTap: () -> Void
    @EnvironmentObject var loc: LocalizationManager
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            HStack(spacing: 5) {
                Image(systemName: item.dua.libraryCategory?.icon ?? "star")
                    .font(.system(size: 10))
                    .foregroundColor(item.dua.libraryCategory?.accentColor ?? .nurGold)
                Text(item.dua.title(for: loc.currentLanguage))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background((item.dua.libraryCategory?.accentColor ?? .nurGold).opacity(0.1))
            .cornerRadius(20)
            .contentShape(Capsule()) 
            .overlay(
                Capsule()
                    .strokeBorder((item.dua.libraryCategory?.accentColor ?? .nurGold).opacity(0.25), 
                                  lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
