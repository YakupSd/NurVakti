import SwiftUI

struct FavouritePill: View {
    let item: DuaLibraryItem
    let onTap: () -> Void
    @EnvironmentObject var loc: LocalizationManager
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            onTap()
        }) {
            HStack(spacing: 6) {
                Image(systemName: item.dua.libraryCategory?.icon ?? "star.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(item.dua.libraryCategory?.accentColor ?? .nurGold)
                
                Text(item.dua.title(for: loc.currentLanguage))
                    .nurFont(11, weight: .semibold)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.85))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke((item.dua.libraryCategory?.accentColor ?? .nurGold).opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 4, y: 1)
        }
        .buttonStyle(BouncyButtonStyle())
    }
}

#Preview {
    FavouritePill(
        item: DuaLibraryItem(
            dua: PrayerDua(
                id: "ayat_al_kursi",
                arabicText: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ",
                transliteration: "Allahu la ilaha illa huwal hayyul qayyum",
                titles: ["tr": "Ayetel Kürsi", "en": "Ayat al-Kursi", "ar": "آية الكرسي"],
                meanings: ["tr": "Allah, O'ndan başka ilah yoktur.", "en": "Allah! There is no deity except Him."],
                category: .quranAyah
            ),
            userState: DuaUserState(id: "ayat_al_kursi", isFavourite: true, routineSlot: .morning)
        )
    ) {}
    .environmentObject(LocalizationManager.shared)
    .padding()
    .background(Color(hex: "F8F6F0"))
}
