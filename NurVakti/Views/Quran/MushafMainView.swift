import SwiftUI

struct MushafMainView: View {
    @StateObject private var vm: MushafViewModel
    
    init(surah: SurahInfo) {
        _vm = StateObject(wrappedValue: MushafViewModel(surah: surah))
    }
    
    init(page: Int) {
        _vm = StateObject(wrappedValue: MushafViewModel(page: page))
    }
    
    var body: some View {
        ZStack {
            Color.mushafBackground.ignoresSafeArea()
            
            if vm.isLoading {
                VStack {
                    ProgressView()
                        .tint(Color.nurGoldPremium)
                    Text(LocalizationManager.shared.localizedString("quran.mushafLoading"))
                        .foregroundColor(Color.nurGoldPremium)
                }
            } else if vm.loadError {
                // Hata durumu — Retry butonu
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color.nurGoldPremium)
                    Text(LocalizationManager.shared.localizedString("general.loadFailed"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "1A1A2E"))
                    Button(action: {
                        if let page = vm.pageNumber {
                            vm.loadPageData(page)
                        } else {
                            vm.loadSurahData()
                        }
                    }) {
                        Text(LocalizationManager.shared.localizedString("general.tryAgain"))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.nurGoldPremium)
                            .cornerRadius(12)
                    }
                }
            } else if !vm.pages.isEmpty {
                ZStack {
                    MushafPageController(
                        currentPageIndex: $vm.currentPageIndex,
                        pages: vm.pages
                    )
                    .ignoresSafeArea()
                    
                    // Page Navigation Buttons
                    HStack {
                        // Previous Page Button
                        Button(action: {
                            vm.previousPage()
                        }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(Color.nurGoldPremium.opacity(0.6))
                                .background(Circle().fill(Color.mushafBackground.opacity(0.8)))
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        // Next Page Button
                        Button(action: {
                            vm.nextPage()
                        }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(Color.nurGoldPremium.opacity(0.6))
                                .background(Circle().fill(Color.mushafBackground.opacity(0.8)))
                        }
                        .padding(.trailing, 20)
                    }
                }
            } else {
                Text(LocalizationManager.shared.localizedString("general.noContent"))
            }
        }
    }
}

