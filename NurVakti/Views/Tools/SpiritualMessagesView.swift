import SwiftUI

public struct SpiritualMessagesView: View {
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    @StateObject private var service = SpiritualMessageService.shared
    
    @State private var selectedCategory: SpiritualCategory = .all
    @State private var selectedKandilSub: KandilSubType? = nil
    @State private var selectedBayramSub: BayramSubType? = nil
    @State private var searchQuery: String = ""
    @State private var shareMessage: SpiritualMessage? = nil
    @State private var copiedMessageId: String? = nil
    
    public init(initialCategory: SpiritualCategory = .all, initialKandilSub: KandilSubType? = nil, initialBayramSub: BayramSubType? = nil) {
        _selectedCategory = State(initialValue: initialCategory)
        _selectedKandilSub = State(initialValue: initialKandilSub)
        _selectedBayramSub = State(initialValue: initialBayramSub)
    }
    
    public var body: some View {
        ZStack {
            // Warm ivory background
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── Search & Filter Area ──
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                
                // ── Category Horizontal Tabs ──
                categoryTabs
                    .padding(.bottom, 6)
                
                // ── Sub-Category Filters (if Kandil or Bayram selected) ──
                if selectedCategory == .kandil {
                    kandilSubTabs
                        .padding(.bottom, 8)
                } else if selectedCategory == .bayram {
                    bayramSubTabs
                        .padding(.bottom, 8)
                }
                
                // ── Message List ──
                let messages = currentMessages
                
                if messages.isEmpty {
                    emptyStateView
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            // Featured Hero Card if on 'all' or 'friday' or matching day
                            if searchQuery.isEmpty && selectedCategory == .all {
                                featuredHeroCard(service.todaysFeaturedMessage())
                                    .padding(.horizontal, 16)
                            }
                            
                            ForEach(messages) { msg in
                                SpiritualMessageCardView(
                                    message: msg,
                                    isFavorite: service.isFavorite(messageId: msg.id),
                                    isCopied: copiedMessageId == msg.id,
                                    onCopy: {
                                        copyMessage(msg)
                                    },
                                    onShareText: {
                                        shareTextMessage(msg)
                                    },
                                    onShareStory: {
                                        shareMessage = msg
                                    },
                                    onToggleFavorite: {
                                        service.toggleFavorite(messageId: msg.id)
                                        HapticManager.shared.light()
                                    }
                                )
                                .padding(.horizontal, 16)
                            }
                            
                            Spacer(minLength: 40)
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
        }
        .sheet(item: $shareMessage) { msg in
            SpiritualShareSheet(message: msg)
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.4))
                .font(.system(size: 15))
            
            TextField("Mesajlarda veya dualarda ara...", text: $searchQuery)
                .nurFont(14)
                .foregroundColor(Color(hex: "1A1A2E"))
            
            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.3))
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 4, y: 2)
    }
    
    // MARK: - Category Tabs
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SpiritualCategory.allCases) { cat in
                    let isSelected = selectedCategory == cat
                    Button(action: {
                        HapticManager.shared.selectionChanged()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedCategory = cat
                            if cat != .kandil { selectedKandilSub = nil }
                            if cat != .bayram { selectedBayramSub = nil }
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                            Text(cat.title(for: localization.currentLanguage))
                                .nurFont(13, weight: isSelected ? .bold : .medium)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundColor(isSelected ? Color(hex: "1A1A2E") : Color(hex: "1A1A2E").opacity(0.65))
                        .background(
                            ZStack {
                                if isSelected {
                                    LinearGradient(
                                        colors: [Color.nurGold.opacity(0.25), Color.nurGold.opacity(0.12)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                } else {
                                    Color.white
                                }
                            }
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.nurGold : Color(hex: "1A1A2E").opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
                        )
                        .shadow(color: isSelected ? Color.nurGold.opacity(0.15) : Color.black.opacity(0.02), radius: 4, y: 2)
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Kandil Sub-Tabs
    private var kandilSubTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button(action: {
                    HapticManager.shared.selectionChanged()
                    withAnimation { selectedKandilSub = nil }
                }) {
                    Text("Tümü")
                        .nurFont(12, weight: selectedKandilSub == nil ? .bold : .medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(selectedKandilSub == nil ? .white : Color(hex: "1A1A2E").opacity(0.6))
                        .background(selectedKandilSub == nil ? Color(hex: "1A1A2E") : Color.white)
                        .clipShape(Capsule())
                }
                
                ForEach(KandilSubType.allCases) { sub in
                    let isSelected = selectedKandilSub == sub
                    Button(action: {
                        HapticManager.shared.selectionChanged()
                        withAnimation { selectedKandilSub = sub }
                    }) {
                        Text(sub.title(for: localization.currentLanguage))
                            .nurFont(12, weight: isSelected ? .bold : .medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundColor(isSelected ? .white : Color(hex: "1A1A2E").opacity(0.6))
                            .background(isSelected ? Color.nurGold : Color.white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Bayram Sub-Tabs
    private var bayramSubTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button(action: {
                    HapticManager.shared.selectionChanged()
                    withAnimation { selectedBayramSub = nil }
                }) {
                    Text("Tümü")
                        .nurFont(12, weight: selectedBayramSub == nil ? .bold : .medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(selectedBayramSub == nil ? .white : Color(hex: "1A1A2E").opacity(0.6))
                        .background(selectedBayramSub == nil ? Color(hex: "1A1A2E") : Color.white)
                        .clipShape(Capsule())
                }
                
                ForEach(BayramSubType.allCases) { sub in
                    let isSelected = selectedBayramSub == sub
                    Button(action: {
                        HapticManager.shared.selectionChanged()
                        withAnimation { selectedBayramSub = sub }
                    }) {
                        Text(sub.title(for: localization.currentLanguage))
                            .nurFont(12, weight: isSelected ? .bold : .medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundColor(isSelected ? .white : Color(hex: "1A1A2E").opacity(0.6))
                            .background(isSelected ? Color.nurGold : Color.white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Hero Banner Card
    private func featuredHeroCard(_ msg: SpiritualMessage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.nurGold)
                        .font(.system(size: 13, weight: .bold))
                    Text(service.todaysSpecialBannerTitle ?? "GÜNÜN ÖNE ÇIKAN MESAJI")
                        .nurFont(11, weight: .bold)
                        .foregroundColor(.nurGold)
                        .tracking(1.5)
                }
                
                Spacer()
                
                Button(action: {
                    shareMessage = msg
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 11))
                        Text("Story Paylaş")
                            .nurFont(11, weight: .bold)
                    }
                    .foregroundColor(Color(hex: "#0E1626"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: [Color.nurGold, Color(hex: "E5C158")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                }
            }
            
            Text(msg.title)
                .nurFont(18, weight: .bold)
                .foregroundColor(.white)
            
            if let arabic = msg.arabicText, !arabic.isEmpty {
                Text(arabic)
                    .font(.custom("KFGQPCUthmanicScriptHAFS", size: 17))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(.white.opacity(0.9))
                    .environment(\.layoutDirection, .rightToLeft)
                    .lineSpacing(4)
            }
            
            Text(msg.text)
                .nurFont(13, weight: .regular)
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(4)
            
            if let source = msg.authorOrSource, !source.isEmpty {
                Text("— \(source)")
                    .nurFont(11, weight: .semibold)
                    .foregroundColor(.nurGold.opacity(0.9))
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color(hex: "#0E1626"), Color(hex: "#1A243B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.nurGold.opacity(0.6), Color.nurGold.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color(hex: "#0E1626").opacity(0.2), radius: 12, y: 6)
    }
    
    // MARK: - Current Messages Logic
    private var currentMessages: [SpiritualMessage] {
        let sub = (selectedCategory == .kandil) ? selectedKandilSub?.rawValue : (selectedCategory == .bayram ? selectedBayramSub?.rawValue : nil)
        return service.messages(for: selectedCategory, subCategory: sub, searchQuery: searchQuery)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "heart.slash")
                .font(.system(size: 44))
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.2))
            Text(selectedCategory == .favorites ? "Henüz favori mesajınız bulunmuyor." : "Aramanıza uygun mesaj bulunamadı.")
                .nurFont(15, weight: .medium)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Actions
    private func copyMessage(_ msg: SpiritualMessage) {
        HapticManager.shared.light()
        UIPasteboard.general.string = msg.formattedShareText
        copiedMessageId = msg.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if copiedMessageId == msg.id {
                copiedMessageId = nil
            }
        }
    }
    
    private func shareTextMessage(_ msg: SpiritualMessage) {
        HapticManager.shared.light()
        let av = UIActivityViewController(activityItems: [msg.formattedShareText], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            root.present(av, animated: true)
        }
    }
}

// MARK: - Individual Message Card View
struct SpiritualMessageCardView: View {
    let message: SpiritualMessage
    let isFavorite: Bool
    let isCopied: Bool
    let onCopy: () -> Void
    let onShareText: () -> Void
    let onShareStory: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Category Pill & Favorite
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: message.category.icon)
                        .font(.system(size: 11))
                    Text(message.title.uppercased())
                        .nurFont(11, weight: .bold)
                        .tracking(1)
                }
                .foregroundColor(.nurGold)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.nurGold.opacity(0.12))
                .cornerRadius(8)
                
                Spacer()
                
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 17))
                        .foregroundColor(isFavorite ? Color(hex: "#E0245E") : Color(hex: "1A1A2E").opacity(0.35))
                        .padding(6)
                }
            }
            
            // Arabic Text (if present)
            if let arabic = message.arabicText, !arabic.isEmpty {
                Text(arabic)
                    .font(.custom("KFGQPCUthmanicScriptHAFS", size: 18))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(Color(hex: "1A1A2E"))
                    .environment(\.layoutDirection, .rightToLeft)
                    .lineSpacing(6)
                    .padding(.vertical, 2)
            }
            
            // Main Text
            Text(message.text)
                .nurFont(14, weight: .regular)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.85))
                .lineSpacing(4)
            
            // Source Info
            if let source = message.authorOrSource, !source.isEmpty {
                Text("— \(source)")
                    .nurFont(11, weight: .medium)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                    .italic()
            }
            
            Divider()
                .opacity(0.08)
                .padding(.vertical, 2)
            
            // Action Bar: Kopyala, Metin Paylaş, Story Paylaş
            HStack(spacing: 8) {
                // Copy Button
                Button(action: onCopy) {
                    HStack(spacing: 4) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 11, weight: .bold))
                        Text(isCopied ? "Kopyalandı" : "Kopyala")
                            .nurFont(12, weight: .semibold)
                    }
                    .foregroundColor(isCopied ? Color(hex: "#2D8B56") : Color(hex: "1A1A2E").opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(isCopied ? Color(hex: "#2D8B56").opacity(0.1) : Color(hex: "1A1A2E").opacity(0.05))
                    .cornerRadius(10)
                }
                .buttonStyle(BouncyButtonStyle())
                
                // Text Share Button
                Button(action: onShareText) {
                    HStack(spacing: 4) {
                        Image(systemName: "message")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Metin")
                            .nurFont(12, weight: .medium)
                    }
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color(hex: "1A1A2E").opacity(0.05))
                    .cornerRadius(10)
                }
                .buttonStyle(BouncyButtonStyle())
                
                Spacer()
                
                // Story / Image Share Button
                Button(action: onShareStory) {
                    HStack(spacing: 5) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 12, weight: .bold))
                        Text("Story Oluştur")
                            .nurFont(12, weight: .bold)
                    }
                    .foregroundColor(Color(hex: "1A1A2E"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        LinearGradient(
                            colors: [Color.nurGold, Color(hex: "E5C158")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(10)
                    .shadow(color: Color.nurGold.opacity(0.25), radius: 6, y: 2)
                }
                .buttonStyle(BouncyButtonStyle())
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 4)
    }
}
