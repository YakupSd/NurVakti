//
//  DashboardView.swift
//  NurVakti
//
//  Created by Yakup Suda on 13.04.2026.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var vm = HomeViewModel.shared
    @StateObject private var dashboardVM = DashboardViewModel()
    @EnvironmentObject var localization: LocalizationManager
    @State private var selectedWisdomForShare: SpiritualMessage? = nil
    @State private var wisdomMessage: SpiritualMessage? = nil
    
    var body: some View {
        ZStack {
            // Background — Warm Cream Light Luxury
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header Card with Dynamic Sky Simulation
                    headerCard
                    
                    // Below Card Content (Cards & Quick Access)
                    contentCardsSection
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .task {
            await vm.onAppear()
            wisdomMessage = await SpiritualMessageService.shared.fetchDailyWisdomOnline()
        }
        .sheet(item: $selectedWisdomForShare) { msg in
            SpiritualShareSheet(message: msg)
        }
    }
    
    // MARK: - Dynamic Sky Simulation Header Card
    private var headerCard: some View {
        ZStack(alignment: .bottom) {
            // 1. Live Dynamic Sky Simulation (Animated & Responsive to Weather)
            SkySimulationView(prayerTimes: vm.todayPrayers, weather: vm.currentWeather)
                .frame(height: 500)
                .clipShape(CustomCardShape.shape(cutEdge: .bottom, radius: 40))
            
            // 2. Atmospheric Readability & Protection Shading
            ZStack {
                // Top subtle shade for action buttons & location
                VStack {
                    LinearGradient(
                        colors: [Color.black.opacity(0.18), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    Spacer()
                }
                
                // Bottom subtle shade for prayer times strip
                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.18)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 140)
                }
            }
            .frame(height: 500)
            .clipShape(CustomCardShape.shape(cutEdge: .bottom, radius: 40))
            
            // 3. Card Border & Subtle Shimmer
            CustomCardShape(cutEdge: .bottom, radius: 40, fillColor: .clear)
                .overlay(
                    CustomCardShape.shape(cutEdge: .bottom, radius: 40)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.nurGold.opacity(0.35),
                                    Color.white.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
            
            // 4. Information Overlays
            VStack(spacing: 0) {
                topActionBar
                    .padding(.top, 58)
                
                topInfoLayer
                    .padding(.top, 14)
                
                Spacer()
                
                nextPrayerInfoLayer
                
                Spacer()
                
                prayerTimesRow
                    .padding(.bottom, 22)
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 500)
        .shadow(color: Color.black.opacity(0.16), radius: 24, y: 10)
    }
    
    // MARK: - Next Prayer Info Layer (Floating Text on Sky)
    private var nextPrayerInfoLayer: some View {
        VStack(spacing: 0) {
            if let next = vm.nextPrayer {
                VStack(spacing: 8) {
                    // Tag
                    HStack(spacing: 6) {
                        Image(systemName: next.name.symbol)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(localization.localizedString("vakitler.nextPrayer").uppercased())
                            .nurFont(11, weight: .bold)
                            .foregroundColor(.white)
                            .tracking(1.8)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, y: 1)
                    
                    // Name & Arabic Calligraphy
                    HStack(spacing: 10) {
                        Text(next.name.localizedName(for: localization.currentLanguage))
                            .nurFont(30, weight: .bold)
                            .foregroundColor(.white)
                        
                        Text("•")
                            .foregroundColor(Color.white.opacity(0.7))
                            .font(.system(size: 16))
                        
                        Text(next.name.arabicName)
                            .font(.custom("Amiri-Bold", size: 26))
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color.black.opacity(0.35), radius: 6, y: 2)
                    
                    // Grand Countdown
                    Text(vm.countdown)
                        .nurFont(40, weight: .black, design: .monospaced)
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 8, y: 3)
                        .shadow(color: Color.nurGold.opacity(0.4), radius: 12, y: 0)
                }
            }
        }
    }
    
    // MARK: - Prayer Times Horizontal Strip
    private var prayerTimesRow: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if let prayers = vm.todayPrayers {
                        ForEach(PrayerName.allCases, id: \.self) { name in
                            prayerTimeBox(for: name, in: prayers)
                                .id(name)
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            .onChange(of: vm.nextPrayer?.name) { newName in
                if let name = newName {
                    withAnimation(.spring()) {
                        proxy.scrollTo(name, anchor: .center)
                    }
                }
            }
            .onAppear {
                if let name = vm.nextPrayer?.name {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        proxy.scrollTo(name, anchor: .center)
                    }
                }
            }
        }
    }
    
    // MARK: - Individual Prayer Time Box (Clean Floating on Sky)
    private func prayerTimeBox(for name: PrayerName, in prayers: PrayerTime) -> some View {
        let isNext = vm.nextPrayer?.name == name
        let time = getPrayerDate(for: name, in: prayers)
        
        return VStack(spacing: 4) {
            Text(name.localizedName(for: localization.currentLanguage))
                .nurFont(12, weight: isNext ? .bold : .medium)
                .foregroundColor(isNext ? .white : Color.white.opacity(0.75))
            
            Text(vm.formattedTime(time, language: localization.currentLanguage))
                .nurFont(16, weight: isNext ? .heavy : .semibold, design: .rounded)
                .foregroundColor(.white)
        }
        .frame(width: 74, height: 58)
        .background(
            Group {
                if isNext {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                        )
                } else {
                    Color.clear
                }
            }
        )
        .shadow(color: Color.black.opacity(0.3), radius: 4, y: 2)
    }
    
    // MARK: - Top Action Bar (Clean Floating SF Symbols)
    private var topActionBar: some View {
        HStack {
            Spacer()
            
            // Settings Button
            Button(action: {
                HapticManager.shared.light()
                dashboardVM.goToSettings()
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.35), radius: 4, y: 2)
                    .frame(width: 44, height: 44)
            }
        }
    }
    
    // MARK: - Top Info Layer (Location & Hijri Date Floating)
    private var topInfoLayer: some View {
        HStack(alignment: .top) {
            // Location & Weather
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(vm.cityName.isEmpty ? "···" : vm.cityName)
                        .nurFont(18, weight: .bold)
                        .foregroundColor(.white)
                }
                
                // Weather condition & temperature badge
                if let weather = vm.currentWeather {
                    HStack(spacing: 4) {
                        Image(systemName: weather.condition.icon)
                            .font(.system(size: 11, weight: .semibold))
                        Text("\(weather.formattedTemperature) · \(weather.condition.localizedNameTr)")
                            .nurFont(11, weight: .medium)
                    }
                    .foregroundColor(Color.white.opacity(0.85))
                    .padding(.leading, 2)
                }
            }
            .shadow(color: Color.black.opacity(0.35), radius: 5, y: 2)
            
            Spacer()
            
            // Date Box
            VStack(alignment: .trailing, spacing: 2) {
                Text(vm.hijriText)
                    .nurFont(15, weight: .bold)
                    .foregroundColor(.white)
                
                Text(formattedGregorianDate)
                    .nurFont(12, weight: .medium)
                    .foregroundColor(Color.white.opacity(0.85))
            }
            .shadow(color: Color.black.opacity(0.35), radius: 5, y: 2)
        }
    }
    
    private var formattedGregorianDate: String {
        let f = DateFormatter()
        f.locale = localization.currentLanguage.locale
        f.dateFormat = "d MMMM yyyy"
        return f.string(from: Date())
    }
    
    // MARK: - CONTENT CARDS SECTION
    @ViewBuilder
    private var contentCardsSection: some View {
        VStack(spacing: 24) {
            // 0. Friday or Special Day Hero Banner (Auto-detects Friday / Kandil / Bayram)
            fridayOrSpecialDayBanner
            
            // 1. Day's Guidance (Ayah, Hadith & Daily Wisdom)
            VStack(spacing: 16) {
                NurCardWithHeader(
                    title: localization.localizedString("guidance.dailyAyat"),
                    icon: "sparkles",
                    content: vm.dailyAyah
                )
                
                NurCardWithHeader(
                    title: localization.localizedString("guidance.dailyHadith"),
                    icon: "hands.sparkles.fill",
                    content: vm.dailyDua
                )
                
                // Günün Hikmetli Sözü Kartı
                dailyWisdomCard
            }
            .padding(.horizontal, 20)
            
            // 2. Tesbihat Action
            Button(action: { 
                HapticManager.shared.tap()
                dashboardVM.router.pushTo(view: MainNavigationView.builder.makeView(
                    TesbihatView(),
                    withNavigationTitle: "Tesbihat"
                ))
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "circle.grid.3x3.fill")
                        .font(.system(size: 18))
                    Text(localization.localizedString("prayerGuide.tasbih").uppercased())
                        .nurFont(15, weight: .bold)
                        .tracking(1.2)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.nurGold, Color(hex: "FFD700")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .nurGold.opacity(0.3), radius: 12, y: 5)
            }
            .padding(.horizontal, 20)
            
            // 3. Dhikr Progress
            VStack(spacing: 12) {
                HStack {
                    Label(localization.localizedString("dhikr.dailyTotal"), systemImage: "bolt.heart.fill")
                        .nurFont(12, weight: .bold)
                        .foregroundColor(.nurGold.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(vm.dhikrCount) / \(vm.dhikrTarget)")
                        .nurFont(12, weight: .bold, design: .monospaced)
                        .foregroundColor(.nurGold)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: "1A1A2E").opacity(0.08))
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.nurGold, Color(hex: "FFD700")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(min(1.0, Double(vm.dhikrCount) / Double(vm.dhikrTarget))))
                            .shadow(color: .nurGold.opacity(0.4), radius: 6)
                    }
                }
                .frame(height: 6)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            
            // 4. Horizontal Feature Hub
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 20) {
                    FeatureCircleButton(
                        icon: "envelope.badge.fill",
                        title: localization.localizedString("spiritual.messagesTitle"),
                        action: { 
                            dashboardVM.router.pushTo(view: MainNavigationView.builder.makeView(
                                SpiritualMessagesView(),
                                withNavigationTitle: localization.localizedString("spiritual.messagesTitle")
                            ))
                        }
                    )
                    
                    FeatureCircleButton(
                        icon: "figure.stand",
                        title: localization.localizedString("prayerGuide.howToPray"),
                        action: { 
                            dashboardVM.router.pushTo(view: MainNavigationView.builder.makeView(
                                HowToPrayView(),
                                withNavigationTitle: localization.localizedString("prayerGuide.howToPray")
                            ))
                        }
                    )
                    
                    FeatureCircleButton(
                        icon: "text.book.closed.fill",
                        title: localization.localizedString("prayerGuide.title"),
                        action: { 
                            dashboardVM.router.pushTo(view: MainNavigationView.builder.makeView(
                                PrayerGuideMainView(),
                                withNavigationTitle: localization.localizedString("prayerGuide.title")
                            ))
                        }
                    )
                    
                    FeatureCircleButton(
                        icon: "hands.sparkles.fill",
                        title: localization.localizedString("prayerGuide.duas"),
                        action: { 
                            dashboardVM.router.pushTo(view: MainNavigationView.builder.makeView(
                                PrayerDuasView(),
                                withNavigationTitle: localization.localizedString("prayerGuide.duas")
                            ))
                        }
                    )
                    
                    FeatureCircleButton(
                        icon: "location.north.fill",
                        title: localization.localizedString("home.qiblaShortcut"),
                        action: { 
                            dashboardVM.router.pushTo(view: MainNavigationView.builder.makeView(
                                QiblaView(),
                                withNavigationTitle: localization.localizedString("home.qiblaShortcut")
                            ))
                        }
                    )
                    
                    FeatureCircleButton(
                        icon: "calendar.badge.clock",
                        title: localization.localizedString("home.calendar"),
                        action: { 
                            dashboardVM.router.pushTo(view: MainNavigationView.builder.makeView(
                                IslamicCalendarView(),
                                withNavigationTitle: localization.localizedString("home.calendar")
                            ))
                        }
                    )
                    
                    FeatureCircleButton(
                        icon: "sparkles",
                        title: "Esmaü'l-Hüsna",
                        action: { 
                            dashboardVM.router.pushTo(view: MainNavigationView.builder.makeView(
                                EsmaulHusnaView(),
                                withNavigationTitle: "Esmaü'l-Hüsna"
                            ))
                        }
                    )
                    
                    FeatureCircleButton(
                        icon: "scalemass.fill",
                        title: localization.localizedString("home.zakatCalculator"),
                        action: { 
                            dashboardVM.router.pushTo(view: MainNavigationView.builder.makeView(
                                ZakatCalculatorView(),
                                withNavigationTitle: localization.localizedString("home.zakatCalculator")
                            ))
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            
            Spacer().frame(height: 120)
        }
        .padding(.top, 24)
    }
    
    // MARK: - Friday / Special Day Banner
    @ViewBuilder
    private var fridayOrSpecialDayBanner: some View {
        if let special = SpiritualMessageService.shared.getTodaySpecialEventBanner(currentLanguage: localization.currentLanguage) {
            Button(action: {
                HapticManager.shared.tap()
                dashboardVM.router.pushTo(view: MainNavigationView.builder.makeView(
                    SpiritualMessagesView(initialCategory: special.category),
                    withNavigationTitle: special.title
                ))
            }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "0E1626").opacity(0.12))
                            .frame(width: 44, height: 44)
                        Text(special.emoji)
                            .font(.system(size: 22))
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(special.title)
                            .nurFont(15, weight: .bold)
                            .foregroundColor(Color(hex: "0E1626"))
                        Text(special.subtitle)
                            .nurFont(12)
                            .foregroundColor(Color(hex: "0E1626").opacity(0.8))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Tebrikler")
                            .nurFont(11, weight: .bold)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "0E1626"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(hex: "0E1626").opacity(0.12))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.nurGold, Color(hex: "F3C64F"), Color(hex: "E5B338")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: Color.nurGold.opacity(0.3), radius: 10, y: 4)
            }
            .buttonStyle(BouncyButtonStyle())
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Daily Wisdom Card
    @ViewBuilder
    private var dailyWisdomCard: some View {
        let wisdom = wisdomMessage ?? SpiritualMessageService.shared.getDailyWisdom()
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(localization.localizedString("spiritual.dailyWisdom").uppercased(), systemImage: "quote.bubble.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.nurGold)
                    .tracking(1.5)
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Copy Button
                    Button(action: {
                        HapticManager.shared.light()
                        let authorText = wisdom.authorOrSource != nil ? "\n— \(wisdom.authorOrSource!)" : ""
                        UIPasteboard.general.string = "\(wisdom.text)\(authorText)"
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                            .padding(6)
                            .background(Color(hex: "1A1A2E").opacity(0.08))
                            .clipShape(Circle())
                    }
                    
                    // Story / Share Button
                    Button(action: {
                        HapticManager.shared.tap()
                        selectedWisdomForShare = wisdom
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 10))
                            Text(localization.localizedString("general.share"))
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.nurGold)
                        .cornerRadius(10)
                    }
                }
            }
            
            Text(wisdom.text)
                .font(.system(size: 15, weight: .medium, design: .serif))
                .foregroundColor(Color(hex: "1A1A2E"))
                .lineSpacing(5)
                .italic()
            
            if let author = wisdom.authorOrSource, !author.isEmpty {
                HStack {
                    Spacer()
                    Text("— " + author)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.nurGold)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: NurTheme.cardShadow, radius: NurTheme.cardShadowRadius, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Navigation Helpers
extension DashboardView {
    private func getPrayerDate(for name: PrayerName, in prayers: PrayerTime) -> Date {
        switch name {
        case .imsak:   return prayers.imsak
        case .fajr:    return prayers.fajr
        case .sunrise: return prayers.sunrise
        case .dhuhr:   return prayers.dhuhr
        case .asr:     return prayers.asr
        case .maghrib: return prayers.maghrib
        case .isha:    return prayers.isha
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(LocalizationManager.shared)
}
