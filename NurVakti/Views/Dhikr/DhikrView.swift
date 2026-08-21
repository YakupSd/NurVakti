import SwiftUI

struct DhikrView: View {
    @StateObject var vm: DhikrViewModel
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    @State private var selectedTab = 0 // 0: Zikirler, 1: Dualar
    
    var body: some View {
        ZStack {
            // Background — Warm Cream Light Luxury
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── ÜST KISIM (TITLE & TAB) ─────────────────────
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(localization.localizedString("dhikr.spiritualJourney"))
                                .nurFont(12, weight: .bold)
                                .kerning(1.1)
                                .foregroundColor(.nurGold)
                            
                            Text(localization.localizedString("dhikr.zikirAndDua"))
                                .nurFont(28, weight: .bold)
                                .foregroundColor(Color(hex: "1A1A2E"))
                        }
                        
                        Spacer()
                        
                        Button(action: { vm.showingAddSheet = true }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 44, height: 44)
                                    .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
                                    .overlay(
                                        Circle()
                                            .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                                    )
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.nurGold)
                            }
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    // Segmented Control (Apple Inset Style)
                    HStack(spacing: 0) {
                        tabButton(title: localization.localizedString("tab.dhikr"), index: 0)
                        tabButton(title: localization.localizedString("dhikr.prayers"), index: 1)
                    }
                    .padding(4)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 16)
                
                // ── İÇERİK ─────────────────────────────────────
                if selectedTab == 0 {
                    zikirlerSection
                } else {
                    dualarSection
                }
            }
        }
        .onChange(of: vm.showingAddSheet) { newValue in
            if newValue {
                vm.resetNewDhikrFields()
                router.pushTo(
                    view: MainNavigationView.builder.makeView(
                        AddDhikrView(vm: vm),
                        withNavigationTitle: localization.localizedString("dhikr.addNew"),
                        isShowRightButton: true,
                        rightImage: "checkmark.circle.fill",
                        rightButtonAction: {
                            if vm.saveNewDhikr() {
                                HapticManager.shared.success()
                                router.pop()
                            } else {
                                HapticManager.shared.error()
                            }
                        }
                    )
                )
                vm.showingAddSheet = false
            }
        }
        .onAppear {
            vm.resetDailyIfNeeded()
            HomeViewModel.shared.updateDhikrStatus()
        }
    }
    
    private var zikirlerSection: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // AKTİF SAYAÇ
                DhikrCounterView(
                    item: $vm.activeItem, 
                    language: localization.currentLanguage, 
                    fontSize: .medium
                ) {
                    HapticManager.shared.dhikrDone()
                }
                .padding(.top, 8)
                
                // ZİKİR KOLEKSİYONU
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(localization.localizedString("dhikr.collection"))
                            .nurFont(16, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                        Spacer()
                        Text("\(vm.dhikrItems.count)")
                            .nurFont(12, weight: .bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.nurGold.opacity(0.15))
                            .foregroundColor(.nurGold)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(vm.dhikrItems) { item in
                                DhikrMiniCard(item: item, isActive: vm.activeItem.id == item.id) {
                                    HapticManager.shared.selectionChanged()
                                    vm.selectDhikr(item)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                    }
                }
                
                // BUGÜNÜN ÖZETİ
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: localization.localizedString("dhikr.peaceReport"), icon: "sparkles")
                        .padding(.horizontal, 20)
                    
                    let totalDaily = vm.dhikrItems.reduce(0) { $0 + $1.dailyCompletions }
                    let totalAllTime = vm.dhikrItems.reduce(0) { $0 + $1.totalCompletions }
                    
                    HStack(spacing: 12) {
                        SummaryBox(
                            title: localization.localizedString("dhikr.dailyTotal"),
                            value: "\(totalDaily)",
                            icon: "checkmark.seal.fill",
                            color: .green
                        )
                        SummaryBox(
                            title: localization.localizedString("dhikr.grandTotal"),
                            value: "\(totalAllTime)",
                            icon: "sum",
                            color: .nurGold
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 120)
            }
        }
    }
    
    private var dualarSection: some View {
        PrayerDuaList(language: localization.currentLanguage, vm: vm)
            .transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
    }
    
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            HapticManager.shared.selectionChanged()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
            Text(title)
                .nurFont(13, weight: selectedTab == index ? .bold : .medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selectedTab == index ? Color.nurGold : Color.clear)
                .foregroundColor(selectedTab == index ? Color(hex: "1A1A2E") : Color(hex: "1A1A2E").opacity(0.55))
                .cornerRadius(12)
        }
    }
}

