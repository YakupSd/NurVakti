import SwiftUI

struct DuaLibraryView: View {
    enum LibraryMode {
        case browse
        case pickFavourites
        case pickRoutine(RoutineSlot)
    }
    
    let initialMode: LibraryMode
    @EnvironmentObject var library: DuaLibraryService
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var selectedCategory: LibraryCategory?
    @State private var selectedItem: DuaLibraryItem?
    
    init(initialMode: LibraryMode = .browse) {
        self.initialMode = initialMode
    }
    
    var body: some View {
        ZStack {
            Color.nurDarkBlue.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── Header ──────────────────────
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(loc.localizedString("library.title"))
                            .font(.system(size: 24, weight: .bold))
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.4))
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.2))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // ── Search & Filter ─────────────
                VStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.3))
                        TextField(loc.localizedString("library.searchPlaceholder"), 
                                  text: $searchText)
                            .foregroundColor(Color(hex: "1A1A2E"))
                        if !searchText.isEmpty {
                            Button { searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                            }
                        }
                    }
                    .padding(12)
                    .background(ColorColor(hex: "1A1A2E").opacity(0.06))
                    .cornerRadius(12)
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterPill(title: loc.localizedString("library.all"), 
                                      isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            
                            ForEach(LibraryCategory.allCases, id: \.self) { cat in
                                FilterPill(title: cat.localizedName(for: loc.currentLanguage), 
                                          isSelected: selectedCategory == cat) {
                                    selectedCategory = cat
                                }
                            }
                        }
                    }
                }
                .padding(24)
                
                // ── List ────────────────────────
                ScrollView {
                    LazyVStack(spacing: 1) {
                        let filtered = library.search(searchText, category: selectedCategory)
                        
                        if filtered.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.15))
                                Text(loc.localizedString("library.noResults"))
                                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.3))
                            }
                            .padding(.top, 100)
                        } else {
                            ForEach(filtered) { item in
                                DuaLibraryRow(
                                    item: item, 
                                    mode: initialMode,
                                    onSelect: { selectedItem = item },
                                    onToggleFav: { library.toggleFavourite(item) },
                                    onSetRoutine: { slot in 
                                        library.setRoutineSlot(slot, for: item) 
                                    }
                                )
                                .padding(.horizontal, 16)
                                .background(item.isFavourite ? Color.nurGold.opacity(0.08) : ColorColor(hex: "1A1A2E").opacity(0.02))
                                .cornerRadius(12)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedItem) { item in
            QuickDuaSheet(item: item)
                .presentationDetents([.medium, .large])
        }
    }
    
    private var subtitle: String {
        switch initialMode {
        case .browse: return loc.localizedString("library.subtitle")
        case .pickFavourites: return loc.localizedString("library.pickFavs")
        case .pickRoutine: return loc.localizedString("library.pickRoutine")
        }
    }
}

// ── Supporting Components ───────────────────

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .black : Color(hex: "1A1A2E").opacity(0.5))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.nurGold : ColorColor(hex: "1A1A2E").opacity(0.06))
                .cornerRadius(20)
        }
    }
}

struct DuaLibraryRow: View {
    let item: DuaLibraryItem
    let mode: DuaLibraryView.LibraryMode
    let onSelect: () -> Void
    let onToggleFav: () -> Void
    let onSetRoutine: (RoutineSlot) -> Void
    @EnvironmentObject var loc: LocalizationManager
    
    var body: some View {
        HStack(spacing: 15) {
            // Category Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill((item.dua.libraryCategory?.accentColor ?? .nurGold).opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: item.dua.libraryCategory?.icon ?? "book.fill")
                    .foregroundColor(item.dua.libraryCategory?.accentColor ?? .nurGold)
                
                if item.isFavourite {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.nurGold)
                        .padding(2)
                        .background(Color.nurDarkBlue)
                        .clipShape(Circle())
                        .offset(x: 16, y: -16)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.dua.title(for: loc.currentLanguage))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(item.isFavourite ? .nurGold : .white)
                Text(item.dua.libraryCategory?.localizedName(for: loc.currentLanguage) ?? "")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.4))
            }
            
            Spacer()
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { onSelect() }
            
            // Context Actions based on Mode
            HStack(spacing: 12) {
                // Routine Selector (Menu)
                Menu {
                    Button(loc.localizedString("routine.none")) { onSetRoutine(.none) }
                    Button(loc.localizedString("routine.morning")) { onSetRoutine(.morning) }
                    Button(loc.localizedString("routine.evening")) { onSetRoutine(.evening) }
                    Button(loc.localizedString("routine.both")) { onSetRoutine(.both) }
                } label: {
                    Image(systemName: item.userState.routineSlot == .none ? "checklist" : "checklist.checked")
                        .foregroundColor(item.userState.routineSlot == .none ? Color(hex: "1A1A2E").opacity(0.2) : .nurGold)
                }

                // Favourite Star
                Button(action: onToggleFav) {
                    Image(systemName: item.isFavourite ? "star.fill" : "star")
                        .foregroundColor(item.isFavourite ? .nurGold : Color(hex: "1A1A2E").opacity(0.2))
                }
            }
            .font(.system(size: 18))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(item.isFavourite ? Color.nurGold.opacity(0.12) : ColorColor(hex: "1A1A2E").opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(item.isFavourite ? Color.nurGold.opacity(0.5) : Color.clear, lineWidth: 1.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}
