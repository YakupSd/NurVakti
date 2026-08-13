import SwiftUI

// MARK: - Arapça + Meal Okuma Görünümü (Beyaz Tema)
struct SurahDetailView: View {
    @StateObject private var vm: QuranViewModel
    let surah: SurahInfo
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.dismiss) var dismiss
    
    init(surah: SurahInfo, vm: QuranViewModel? = nil) {
        self.surah = surah
        _vm = StateObject(wrappedValue: vm ?? QuranViewModel())
    }
    
    var body: some View {
        ZStack {
            // Background — Beyaz/Krem
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Surah Header
                surahHeader
                
                if vm.isLoadingAyahs {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(Color(hex: "C9A84C"))
                            .scaleEffect(1.5)
                        Text("Yükleniyor...")
                            .nurFont(14)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.4))
                    }
                    Spacer()
                } else if let error = vm.ayahLoadError {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "C9A84C"))
                        Text("Yüklenemedi")
                            .nurFont(18, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                        Button("Tekrar Dene") {
                            Task {
                                await vm.loadAyahs(surah: surah, language: localization.currentLanguage)
                            }
                        }
                        .nurFont(14, weight: .bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color(hex: "C9A84C"))
                        .cornerRadius(20)
                    }
                    Spacer()
                } else {
                    // Ayah List
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            // Besmele (Tevbe hariç)
                            if surah.id != 9 {
                                besmeleCard
                            }
                            
                            ForEach(vm.ayahs) { ayah in
                                ayahCard(ayah)
                                    .id(ayah.id)
                            }
                            
                            Color.clear.frame(height: 40)
                        }
                    }
                }
            }
        }
        .task {
            await vm.loadAyahs(surah: surah, language: localization.currentLanguage)
        }
    }
    
    // MARK: - Surah Header
    private var surahHeader: some View {
        VStack(spacing: 12) {
            // Arabic name
            Text(surah.nameArabic)
                .font(.custom("ScheherazadeNew-Bold", size: 36))
                .foregroundColor(Color(hex: "C9A84C"))
            
            // English name + info
            HStack(spacing: 12) {
                Text(surah.englishName)
                    .nurFont(16, weight: .bold)
                    .foregroundColor(Color(hex: "1A1A2E"))
                
                Text("•")
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.2))
                
                Text("\(surah.ayahCount) \(localization.localizedString("quran.ayahs"))")
                    .nurFont(12)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.45))
                
                Text("•")
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.2))
                
                Text(surah.revelationType.localizedName(for: localization.currentLanguage))
                    .nurFont(12)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.45))
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Besmele Card
    private var besmeleCard: some View {
        VStack(spacing: 0) {
            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(.custom("ScheherazadeNew-Bold", size: 32))
                .foregroundColor(Color(hex: "2C1E11"))
                .multilineTextAlignment(.center)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
            
            Rectangle()
                .fill(Color(hex: "1A1A2E").opacity(0.06))
                .frame(height: 1)
        }
    }
    
    // MARK: - Ayah Card
    private func ayahCard(_ ayah: AyahItem) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .trailing, spacing: 16) {
                // Ayah number bar
                HStack {
                    // Ayah Number Badge
                    ZStack {
                        Circle()
                            .fill(Color(hex: "C9A84C").opacity(0.1))
                            .frame(width: 36, height: 36)
                        Text("\(ayah.id)")
                            .nurFont(14, weight: .bold)
                            .foregroundColor(Color(hex: "C9A84C"))
                    }
                    
                    Spacer()
                    
                    // Actions
                    HStack(spacing: 16) {
                        // Play audio
                        Button {
                            if audioManager.isPlaying {
                                audioManager.stop()
                            } else {
                                audioManager.play(
                                    idType: .ayahID(surah: surah.id, ayah: ayah.id),
                                    title: "\(surah.englishName), Ayet \(ayah.id)"
                                )
                            }
                        } label: {
                            Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "C9A84C"))
                                .frame(width: 32, height: 32)
                                .background(Color(hex: "C9A84C").opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        // Bookmark
                        Button {
                            vm.saveProgress(surah: surah.id, ayah: ayah.id)
                            HapticManager.shared.success()
                        } label: {
                            Image(systemName: vm.isBookmarked(surah: surah.id, ayah: ayah.id) ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "C9A84C").opacity(0.7))
                                .frame(width: 32, height: 32)
                                .background(Color(hex: "C9A84C").opacity(0.05))
                                .clipShape(Circle())
                        }
                    }
                }
                
                // Arabic Text
                Text(ayah.arabicText)
                    .font(.custom("ScheherazadeNew-Bold", size: 28))
                    .lineSpacing(16)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(Color(hex: "2C1E11"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .environment(\.layoutDirection, .rightToLeft)
                
                // Translation / Meal
                if !ayah.translation.isEmpty {
                    Text(ayah.translation)
                        .nurFont(15)
                        .lineSpacing(8)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(20)
            
            // Separator
            Rectangle()
                .fill(Color(hex: "1A1A2E").opacity(0.06))
                .frame(height: 1)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    SurahDetailView(surah: SurahInfo(
        id: 1,
        nameArabic: "الفاتحة",
        nameLocalized: [.tr: "Fatiha"],
        englishName: "Al-Fatihah",
        ayahCount: 7,
        revelationType: .makkah
    ))
    .environmentObject(LocalizationManager.shared)
    .environmentObject(AudioManager.shared)
}