struct DhikrMiniCard: View {
    let item: DhikrItem
    @EnvironmentObject var localization: LocalizationManager
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(isActive ? Color.nurGold.opacity(0.2) : Color(hex: "1A1A2E").opacity(0.05))
                            .frame(width: 34, height: 34)
                        Image(systemName: "hands.sparkles.fill")
                            .foregroundColor(isActive ? .nurGold : Color(hex: "1A1A2E").opacity(0.4))
                            .font(.system(size: 14))
                    }
                    
                    Spacer()
                    
                    if item.dailyCompletions > 0 {
                        Text("x\(item.dailyCompletions)")
                            .nurFont(10, weight: .bold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.nurGold)
                            .clipShape(Capsule())
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.arabicText)
                        .font(.custom("ScheherazadeNew-Bold", size: 18))
                        .lineLimit(1)
                        .foregroundColor(Color(hex: "2C1E11"))
                    
                    Text(item.meanings[localization.currentLanguage] ?? item.meanings[.tr] ?? "")
                        .nurFont(11)
                        .lineLimit(1)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.55))
                }
                
                HStack(spacing: 3) {
                    Text("\(item.currentCount)")
                        .nurFont(12, weight: .bold)
                        .foregroundColor(.nurGold)
                    Text("/")
                        .nurFont(11)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.3))
                    Text("\(item.targetCount)")
                        .nurFont(11, weight: .semibold)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                }
            }
            .padding(14)
            .frame(width: 154, height: 130, alignment: .leading)
            .background(Color.white)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isActive ? Color.nurGold : Color(hex: "1A1A2E").opacity(0.06), lineWidth: isActive ? 1.5 : 1)
            )
            .shadow(color: isActive ? Color.nurGold.opacity(0.15) : Color.black.opacity(0.02), radius: 6, y: 2)
        }
        .buttonStyle(CardPressableButtonStyle())
    }
}

struct SummaryBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 13, weight: .bold))
            }
            
            Text(value)
                .nurFont(26, weight: .heavy, design: .rounded)
                .foregroundColor(Color(hex: "1A1A2E"))
            
            Text(title)
                .nurFont(11, weight: .semibold)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
    }
}

struct PrayerDuaList: View {
    let language: LanguageCode
    @ObservedObject var vm: DhikrViewModel
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    @State private var duaTab = 0 // 0: Sabah, 1: Akşam
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Dua Time Picker
                HStack(spacing: 0) {
                    duaTabButton(title: localization.localizedString("dhikr.morning"), index: 0)
                    duaTabButton(title: localization.localizedString("dhikr.evening"), index: 1)
                }
                .padding(4)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                )
                
                let currentDuas = duaTab == 0 ? vm.morningDuas : vm.eveningDuas
                
                ForEach(currentDuas) { dua in
                    Button(action: { 
                        HapticManager.shared.light()
                        router.pushTo(view: MainNavigationView.builder.makeView(
                            DuaDetailView(dua: dua, language: language),
                            withNavigationTitle: dua.title[language] ?? ""
                        ))
                    }) {
                        VStack(alignment: .trailing, spacing: 10) {
                            HStack {
                                Text(dua.title[language] ?? "")
                                    .nurFont(16, weight: .bold)
                                    .foregroundColor(Color(hex: "1A1A2E"))
                                Spacer()
                                Image(systemName: "hand.raised.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.nurGold)
                            }
                            
                            Text(dua.arabicText)
                                .font(.custom("ScheherazadeNew-Bold", size: 22))
                                .lineLimit(2)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(Color(hex: "2C1E11"))
                                .padding(.vertical, 2)
                            
                            Text(dua.translation[language] ?? "")
                                .nurFont(13)
                                .lineLimit(2)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
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
                    .buttonStyle(CardPressableButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
    }
    
    private func duaTabButton(title: String, index: Int) -> some View {
        Button(action: {
            HapticManager.shared.selectionChanged()
            withAnimation(.spring(response: 0.3)) { duaTab = index }
        }) {
            Text(title)
                .nurFont(12, weight: .bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(duaTab == index ? Color.nurGold : Color.clear)
                .foregroundColor(duaTab == index ? Color(hex: "1A1A2E") : Color(hex: "1A1A2E").opacity(0.55))
                .cornerRadius(10)
        }
    }
}

#Preview {
    DhikrView(vm: DhikrViewModel())
        .environmentObject(LocalizationManager.shared)
        .environmentObject(AppRouter.shared)
}
