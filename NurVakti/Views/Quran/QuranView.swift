import SwiftUI

struct QuranView: View {
    @StateObject var vm = QuranViewModel()
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        ZStack {
            // Arka plan (Home ile uyumlu)
            LinearGradient(colors: [Color(hex: "0F2027"), Color(hex: "203A43")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ÜSTBAR
                VStack(spacing: 16) {
                    HStack {
                        Text(localization.localizedString("menu_quran"))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Arama Çubuğu
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.6))
                        TextField(localization.localizedString("quran_search_placeholder"), text: $vm.searchText)
                            .textFieldStyle(.plain)
                            .foregroundColor(.white)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        // Hatim Banner
                        SectionHeader(title: localization.localizedString("quran.hatimJourney"))
                        
                        Button(action: { 
                            let page = vm.hatimProgress?.currentPage ?? 1
                            router.pushTo(
                                view: MainNavigationView.builder.makeView(
                                    HatimPageView(currentPage: page, vm: vm),
                                    withNavigationTitle: "Hatim",
                                    isShowRightButton: false
                                )
                            )
                        }) {
                            NurCard(title: "Kur'an-ı Hatmet", icon: "sparkles") {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        let page = vm.hatimProgress?.currentPage ?? 1
                                        Text("\(localization.localizedString("quran.pageLabel")) \(page) / 604")
                                            .nurFont(18, weight: .bold)
                                        
                                        ProgressView(value: Double(page), total: 604)
                                            .tint(.nurGold)
                                            .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                            .padding(.vertical, 8)
                                        
                                        Text(page == 1 ? localization.localizedString("quran.startFromFirst") : localization.localizedString("quran.continueWhereLeft"))
                                            .nurFont(12)
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    Spacer()
                                    Image(systemName: "play.fill")
                                        .font(.title2)
                                        .foregroundColor(.nurGold)
                                }
                            }
                        }
                        
                        // Devam Et Banner
                        if let progress = vm.readingProgress {
                            SectionHeader(title: localization.localizedString("quran.lastRead"))
                            
                            // Not: Burada surenin SurahInfo nesnesine ihtiyacı var. 
                            // Basitleştirmek için veya progress içinde surahInfo tutulabilir.
                            // Şimdilik sadece Hatim'e yönelelim veya progress'i butona bağlayalım.
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
                                    Button(action: { 
                                        router.pushTo(
                                            view: MainNavigationView.builder.makeView(
                                                AyahListView(surah: surah, vm: vm),
                                                withNavigationTitle: surah.englishName,
                                                isShowRightButton: false
                                            )
                                        )
                                    }) {
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
            // Numara
            ZStack {
                Circle()
                    .stroke(Color.nurGold.opacity(0.5), lineWidth: 1)
                    .frame(width: 40, height: 40)
                Text("\(surah.id)")
                    .nurFont(14, weight: .bold)
                    .foregroundColor(.nurGold)
            }
            
            // İsim ve Detay
            VStack(alignment: .leading, spacing: 4) {
                Text(surah.englishName) // Yerel isim gerekebilir
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
            
            // Arapça İsim
            Text(surah.nameArabic)
                .nurFont(20)
                .foregroundColor(.white)
        }
        .padding()
        .background(surah.id == 18 ? Color.green.opacity(0.1) : Color.white.opacity(0.05)) // Kehf suresi vurgusu örneği
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(surah.id == 18 ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        QuranView()
            .environmentObject(LocalizationManager.shared)
    }
}
