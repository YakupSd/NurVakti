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
                        TextField(localization.localizedString("quran.searchPlaceholder"), text: $vm.searchText)
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
                            router.push(to: .mushaf(page: page))
                        }) {
                            NurCard(title: localization.localizedString("quran.hatimJourney"), icon: "sparkles") {
                                let page = vm.hatimProgress?.currentPage ?? 1
                                HStack(spacing: 20) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                                            Text("\(page)")
                                                .nurFont(32, weight: .bold)
                                                .foregroundColor(.nurGold)
                                            Text("/ 604")
                                                .nurFont(16, weight: .medium)
                                                .foregroundColor(.white.opacity(0.4))
                                                                            
                                            Text(localization.localizedString("quran.pageLabel"))
                                                .nurFont(14)
                                                .foregroundColor(.white.opacity(0.6))
                                                .padding(.leading, 8)
                                        }
                                        
                                        ProgressView(value: Double(page), total: 604)
                                            .tint(.nurGold)
                                            .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                        
                                        Text(page == 1 ? localization.localizedString("quran.startFromFirst") : localization.localizedString("quran.continueWhereLeft"))
                                            .nurFont(13, weight: .medium)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .fill(Color.nurGold.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        Image(systemName: page == 1 ? "arrow.right" : "play.fill")
                                            .font(.title3)
                                            .foregroundColor(.nurGold)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        
                        // Devam Et Banner
                        if let progress = vm.readingProgress {
                            SectionHeader(title: localization.localizedString("quran.lastRead"))
                            
                            // Not: Burada surenin SurahInfo nesnesine ihtiyacı var. 
                            // Basitleştirmek için veya progress içinde surahInfo tutulabilir.
                            // Şimdilik sadece Hatim'e yönelelim veya progress'i butona bağlayalım.
                            Button(action: {
                                if let surah = vm.surahs.first(where: { $0.id == progress.lastSurah }) {
                                    router.push(to: .mushaf(surah: surah))
                                }
                            }) {
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
                                    Button(action: { 
                                        router.push(to: .mushaf(surah: surah))
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
