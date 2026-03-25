import SwiftUI

struct AyahListView: View {
    let surah: SurahInfo
    @ObservedObject var vm: QuranViewModel
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        ZStack {
            Color(hex: "0F2027").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Font Kontrolü)
                VStack(spacing: 12) {
                    Text(surah.nameArabic)
                        .font(.custom("Traditional Arabic", size: 44))
                        .foregroundColor(.nurGold)
                    
                    if surah.id != 1 && surah.id != 9 {
                        Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                    }
                    
            HStack(spacing: 20) {
                // Font Slider
                HStack {
                    Image(systemName: "textformat.size.smaller")
                    Slider(value: $vm.arabicFontSize, in: 18...44)
                        .tint(.nurGold)
                    Image(systemName: "textformat.size.larger")
                }
                .foregroundColor(.white.opacity(0.6))
                
                // Reading Mode Toggle
                Button(action: { withAnimation { vm.toggleReadingMode() } }) {
                    HStack(spacing: 8) {
                        Image(systemName: vm.readingMode == .arabicOnly ? "eye.slash" : "eye")
                        Text(vm.readingMode == .arabicOnly ? localization.localizedString("quran.onlyArabic") : localization.localizedString("quran.withTranslation"))
                            .font(.system(size: 11, weight: .bold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.nurGold.opacity(0.15))
                    .foregroundColor(.nurGold)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(.ultraThinMaterial)
        
        if vm.isLoadingAyahs {
            Spacer()
            ProgressView().tint(.white)
            Spacer()
        } else {
            if vm.viewStyle == .mushaf {
                MushafPageContent(ayahs: vm.ayahs, 
                                  arabicFontSize: vm.arabicFontSize + 4, 
                                  readingMode: vm.readingMode)
                    .transition(.opacity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(vm.ayahs) { ayah in
                            AyahRowView(ayah: ayah, 
                                        fontSize: .medium, 
                                        arabicFontSize: vm.arabicFontSize, 
                                        readingMode: vm.readingMode,
                                        language: localization.currentLanguage, 
                                        isBookmarked: vm.isBookmarked(surah: surah.id, ayah: ayah.id)) {
                                vm.addBookmark(surah: surah, ayah: ayah)
                            }
                        }
                    }
                    .padding()
                }
                .transition(.opacity)
            }
        }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { withAnimation { vm.toggleViewStyle() } }) {
                    Image(systemName: vm.viewStyle == .mushaf ? "list.bullet" : "book.closed")
                }
            }
        }
        .task {
            await vm.loadAyahs(surah: surah, language: localization.currentLanguage)
        }
    }
}

struct AyahRowView: View {
    let ayah: AyahItem
    let fontSize: FontSize
    let arabicFontSize: CGFloat
    let readingMode: QuranReadingMode
    let language: LanguageCode
    let isBookmarked: Bool
    let onBookmark: () -> Void
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            // Arapça Metin (Tajweed Destekli)
            Text(TajweedFormatter.shared.format(ayah.tajweedText ?? ayah.arabicText, defaultColor: .white))
                .font(.system(size: arabicFontSize))
                .multilineTextAlignment(.trailing)
                .lineSpacing(10)
            
            HStack {
                // Ayet Numarası Badge
                ZStack {
                    Image(systemName: "hexagon")
                        .font(.system(size: 28))
                        .foregroundColor(.nurGold.opacity(0.5))
                    Text("\(ayah.id)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if readingMode == .withTranslation && language != .ar {
                    Text(ayah.translation)
                        .nurFont(16)
                        .italic()
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .contextMenu {
            Button(action: onBookmark) {
                Label(isBookmarked ? localization.localizedString("quran.removeBookmark") : localization.localizedString("quran.addBookmark"), 
                      systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
            }
            Button(action: { UIPasteboard.general.string = "\(ayah.arabicText)\n\n\(ayah.translation)" }) {
                Label(localization.localizedString("general.copy"), systemImage: "doc.on.doc")
            }
            Button(action: { /* Paylaş logic */ }) {
                Label(localization.localizedString("general.share"), systemImage: "square.and.arrow.up")
            }
        }
    }
}
