import SwiftUI

struct QuranView: View {
    @StateObject var vm = QuranViewModel()
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    
    @State private var selectedSurahForSheet: SurahInfo? = nil
    
    var body: some View {
        ZStack {
            // Background — Beyaz / Krem Tema
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ÜSTBAR (Header)
                VStack(spacing: 16) {
                    HStack {
                        Text(localization.localizedString("menu_quran"))
                            .nurFont(32, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Arama Çubuğu
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.35))
                        TextField(localization.localizedString("quran.searchPlaceholder"), text: $vm.searchText)
                            .textFieldStyle(.plain)
                            .foregroundColor(Color(hex: "1A1A2E"))
                    }
                    .padding(14)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Hatim Banner
                        SectionHeader(title: localization.localizedString("quran.hatimJourney"))
                        
                        Button {
                            HapticManager.shared.tap()
                            let page = vm.hatimProgress?.currentPage ?? 1
                            router.pushTo(view: MainNavigationView.builder.makeView(
                                MushafMainView(page: page),
                                withNavigationTitle: "Mushaf"
                            ))
                        } label: {
                            VStack(spacing: 20) {
                                let page = vm.hatimProgress?.currentPage ?? 1
                                HStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "C9A84C").opacity(0.15))
                                            .frame(width: 80, height: 80)
                                        
                                        VStack(spacing: 0) {
                                            Text("\(page)")
                                                .nurFont(28, weight: .bold)
                                                .foregroundColor(Color(hex: "C9A84C"))
                                            Text(localization.localizedString("quran.pageLabel"))
                                                .nurFont(10)
                                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.4))
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(localization.localizedString("quran.hatimJourney"))
                                            .nurFont(18, weight: .bold)
                                            .foregroundColor(Color(hex: "1A1A2E"))
                                        
                                        ProgressView(value: Double(page), total: 604)
                                            .tint(Color(hex: "C9A84C"))
                                            .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                        
                                        Text(page == 1 ? localization.localizedString("quran.startFromFirst") : localization.localizedString("quran.continueWhereLeft"))
                                            .nurFont(12, weight: .medium)
                                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.title3)
                                        .foregroundColor(Color(hex: "C9A84C").opacity(0.5))
                                }
                            }
                            .padding(24)
                            .background(Color.white)
                            .cornerRadius(24)
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        
                        if let progress = vm.readingProgress,
                           let surah = vm.surahs.first(where: { $0.id == progress.lastSurah }) {
                            SectionHeader(title: localization.localizedString("quran.lastRead"))
                            
                            Button {
                                selectedSurahForSheet = surah
                            } label: {
                                HStack {
                                    Image(systemName: "book.fill")
                                        .foregroundColor(Color(hex: "C9A84C"))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(localization.localizedString("quran.surahLabel")) \(progress.lastSurah), \(localization.localizedString("quran.ayahLabel")) \(progress.lastAyah)")
                                            .nurFont(16, weight: .bold)
                                            .foregroundColor(Color(hex: "1A1A2E"))
                                        Text(localization.localizedString("quran.goToLastAyah"))
                                            .nurFont(12)
                                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(hex: "C9A84C"))
                                }
                                .padding(18)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        SectionHeader(title: localization.localizedString("quran.surahsTitle"))
                        
                        // Sure Listesi
                        LazyVStack(spacing: 12) {
                            if vm.isLoading {
                                ProgressView()
                                    .tint(Color(hex: "C9A84C"))
                                    .padding(40)
                            } else if let error = vm.loadError {
                                ErrorStateView(error: error, language: localization.currentLanguage) {
                                    Task { await vm.loadSurahList() }
                                }
                                .padding(.top, 40)
                            } else if vm.filteredSurahs.isEmpty && !vm.searchText.isEmpty {
                                EmptyStateView(type: .quranSearchNoResults, language: localization.currentLanguage)
                                    .padding(.top, 40)
                            } else {
                                ForEach(vm.filteredSurahs) { surah in
                                    Button {
                                        selectedSurahForSheet = surah
                                    } label: {
                                        SurahRowView(surah: surah, language: localization.currentLanguage, fontSize: .medium)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await vm.loadSurahList()
        }
        // Okuma Modu Seçim Sheet'i
        .sheet(item: $selectedSurahForSheet) { surah in
            readingModeSheet(for: surah)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }
    
    // MARK: - Okuma Modu Seçim Sheet
    @ViewBuilder
    private func readingModeSheet(for surah: SurahInfo) -> some View {
        ZStack {
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Surah info
                VStack(spacing: 8) {
                    Text(surah.nameArabic)
                        .font(.custom("ScheherazadeNew-Bold", size: 30))
                        .foregroundColor(Color(hex: "C9A84C"))
                    
                    Text(surah.englishName)
                        .nurFont(16, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E"))
                }
                .padding(.top, 20)
                
                // Mod seçimi
                VStack(spacing: 12) {
                    // Arapça + Meal (Varsayılan)
                    Button {
                        selectedSurahForSheet = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            router.pushTo(view: MainNavigationView.builder.makeView(
                                SurahDetailView(surah: surah),
                                withNavigationTitle: surah.englishName
                            ))
                        }
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "text.book.closed.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "C9A84C"))
                                .frame(width: 44, height: 44)
                                .background(Color(hex: "C9A84C").opacity(0.12))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Arapça + Meal")
                                    .nurFont(16, weight: .bold)
                                    .foregroundColor(Color(hex: "1A1A2E"))
                                Text("Ayet ayet okuma ve meal takibi")
                                    .nurFont(12)
                                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                            }
                            
                            Spacer()
                            
                            Text("Önerilen")
                                .nurFont(10, weight: .bold)
                                .foregroundColor(Color(hex: "C9A84C"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: "C9A84C").opacity(0.12))
                                .cornerRadius(12)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.3))
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "C9A84C").opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Mushaf Modu
                    Button {
                        selectedSurahForSheet = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            router.pushTo(view: MainNavigationView.builder.makeView(
                                MushafMainView(surah: surah),
                                withNavigationTitle: surah.englishName
                            ))
                        }
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "book.pages.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                                .frame(width: 44, height: 44)
                                .background(Color(hex: "1A1A2E").opacity(0.05))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mushaf")
                                    .nurFont(16, weight: .bold)
                                    .foregroundColor(Color(hex: "1A1A2E"))
                                Text("Geleneksel sayfa görünümü")
                                    .nurFont(12)
                                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.3))
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

struct SurahRowView: View {
    let surah: SurahInfo
    let language: LanguageCode
    let fontSize: FontSize
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "C9A84C").opacity(0.1))
                    .frame(width: 40, height: 40)
                Text("\(surah.id)")
                    .nurFont(14, weight: .bold)
                    .foregroundColor(Color(hex: "C9A84C"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(surah.englishName)
                    .nurFont(18, weight: .bold)
                    .foregroundColor(Color(hex: "1A1A2E"))
                
                HStack(spacing: 8) {
                    Text("\(surah.ayahCount) \(localization.localizedString("quran.ayahs"))")
                    Circle().frame(width: 4, height: 4)
                    Text(surah.revelationType.localizedName(for: language))
                }
                .nurFont(12)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.45))
            }
            
            Spacer()
            
            Text(surah.nameArabic)
                .font(.custom("ScheherazadeNew-Regular", size: 22))
                .foregroundColor(Color(hex: "2C1E11"))
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        QuranView()
            .environmentObject(LocalizationManager.shared)
    }
}
