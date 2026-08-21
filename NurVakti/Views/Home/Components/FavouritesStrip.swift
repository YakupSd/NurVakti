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
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.nurGold)
                    
                    Text(loc.localizedString("favourites.title"))
                        .nurFont(12, weight: .bold)
                        .kerning(1.2)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                }
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.light()
                    activeSheet = .library
                }) {
                    Text(loc.localizedString("favourites.edit"))
                        .nurFont(12, weight: .bold)
                        .foregroundColor(.nurGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.nurGold.opacity(0.12))
                        .cornerRadius(10)
                }
                .buttonStyle(BouncyButtonStyle())
            }
            
            if library.favourites.isEmpty {
                // Empty state Inset Card
                Button(action: {
                    HapticManager.shared.light()
                    activeSheet = .library
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.nurGold.opacity(0.12))
                                .frame(width: 38, height: 38)
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.nurGold)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.localizedString("favourites.empty"))
                                .nurFont(14, weight: .semibold)
                                .foregroundColor(Color(hex: "1A1A2E"))
                            
                            Text(loc.localizedString("library.pickFavs"))
                                .nurFont(11)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.3))
                    }
                    .padding(14)
                    .background(Color(hex: "1A1A2E").opacity(0.03))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                    )
                }
                .buttonStyle(CardPressableButtonStyle())
            } else {
                // Horizontal pill scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(library.favourites) { item in
                            FavouritePill(item: item) {
                                activeSheet = .detail(item)
                            }
                        }
                        
                        // + Add more pill
                        Button(action: {
                            HapticManager.shared.light()
                            activeSheet = .library
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                Text(loc.localizedString("favourites.addMore"))
                                    .nurFont(11, weight: .bold)
                            }
                            .foregroundColor(.nurGold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.nurGold.opacity(0.12))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.nurGold.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                    .padding(.vertical, 2)
                }
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

#Preview {
    ZStack {
        Color(hex: "F8F6F0").ignoresSafeArea()
        FavouritesStrip()
            .padding()
            .environmentObject(DuaLibraryService.shared)
            .environmentObject(LocalizationManager.shared)
    }
}
