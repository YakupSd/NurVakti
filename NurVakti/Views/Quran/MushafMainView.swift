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
                    Text("Mushaf Yükleniyor...")
                        .foregroundColor(Color.nurGoldPremium)
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
                Text("Veri bulunamadı.")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(vm.pages.first?.surahName ?? "Mushaf-ı Şerif")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.nurGoldPremium)
            }
        }
    }
}

