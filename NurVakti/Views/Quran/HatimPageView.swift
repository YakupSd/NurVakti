import SwiftUI

struct HatimPageView: View {
    @State var currentPage: Int
    @ObservedObject var vm: QuranViewModel
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        ZStack {
            Color(hex: "0F2027").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Sayfa Kontrolü)
                HStack {
                    Button(action: { router.pop() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.trailing, 8)
                    
                    Button(action: { 
                        if currentPage > 1 { 
                            HapticManager.shared.light()
                            changePage(to: currentPage - 1) 
                        } 
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title)
                            .foregroundColor(currentPage > 1 ? .nurGold : .white.opacity(0.1))
                    }
                    .disabled(currentPage <= 1)
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("\(localization.localizedString("quran.pageLabel")) \(currentPage)")
                            .nurFont(20, weight: .bold)
                            .foregroundColor(.white)
                        Text("604")
                            .nurFont(12)
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    Spacer()
                    
                    Button(action: { 
                        if currentPage < 604 { 
                            HapticManager.shared.light()
                            changePage(to: currentPage + 1) 
                        } 
                    }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title)
                            .foregroundColor(currentPage < 604 ? .nurGold : .white.opacity(0.1))
                    }
                    .disabled(currentPage >= 604)
                }
                .padding()
                .background(.ultraThinMaterial)
                
                if vm.isLoadingAyahs {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView().tint(.nurGold)
                        Text(localization.localizedString("home.loading"))
                            .nurFont(14)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                } else {
                    if vm.viewStyle == .mushaf {
                        MushafPageContent(ayahs: vm.ayahs, 
                                          arabicFontSize: vm.arabicFontSize + 4, 
                                          readingMode: vm.readingMode)
                            .background(Color(hex: "FDFBF0").opacity(0.95)) // Saman kağıdı rengi/dokusu
                            .cornerRadius(12)
                            .padding(8)
                            .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 24) {
                                ForEach(vm.ayahs) { ayah in
                                    AyahRowView(ayah: ayah, 
                                                fontSize: .medium, 
                                                arabicFontSize: vm.arabicFontSize, 
                                                readingMode: vm.readingMode,
                                                language: localization.currentLanguage, 
                                                isBookmarked: vm.isBookmarked(surah: ayah.surahNumber, ayah: ayah.id)) {
                                        HapticManager.shared.success()
                                        // Bookmark logic (needs SurahInfo implementation)
                                    }
                                }
                            }
                            .padding()
                        }
                        .transition(.opacity)
                    }
                }
                
                // Sayfa altı Kontroller (Okuma Modu & Görünüm)
                HStack(spacing: 12) {
                    Button(action: { 
                        HapticManager.shared.light()
                        withAnimation { vm.toggleReadingMode() } 
                    }) {
                        Label(vm.readingMode == .arabicOnly ? localization.localizedString("quran.onlyArabic") : localization.localizedString("quran.withTranslation"),
                              systemImage: vm.readingMode == .arabicOnly ? "eye.slash" : "eye")
                            .nurFont(12, weight: .bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.nurGold.opacity(0.15))
                            .foregroundColor(.nurGold)
                            .cornerRadius(12)
                    }
                    
                    Button(action: { 
                        HapticManager.shared.light()
                        withAnimation { vm.toggleViewStyle() } 
                    }) {
                        Label(vm.viewStyle == .mushaf ? localization.localizedString("quran.listView") : localization.localizedString("quran.mushafView"),
                              systemImage: vm.viewStyle == .mushaf ? "list.bullet" : "book.closed")
                            .nurFont(12, weight: .bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        .navigationBarHidden(true)
        .task {
            await vm.loadHatimPage(page: currentPage, language: localization.currentLanguage)
        }
    }
    
    private func changePage(to page: Int) {
        currentPage = page
        Task {
            await vm.loadHatimPage(page: page, language: localization.currentLanguage)
        }
    }
}
