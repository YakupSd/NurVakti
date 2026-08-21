import SwiftUI

// MARK: - Arapça + Meal Okuma Görünümü (VIP Beyaz Tema)
struct SurahDetailView: View {
    @StateObject private var vm: QuranViewModel
    let surah: SurahInfo
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.dismiss) var dismiss
    @State private var shareText: String? = nil
    @State private var showCopiedToast: Bool = false
    
    init(surah: SurahInfo, vm: QuranViewModel? = nil) {
        self.surah = surah
        _vm = StateObject(wrappedValue: vm ?? QuranViewModel())
    }
    
    var body: some View {
        ZStack {
            // Background — Ipeksi Krem
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Surah Header Banner
                surahHeader
                
                if vm.isLoadingAyahs {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.nurGold)
                            .scaleEffect(1.3)
                        Text(localization.localizedString("general.loading"))
                            .nurFont(13)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.45))
                    }
                    Spacer()
                } else if let error = vm.ayahLoadError {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.nurGold)
                        Text(localization.localizedString("general.loadFailed"))
                            .nurFont(16, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                        Button(localization.localizedString("general.tryAgain")) {
                            Task {
                                await vm.loadAyahs(surah: surah, language: localization.currentLanguage)
                            }
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                    Spacer()
                } else {
                    // Ayah List
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            // Besmele (Tevbe hariç)
                            if surah.id != 9 {
                                besmeleCard
                            }
                            
                            ForEach(vm.ayahs) { ayah in
                                ayahCard(ayah)
                                    .id(ayah.id)
                            }
                            
                            Color.clear.frame(height: 50)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }
                }
            }
        }
        .task {
            await vm.loadAyahs(surah: surah, language: localization.currentLanguage)
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
    
    // MARK: - Surah Header
    private var surahHeader: some View {
        VStack(spacing: 8) {
            Text(surah.nameArabic)
                .font(.custom("ScheherazadeNew-Bold", size: 32))
                .foregroundColor(Color(hex: "2C1E11"))
            
            HStack(spacing: 10) {
                Text(surah.englishName)
                    .nurFont(15, weight: .bold)
                    .foregroundColor(Color(hex: "1A1A2E"))
                
                Circle()
                    .fill(Color(hex: "1A1A2E").opacity(0.2))
                    .frame(width: 4, height: 4)
                
                Text("\(surah.ayahCount) \(localization.localizedString("quran.ayahs"))")
                    .nurFont(12)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                
                Circle()
                    .fill(Color(hex: "1A1A2E").opacity(0.2))
                    .frame(width: 4, height: 4)
                
                Text(surah.revelationType.localizedName(for: localization.currentLanguage))
                    .nurFont(12)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
            }
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color(hex: "1A1A2E").opacity(0.06))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Besmele Card
    private var besmeleCard: some View {
        VStack(spacing: 0) {
            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(.custom("ScheherazadeNew-Bold", size: 28))
                .foregroundColor(Color(hex: "2C1E11"))
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
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
        VStack(alignment: .trailing, spacing: 14) {
            // Ayah number bar
            HStack {
                // Ayah Number Badge
                ZStack {
                    Circle()
                        .fill(Color.nurGold.opacity(0.12))
                        .frame(width: 32, height: 32)
                    Text("\(ayah.id)")
                        .nurFont(13, weight: .bold, design: .rounded)
                        .foregroundColor(.nurGold)
                }
                
                Spacer()
                
                // Actions (Audio & Bookmark)
                HStack(spacing: 12) {
                    Button(action: {
                        HapticManager.shared.light()
                        let thisAyahID = "ayah_\(surah.id)_\(ayah.id)"
                        if audioManager.isPlaying && audioManager.currentPlayingID == thisAyahID {
                            audioManager.stop()
                        } else {
                            audioManager.play(
                                idType: .ayahID(surah: surah.id, ayah: ayah.id),
                                title: "\(surah.englishName), Ayet \(ayah.id)"
                            )
                        }
                    }) {
                        let thisAyahID = "ayah_\(surah.id)_\(ayah.id)"
                        let isThisPlaying = audioManager.isPlaying && audioManager.currentPlayingID == thisAyahID
                        Image(systemName: isThisPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.nurGold)
                            .frame(width: 32, height: 32)
                            .background(Color.nurGold.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    Button(action: {
                        vm.saveProgress(surah: surah.id, ayah: ayah.id)
                        HapticManager.shared.success()
                    }) {
                        Image(systemName: vm.isBookmarked(surah: surah.id, ayah: ayah.id) ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 13))
                            .foregroundColor(.nurGold)
                            .frame(width: 32, height: 32)
                            .background(Color.nurGold.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    // Copy Button
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
                            .font(.system(size: 13))
                            .foregroundColor(.nurGold)
                            .frame(width: 32, height: 32)
                            .background(Color.nurGold.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    // Share Button
                    Button(action: {
                        HapticManager.shared.light()
                        shareText = formatAyahText(ayah)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 13))
                            .foregroundColor(.nurGold)
                            .frame(width: 32, height: 32)
                            .background(Color.nurGold.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
            
            // Arabic Text
            Text(ayah.arabicText)
                .font(.custom("ScheherazadeNew-Bold", size: 26))
                .lineSpacing(14)
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color(hex: "2C1E11"))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)
            
            // Translation / Meal
            if !ayah.translation.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Divider().opacity(0.06)
                        .padding(.vertical, 4)
                    
                    Text(ayah.translation)
                        .nurFont(14)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.75))
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
    }
    
    // MARK: - Helpers
    private func formatAyahText(_ ayah: AyahItem) -> String {
        var text = "﴿ \(ayah.arabicText) ﴾\n"
        if !ayah.translation.isEmpty {
            text += "\n\(ayah.translation)\n"
        }
        text += "\n— \(surah.englishName), \(ayah.id)"
        text += "\n\n📱 NurVakti"
        return text
    }
}

// MARK: - Share Sheet
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

#Preview {
    SurahDetailView(surah: .fatihaMock)
        .environmentObject(LocalizationManager.shared)
        .environmentObject(AudioManager.shared)
}
