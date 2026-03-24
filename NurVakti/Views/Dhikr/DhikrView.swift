import SwiftUI

struct DhikrView: View {
    @StateObject var vm: DhikrViewModel
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    @State private var selectedTab = 0 // 0: Zikirler, 1: Dualar
    
    var body: some View {
        ZStack {
            // Arka plan (Premium Gradient)
            LinearGradient(
                colors: [
                    Color(hex: "0D1B2A"), // Gece mavisi
                    Color(hex: "1B263B"),
                    Color(hex: "000000") // Siyah alt
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Süsleme (Subtle Glows)
            Circle()
                .fill(Color.nurGold.opacity(0.05))
                .frame(width: 400, height: 400)
                .offset(x: -150, y: -200)
                .blur(radius: 80)
            
            VStack(spacing: 0) {
                // ── ÜST KISIM (TITLE & TAB) ─────────────────────
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localization.localizedString("dhikr.spiritualJourney"))
                                .nurFont(14, weight: .medium)
                                .foregroundColor(.nurGold.opacity(0.8))
                            Text(localization.localizedString("dhikr.zikirAndDua"))
                                .nurFont(32, weight: .bold)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: { vm.showingAddSheet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.nurGold)
                                .padding(8)
                                .background(Color.white.opacity(0.05))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Custom Tab Switcher
                    HStack(spacing: 0) {
                        tabButton(title: localization.localizedString("tab.dhikr"), index: 0)
                        tabButton(title: localization.localizedString("dhikr.prayers"), index: 1)
                    }
                    .padding(4)
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .padding(.bottom, 25)
                
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
    }
    
    private var zikirlerSection: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // AKTİF SAYAÇ (Mücevher Görünümü)
                DhikrCounterView(item: $vm.activeItem, 
                                 language: localization.currentLanguage, 
                                 fontSize: .medium) {
                    // On Complete
                    withAnimation {
                        // Belki bir kutlama efekti eklenebilir
                    }
                }
                
                // ZİKİR LİSTESİ (Sleek Horizontal Cards)
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(localization.localizedString("dhikr.collection"))
                            .nurFont(18, weight: .bold)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(vm.dhikrItems.count)")
                            .nurFont(12, weight: .bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.nurGold.opacity(0.2))
                            .foregroundColor(.nurGold)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(vm.dhikrItems) { item in
                                DhikrMiniCard(item: item, isActive: vm.activeItem.id == item.id) {
                                    vm.selectDhikr(item)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // BUGÜNÜN ÖZETİ
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: localization.localizedString("dhikr.peaceReport"), icon: "sparkles")
                    
                    let totalDaily = vm.dhikrItems.reduce(0) { $0 + $1.dailyCompletions }
                    let totalAllTime = vm.dhikrItems.reduce(0) { $0 + $1.totalCompletions }
                    
                    HStack(spacing: 16) {
                        SummaryBox(title: localization.localizedString("dhikr.dailyTotal"), value: "\(totalDaily)", icon: "checkmark.seal.fill", color: .green)
                        SummaryBox(title: localization.localizedString("dhikr.grandTotal"), value: "\(totalAllTime)", icon: "sum", color: .nurGold)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
    
    private var dualarSection: some View {
        PrayerDuaList(language: localization.currentLanguage, vm: vm)
            .transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
    }
    
    // Yardımcı Görünümler
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
            Text(title)
                .nurFont(14, weight: selectedTab == index ? .bold : .medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedTab == index ? Color.nurGold : Color.clear)
                .foregroundColor(selectedTab == index ? .black : .white.opacity(0.6))
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
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .center) {
                    Circle()
                        .fill(isActive ? Color.nurGold.opacity(0.2) : Color.white.opacity(0.05))
                        .frame(width: 40, height: 40)
                    Image(systemName: "hands.sparkles.fill")
                        .foregroundColor(isActive ? .nurGold : .white.opacity(0.3))
                        .font(.system(size: 16))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.arabicText)
                        .nurFont(16, weight: .bold)
                        .lineLimit(1)
                        .foregroundColor(.white)
                    
                    // Anlam (Meal)
                    Text(item.meanings[localization.currentLanguage] ?? item.meanings[.tr] ?? "")
                        .nurFont(12)
                        .lineLimit(1)
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack {
                        HStack(spacing: 4) {
                            Text("\(item.currentCount)")
                                .foregroundColor(.nurGold)
                            Text("/")
                                .foregroundColor(.white.opacity(0.3))
                            Text("\(item.targetCount)")
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .nurFont(12, weight: .medium)
                        
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
                }
            }
            .padding(16)
            .frame(width: 150, height: 130, alignment: .leading)
            .background(isActive ? Color.white.opacity(0.12) : Color.white.opacity(0.05))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isActive ? Color.nurGold.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SummaryBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14, weight: .bold))
                Spacer()
            }
            
            Text(value)
                .nurFont(28, weight: .heavy)
                .foregroundColor(.white)
            
            Text(title)
                .nurFont(12, weight: .medium)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}

struct PrayerDuaList: View {
    let language: LanguageCode
    @ObservedObject var vm: DhikrViewModel
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    @State private var duaTab = 0 // 0: Sabah, 1: Akşam
    @State private var selectedDua: DuaItem? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Dua Time Picker
                HStack(spacing: 0) {
                    duaTabButton(title: localization.localizedString("dhikr.morning"), index: 0)
                    duaTabButton(title: localization.localizedString("dhikr.evening"), index: 1)
                }
                .padding(4)
                .background(Color.white.opacity(0.07))
                .cornerRadius(12)
                
                let currentDuas = duaTab == 0 ? vm.morningDuas : vm.eveningDuas
                
                ForEach(currentDuas) { dua in
                    Button(action: { 
                        router.pushTo(
                            view: MainNavigationView.builder.makeView(
                                DuaDetailView(dua: dua, language: language),
                                withNavigationTitle: "Dua",
                                isShowRightButton: true,
                                rightImage: "square.and.arrow.up",
                                rightButtonAction: {
                                    // Örnek Paylaşım Aksiyonu
                                    print("Dua paylaşıldı: \(dua.title[language] ?? "")")
                                }
                            )
                        )
                    }) {
                        VStack(alignment: .trailing, spacing: 12) {
                            HStack {
                                Text(dua.title[language] ?? "")
                                    .nurFont(18, weight: .bold)
                                    .foregroundColor(.nurGold)
                                Spacer()
                                Image(systemName: "hand.raised.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.2))
                            }
                            
                            Text(dua.arabicText)
                                .font(.custom("Traditional Arabic", size: 24))
                                .lineLimit(2)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.white)
                                .padding(.vertical, 4)
                            
                            Text(dua.translation[language] ?? "")
                                .nurFont(14)
                                .lineLimit(2)
                                .foregroundColor(.white.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
    
    private func duaTabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) { duaTab = index }
        }) {
            Text(title)
                .nurFont(13, weight: .bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(duaTab == index ? Color.nurGold : Color.clear)
                .foregroundColor(duaTab == index ? .black : .white.opacity(0.6))
                .cornerRadius(10)
        }
    }
}

#Preview {
    DhikrView(vm: DhikrViewModel())
        .environmentObject(LocalizationManager.shared)
}
