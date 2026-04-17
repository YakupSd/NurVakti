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
    
    var body: some View {
        ZStack {
            // Background
            // Background - Light Green
            Color.nurLightGreenBg.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header Card (Stage 2 will populate this)
                    headerCard
                    
                    // Below Card Content (Cards & Quick Access)
                    contentCardsSection
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .task {
            await vm.onAppear()
        }
    }
    
    private var headerCard: some View {
        ZStack(alignment: .bottom) {
            // 1. Sky Simulation
            SkySimulationView(prayerTimes: vm.todayPrayers)
                .frame(height: 480)
                .clipShape(CustomCardShape.shape(cutEdge: .bottom, radius: 40))
            
            // 2. Card Overlay Shadow
            CustomCardShape(cutEdge: .bottom, radius: 40, fillColor: .clear)
                .overlay(
                    CustomCardShape.shape(cutEdge: .bottom, radius: 40)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            // 3. Information Overlays
            VStack(spacing: 0) {
                topActionBar
                    .padding(.top, 60)
                
                topInfoLayer
                    .padding(.top, 20)
                
                Spacer()
                
                nextPrayerInfoLayer
                
                Spacer()
                
                prayerTimesRow
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 480)
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }
    
    private var nextPrayerInfoLayer: some View {
        VStack(spacing: 6) {
            if let next = vm.nextPrayer {
                Text(localization.localizedString("vakitler.nextPrayer").uppercased())
                    .nurFont(11, weight: .bold)
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(2)
                
                HStack(spacing: 12) {
                    Text(next.name.localizedName(for: localization.currentLanguage))
                    Text("·").foregroundColor(.white.opacity(0.3))
                    Text(next.name.arabicName)
                }
                .nurFont(34, weight: .bold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 8)
                
                Text(vm.countdown)
                    .nurFont(38, weight: .black, design: .monospaced)
                    .foregroundColor(.nurGold)
                    .shadow(color: .nurGold.opacity(0.2), radius: 10)
            }
        }
    }
    
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
    
    private func prayerTimeBox(for name: PrayerName, in prayers: PrayerTime) -> some View {
        let isNext = vm.nextPrayer?.name == name
        let time = getPrayerDate(for: name, in: prayers)
        
        return VStack(spacing: 4) {
            Text(name.localizedName(for: localization.currentLanguage))
                .nurFont(10, weight: .bold)
                .foregroundColor(.white.opacity(0.8))
            
            Text(vm.formattedTime(time, language: localization.currentLanguage))
                .nurFont(15, weight: .bold)
                .foregroundColor(isNext ? .nurGold : .white)
        }
        .frame(width: 80, height: 64)
        .background(isNext ? .black.opacity(0.3) : .white.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isNext ? Color.nurGold : Color.white.opacity(0.2), lineWidth: isNext ? 2 : 1)
        )
    }
    
    // MARK: - CONTENT CARDS SECTION
    @ViewBuilder
    private var contentCardsSection: some View {
        VStack(spacing: 24) {
            // 1. Day's Guidance (Ayah & Hadith)
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
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.nurLightGreenSecondary)
                .cornerRadius(16)
                .shadow(color: .nurLightGreenSecondary.opacity(0.2), radius: 10, y: 5)
            }
            .padding(.horizontal, 20)
            
            // 3. Dhikr Progress
            VStack(spacing: 12) {
                HStack {
                    Label(localization.localizedString("dhikr.dailyTotal"), systemImage: "bolt.heart.fill")
                        .nurFont(12, weight: .bold)
                        .foregroundColor(.nurLightGreenPrimary.opacity(0.6))
                    
                    Spacer()
                    
                    Text("\(vm.dhikrCount) / \(vm.dhikrTarget)")
                        .nurFont(12, weight: .bold, design: .monospaced)
                        .foregroundColor(.nurLightGreenPrimary)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.nurLightGreenSecondary.opacity(0.1))
                        
                        Capsule()
                            .fill(Color.nurLightGreenSecondary)
                            .frame(width: geo.size.width * CGFloat(min(1.0, Double(vm.dhikrCount) / Double(vm.dhikrTarget))))
                            .shadow(color: .nurLightGreenSecondary.opacity(0.3), radius: 4)
                    }
                }
                .frame(height: 6)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.nurLightGreenBorder, lineWidth: 1)
            )
            .padding(.horizontal, 20)
            
            // 4. Horizontal Feature Hub
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 20) {
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
        .padding(.top, 32)
    }
    
    
    private var topActionBar: some View {
        HStack {
            // Settings Button
            Button(action: {
                HapticManager.shared.light()
                dashboardVM.goToSettings()
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial.opacity(0.5))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Profile / Login Button
            Button(action: {
                HapticManager.shared.light()
                dashboardVM.goToAccount()
            }) {
                HStack(spacing: 8) {
                    Text(dashboardVM.userSession.isLoggedIn ? localization.localizedString("general.profile") : localization.localizedString("general.login"))
                        .nurFont(11, weight: .bold)
                        .foregroundColor(.white)
                        .padding(.leading, 12)
                    
                    Image(systemName: dashboardVM.userSession.isLoggedIn ? "person.fill" : "person.circle.fill")
                        .font(.system(size: dashboardVM.userSession.isLoggedIn ? 20 : 24))
                        .foregroundColor(.white)
                        .padding(dashboardVM.userSession.isLoggedIn ? 6 : 2)
                }
                .background(.black.opacity(0.2))
                .clipShape(Capsule())
            }
        }
    }
    
    private var topInfoLayer: some View {
        HStack(alignment: .top) {
            // Location
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .font(.system(size: 13))
                Text(vm.cityName)
                    .nurFont(18, weight: .bold)
            }
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.5), radius: 4)
            
            Spacer()
            
            // Date Box
            VStack(alignment: .trailing, spacing: 2) {
                Text(vm.hijriText)
                    .nurFont(16, weight: .bold)
                    .foregroundColor(.nurGold)
                
                Text(formattedGregorianDate)
                    .nurFont(11, weight: .medium)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    private var formattedGregorianDate: String {
        let f = DateFormatter()
        f.locale = localization.currentLanguage.locale
        f.dateFormat = "d MMMM yyyy"
        return f.string(from: Date())
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
}
