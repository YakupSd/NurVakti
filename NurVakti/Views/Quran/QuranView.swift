import SwiftUI

struct QuranView: View {
    @StateObject var vm = QuranViewModel()
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0B132B"),
                    Color(hex: "1C2541"),
                    Color(hex: "000000")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Premium Light Orbs
            Circle()
                .fill(Color.nurGold.opacity(0.12))
                .frame(width: 400, height: 400)
                .offset(x: -150, y: -200)
                .blur(radius: 100)
            
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 300)
                .blur(radius: 80)
            
            VStack(spacing: 0) {
                // ÜSTBAR (Header)
                VStack(spacing: 16) {
                    HStack {
                        Text(localization.localizedString("menu_quran"))
                            .nurFont(32, weight: .bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Arama Çubuğu (Premium Glass)
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.4))
                        TextField(localization.localizedString("quran.searchPlaceholder"), text: $vm.searchText)
                            .textFieldStyle(.plain)
                            .foregroundColor(.white)
                    }
                    .padding(14)
                    .background(.ultraThinMaterial.opacity(0.15))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
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
                                            .fill(Color.nurGold.opacity(0.1))
                                            .frame(width: 80, height: 80)
                                            .blur(radius: 10)
                                        
                                        VStack(spacing: 0) {
                                            Text("\(page)")
                                                .nurFont(28, weight: .bold)
                                                .foregroundColor(.nurGold)
                                            Text(localization.localizedString("quran.pageLabel"))
                                                .nurFont(10)
                                                .foregroundColor(.white.opacity(0.4))
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(localization.localizedString("quran.hatimJourney"))
                                            .nurFont(18, weight: .bold)
                                            .foregroundColor(.white)
                                        
                                        ProgressView(value: Double(page), total: 604)
                                            .tint(.nurGold)
                                            .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                        
                                        Text(page == 1 ? localization.localizedString("quran.startFromFirst") : localization.localizedString("quran.continueWhereLeft"))
                                            .nurFont(12, weight: .medium)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.title3)
                                        .foregroundColor(.nurGold.opacity(0.5))
                                }
                            }
                            .padding(24)
                            .background(.ultraThinMaterial.opacity(0.15))
                            .cornerRadius(24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        if let progress = vm.readingProgress,
                           let surah = vm.surahs.first(where: { $0.id == progress.lastSurah }) {
                            SectionHeader(title: localization.localizedString("quran.lastRead"))
                            
                            Button {
                                router.pushTo(view: MainNavigationView.builder.makeView(
                                    MushafMainView(surah: surah),
                                    withNavigationTitle: surah.englishName
                                ))
                            } label: {
                                NurCard(title: "\(localization.localizedString("quran.surahLabel")) \(progress.lastSurah), \(localization.localizedString("quran.ayahLabel")) \(progress.lastAyah)", icon: "book.fill") {
                                    HStack {
                                        Text(localization.localizedString("quran.goToLastAyah"))
                                            .nurFont(12)
                                            .foregroundColor(.white.opacity(0.5))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.nurGold)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        
                        SectionHeader(title: localization.localizedString("quran.surahsTitle"))
                        
                        // Sure Listesi
                        LazyVStack(spacing: 12) {
                            if vm.isLoading {
                                ProgressView()
                                    .tint(.white)
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
                                        router.pushTo(view: MainNavigationView.builder.makeView(
                                            MushafMainView(surah: surah),
                                            withNavigationTitle: surah.englishName
                                        ))
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
                    .stroke(Color.nurGold.opacity(0.5), lineWidth: 1)
                    .frame(width: 40, height: 40)
                Text("\(surah.id)")
                    .nurFont(14, weight: .bold)
                    .foregroundColor(.nurGold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(surah.englishName)
                    .nurFont(18, weight: .bold)
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text("\(surah.ayahCount) \(localization.localizedString("quran.ayahs"))")
                    Circle().frame(width: 4, height: 4)
                    Text(surah.revelationType.localizedName(for: language))
                }
                .nurFont(12)
                .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text(surah.nameArabic)
                .nurFont(20)
                .foregroundColor(.white)
        }
        .padding(18)
        .background(.ultraThinMaterial.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(surah.id == 18 ? Color.green.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        QuranView()
            .environmentObject(LocalizationManager.shared)
    }
}
