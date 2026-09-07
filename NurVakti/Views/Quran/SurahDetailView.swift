import SwiftUI

// MARK: - Ultra-Smooth Surah Reader View (VIP Gold & Ivory Theme)
struct SurahDetailView: View {
    @StateObject private var vm: QuranViewModel
    @State private var currentSurah: SurahInfo
    
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var router: AppRouter
    @Environment(\.dismiss) var dismiss
    
    @State private var shareText: String? = nil
    @State private var showCopiedToast: Bool = false
    @State private var arabicFontSize: CGFloat = 26
    @State private var readingMode: QuranReadingMode = .withTranslation
    @State private var isMushafMode: Bool = false
    
    init(surah: SurahInfo, vm: QuranViewModel? = nil) {
        _currentSurah = State(initialValue: surah)
        let resolvedVM = vm ?? QuranViewModel.shared
        _vm = StateObject(wrappedValue: resolvedVM)
    }
    
    var body: some View {
        ZStack {
            // Background — Silk Ivory / Cream
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Top Control Bar (Surah Title, Font Size & Mode Switcher)
                surahTopBar
                
                // 2. Main Content
                if isMushafMode {
                    MushafMainView(surah: currentSurah)
                } else if vm.isLoadingAyahs && vm.ayahs.isEmpty {
                    loadingView
                } else if let error = vm.ayahLoadError, vm.ayahs.isEmpty {
                    errorView(error)
                } else {
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                Color.clear.frame(height: 1).id("top_anchor")
                                
                                // Besmele (Tevbe / 9. Sure hariç)
                                if currentSurah.id != 9 {
                                    besmeleCard
                                }
                                
                                // Ayah List
                                ForEach(vm.ayahs) { ayah in
                                    ayahCard(ayah)
                                        .id(ayah.id)
                                }
                                
                                // Bottom Next / Previous Surah Bar
                                bottomSurahNavigationBar(proxy: proxy)
                                
                                Color.clear.frame(height: 40)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                        }
                    }
                }
            }
        }
        .task(id: currentSurah.id) {
            await vm.loadAyahs(surah: currentSurah, language: localization.currentLanguage)
        }
        .sheet(item: Binding(
            get: { shareText.map { ShareTextWrapper(text: $0) } },
            set: { if $0 == nil { shareText = nil } }
        )) { wrapper in
            ShareSheet(items: [wrapper.text])
        }
        .overlay(alignment: .bottom) {
            if showCopiedToast {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text(localization.localizedString("general.copied"))
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.nurGold)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 30)
            }
        }
        .animation(.spring(response: 0.35), value: showCopiedToast)
    }
    
    // MARK: - Top Header & Control Bar
    private var surahTopBar: some View {
        VStack(spacing: 8) {
            // Main info row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(currentSurah.nameArabic)
                            .font(.custom("ScheherazadeNew-Bold", size: 26))
                            .foregroundColor(Color(hex: "2C1E11"))
                        
                        Text("(\(currentSurah.id). Sure)")
                            .nurFont(12, weight: .semibold)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                    }
                    
                    HStack(spacing: 6) {
                        Text(currentSurah.englishName)
                            .nurFont(13, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                        
                        Text("·")
                            .foregroundColor(.gray)
                        
                        Text("\(currentSurah.ayahCount) \(localization.localizedString("quran.ayahs"))")
                            .nurFont(12)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                        
                        Text("·")
                            .foregroundColor(.gray)
                        
                        Text(currentSurah.revelationType.localizedName(for: localization.currentLanguage))
                            .nurFont(12)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                    }
                }
                
                Spacer()
                
                // Font Size & Mode Controls
                HStack(spacing: 6) {
                    // Font Size Adjuster
                    Button(action: {
                        HapticManager.shared.light()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            arabicFontSize = (arabicFontSize >= 34) ? 22 : arabicFontSize + 4
                        }
                    }) {
                        HStack(spacing: 2) {
                            Image(systemName: "textformat.size")
                                .font(.system(size: 13, weight: .semibold))
                            Text("\(Int(arabicFontSize))")
                                .nurFont(11, weight: .bold)
                        }
                        .foregroundColor(Color(hex: "1A1A2E"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(hex: "1A1A2E").opacity(0.06))
                        .clipShape(Capsule())
                    }
                    
                    // Translation Toggle
                    Button(action: {
                        HapticManager.shared.light()
                        withAnimation(.easeInOut(duration: 0.25)) {
                            readingMode = (readingMode == .withTranslation) ? .arabicOnly : .withTranslation
                        }
                    }) {
                        Text(readingMode == .withTranslation ? "Meal Açık" : "Sadece Arapça")
                            .nurFont(11, weight: .bold)
                            .foregroundColor(readingMode == .withTranslation ? .nurGold : Color(hex: "1A1A2E").opacity(0.7))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(readingMode == .withTranslation ? Color.nurGold.opacity(0.12) : Color(hex: "1A1A2E").opacity(0.06))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color(hex: "1A1A2E").opacity(0.06))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Loading & Error States
    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .tint(.nurGold)
                .scaleEffect(1.3)
            Text(localization.localizedString("general.loading"))
                .nurFont(13)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.45))
            Spacer()
        }
    }
    
    private func errorView(_ error: NurError) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundColor(.nurGold)
            Text(localization.localizedString("general.loadFailed"))
                .nurFont(16, weight: .bold)
                .foregroundColor(Color(hex: "1A1A2E"))
            Button(localization.localizedString("general.tryAgain")) {
                Task {
                    await vm.loadAyahs(surah: currentSurah, language: localization.currentLanguage)
                }
            }
            .buttonStyle(BouncyButtonStyle())
            Spacer()
        }
    }
    
    // MARK: - Besmele Card
    private var besmeleCard: some View {
        VStack(spacing: 0) {
            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(.custom("ScheherazadeNew-Bold", size: arabicFontSize + 2))
                .foregroundColor(Color(hex: "2C1E11"))
                .multilineTextAlignment(.center)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
        }
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
    }
    
    // MARK: - Ayah Card
    private func ayahCard(_ ayah: AyahItem) -> some View {
        let isAudioPlaying = audioManager.isPlaying && audioManager.currentPlayingID == "ayah_\(currentSurah.id)_\(ayah.id)"
        let isBookmarked = vm.isBookmarked(surah: currentSurah.id, ayah: ayah.id)
        
        return VStack(alignment: .trailing, spacing: 14) {
            // Ayah number & Action bar
            HStack {
                // Number badge
                ZStack {
                    Circle()
                        .fill(Color.nurGold.opacity(0.12))
                        .frame(width: 30, height: 30)
                    Text("\(ayah.id)")
                        .nurFont(12, weight: .bold, design: .rounded)
                        .foregroundColor(.nurGold)
                }
                
                Spacer()
                
                // Actions (Audio, Bookmark, Copy, Share)
                HStack(spacing: 8) {
                    // Audio Play
                    Button(action: {
                        HapticManager.shared.light()
                        let thisAyahID = "ayah_\(currentSurah.id)_\(ayah.id)"
                        if isAudioPlaying {
                            audioManager.stop()
                        } else {
                            audioManager.play(
                                idType: .ayahID(surah: currentSurah.id, ayah: ayah.id),
                                title: "\(currentSurah.englishName), Ayet \(ayah.id)"
                            )
                        }
                    }) {
                        Image(systemName: isAudioPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 12))
                            .foregroundColor(isAudioPlaying ? .white : .nurGold)
                            .frame(width: 28, height: 28)
                            .background(isAudioPlaying ? Color.nurGold : Color.nurGold.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    // Bookmark
                    Button(action: {
                        vm.saveProgress(surah: currentSurah.id, ayah: ayah.id)
                        HapticManager.shared.success()
                    }) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 12))
                            .foregroundColor(.nurGold)
                            .frame(width: 28, height: 28)
                            .background(Color.nurGold.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    // Copy
                    Button(action: {
                        let text = formatAyahText(ayah)
                        UIPasteboard.general.string = text
                        HapticManager.shared.success()
                        showCopiedToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showCopiedToast = false
                        }
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12))
                            .foregroundColor(.nurGold)
                            .frame(width: 28, height: 28)
                            .background(Color.nurGold.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    // Share
                    Button(action: {
                        HapticManager.shared.light()
                        shareText = formatAyahText(ayah)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 12))
                            .foregroundColor(.nurGold)
                            .frame(width: 28, height: 28)
                            .background(Color.nurGold.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
            
            // Arabic Text
            Text(ayah.arabicText)
                .font(.custom("ScheherazadeNew-Bold", size: arabicFontSize))
                .lineSpacing(12)
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color(hex: "2C1E11"))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)
            
            // Translation / Meal
            if readingMode == .withTranslation && !ayah.translation.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Divider().opacity(0.06)
                        .padding(.vertical, 2)
                    
                    Text(ayah.translation)
                        .nurFont(14)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.8))
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isAudioPlaying ? Color.nurGold : Color(hex: "1A1A2E").opacity(0.06), lineWidth: isAudioPlaying ? 1.5 : 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
    }
    
    // MARK: - Bottom Surah Navigation Bar
    private func bottomSurahNavigationBar(proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 12) {
            // Previous Surah
            if let prev = vm.previousSurah(before: currentSurah) {
                Button(action: {
                    HapticManager.shared.selectionChanged()
                    currentSurah = prev
                    withAnimation {
                        proxy.scrollTo("top_anchor", anchor: .top)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .bold))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Önceki Sure")
                                .nurFont(10)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                            Text(prev.englishName)
                                .nurFont(13, weight: .bold)
                                .foregroundColor(Color(hex: "1A1A2E"))
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
                }
                .buttonStyle(BouncyButtonStyle())
            }
            
            Spacer()
            
            // Next Surah
            if let next = vm.nextSurah(after: currentSurah) {
                Button(action: {
                    HapticManager.shared.selectionChanged()
                    currentSurah = next
                    withAnimation {
                        proxy.scrollTo("top_anchor", anchor: .top)
                    }
                }) {
                    HStack(spacing: 6) {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("Sonraki Sure")
                                .nurFont(10)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                            Text(next.englishName)
                                .nurFont(13, weight: .bold)
                                .foregroundColor(.nurGold)
                        }
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.nurGold)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.nurGold.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.nurGold.opacity(0.12), radius: 6, y: 2)
                }
                .buttonStyle(BouncyButtonStyle())
            }
        }
        .padding(.top, 14)
    }
    
    // MARK: - Helpers
    private func formatAyahText(_ ayah: AyahItem) -> String {
        var text = "﴿ \(ayah.arabicText) ﴾\n"
        if !ayah.translation.isEmpty {
            text += "\n\(ayah.translation)\n"
        }
        text += "\n— \(currentSurah.englishName), \(ayah.id)"
        text += "\n\n📱 NurVakti"
        return text
    }
}

// MARK: - Share Helpers
struct ShareTextWrapper: Identifiable {
    let id = UUID()
    let text: String
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

