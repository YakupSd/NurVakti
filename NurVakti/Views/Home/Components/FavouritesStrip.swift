import SwiftUI

struct FavouritesStrip: View {
    @EnvironmentObject var library: DuaLibraryService
    @EnvironmentObject var loc: LocalizationManager
    @State private var activeSheet: FavouritesSheet?
    
    enum FavouritesSheet: Identifiable {
        case detail(DuaLibraryItem)
        case library
        
        var id: String {
            switch self {
            case .detail(let item): return "detail-\(item.id)"
            case .library: return "library"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                Text(loc.localizedString("favourites.title"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "1A1A2E"))
                    .shadow(color: .black.opacity(0.5), radius: 4)
                    .tracking(1.5)
                    .textCase(.uppercase)
                
                Spacer()
                
                Button(action: { activeSheet = .library }) {
                    Text(loc.localizedString("favourites.edit"))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.nurGold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.nurGold.opacity(0.15))
                        .cornerRadius(10)
                }
            }
            .padding(.bottom, 4)
            
            if library.favourites.isEmpty {
                // Empty state
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.nurGold)
                    Text(loc.localizedString("favourites.empty"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "1A1A2E"))
                        .shadow(color: .black.opacity(0.5), radius: 4)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                // Horizontal pill scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(library.favourites) { item in
                            FavouritePill(item: item) {
                                activeSheet = .detail(item)
                            }
                        }
                        // + Add more pill
                        Button {
                            activeSheet = .library
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11))
                                Text(loc.localizedString("favourites.addMore"))
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.8))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(ColorColor(hex: "1A1A2E").opacity(0.1))
                            .cornerRadius(20)
                            .overlay(
                                Capsule()
                                    .strokeBorder(ColorColor(hex: "1A1A2E").opacity(0.2), 
                                                  lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 2)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(ColorColor(hex: "1A1A2E").opacity(0.12), lineWidth: 1)
        )
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .detail(let item):
                QuickDuaSheet(item: item)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            case .library:
                DuaLibraryView(initialMode: .pickFavourites)
                    .presentationDetents([.large])
            }
        }
    }
}
