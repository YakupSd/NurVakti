import SwiftUI

struct HomeView: View {
    @StateObject var vm: HomeViewModel
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    @State private var todayEvent: IslamicEvent? = IslamicCalendarService.shared.todayEvent()
    @State private var showEventBanner = true

    var body: some View {
        ZStack {
            // New Dynamic Premium Background
            DynamicHomeBackground(theme: vm.currentTheme)
                .ignoresSafeArea()
            
            // KATMAN 3: Güneş/Ay Yayı (Overlay)
            VStack {
                SunMoonArcView(sunPosition: vm.currentTheme.sunPosition, 
                               isMoon: vm.currentTheme.starOpacity > 0.5, 
                               theme: vm.currentTheme)
                    .offset(y: 50)
                Spacer()
            }
            .ignoresSafeArea()
            
            // KATMAN 4: İçerik
            if vm.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text(localization.localizedString("general.loading"))
                        .foregroundColor(.white)
                        .padding(.top)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // ── İSLAMİ ÖZEL GÜN BANNER ──
                        if let event = todayEvent, showEventBanner {
                            IslamicEventBanner(
                                event: event,
                                language: localization.currentLanguage
                            ) {
                                withAnimation { showEventBanner = false }
                            }
                        }

                        // ── GÖNÜL REHBERİ (Ayet/Hadis) ──
                        if let guidance = vm.dailyGuidance {
                            DailyGuidanceView(item: guidance, 
                                              language: localization.currentLanguage)
                        }

                        // ── ÜSTBAR ──
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 14))
                                    Text(vm.cityName)
                                        .nurFont(24, weight: .bold)
                                }
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                
                                Text(vm.currentTheme.ambientLabel)
                                    .nurFont(14, weight: .medium)
                                    .italic()
                                    .foregroundColor(.white.opacity(0.7))
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                            
                            Spacer()
                            
                            if let prayers = vm.todayPrayers {
                                HijriDateBadge(hijriDate: prayers.hijriDate, 
                                               miladi: Date(), 
                                               language: localization.currentLanguage, 
                                               fontSize: .medium)
                            }
                            
                            Button(action: { 
                                router.pushTo(
                                    view: MainNavigationView.builder.makeView(
                                        SettingsView(vm: SettingsViewModel()),
                                        withNavigationTitle: localization.localizedString("settings.title"),
                                        isShowRightButton: false
                                    )
                                )
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.top, 20)
                        
                        // ── COUNTDOWN RING ──
                        if let next = vm.nextPrayer {
                            VStack(spacing: 12) {
                                CountdownRing(nextPrayerName: next.name, 
                                              timeRemaining: vm.todayPrayers != nil ? next.time.timeIntervalSince(Date()) : 0, 
                                              totalInterval: 14400, // Örnek aralık
                                              language: localization.currentLanguage, 
                                              fontSize: .large)
                            }
                            .padding(.vertical, 10)
                        }
                        
                        // ── VAKİTLER LİSTESİ ──
                        NurCard(title: localization.localizedString("home.prayerTimesTitle"), icon: "timer", padding: 0) {
                            VStack(spacing: 0) {
                                if let prayers = vm.todayPrayers {
                                    ForEach(PrayerName.allCases, id: \.self) { name in
                                        PrayerTimeRow(prayer: name, 
                                                       time: prayerDate(for: name, in: prayers), 
                                                       isActive: vm.nextPrayer?.name == name, 
                                                       isPast: isPast(prayer: name, in: prayers), 
                                                       notificationEnabled: true, 
                                                       fontSize: .medium, 
                                                       language: localization.currentLanguage) {
                                            vm.toggleNotification(for: name)
                                        }
                                        
                                        if name != .isha {
                                            Divider()
                                                .background(Color.white.opacity(0.1))
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // ── QUICK ACCESS ──
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                quickAccessButton(title: localization.localizedString("menu_quran"), icon: "book.fill") {
                                    NotificationCenter.default.post(name: Notification.Name("NavigateToTab"), object: 1)
                                }
                                quickAccessButton(title: localization.localizedString("menu_calendar"), icon: "calendar") {
                                    router.pushTo(
                                        view: MainNavigationView.builder.makeView(
                                            IslamicCalendarView(),
                                            withNavigationTitle: localization.localizedString("home.calendar"),
                                            isShowRightButton: false
                                        )
                                    )
                                }
                            }
                            HStack(spacing: 12) {
                                quickAccessButton(title: localization.localizedString("menu_dhikr"), icon: "sparkles") {
                                    NotificationCenter.default.post(name: Notification.Name("NavigateToTab"), object: 2)
                                }
                                quickAccessButton(title: localization.localizedString("menu_qibla"), icon: "safari.fill") {
                                    router.pushTo(
                                        view: MainNavigationView.builder.makeView(
                                            QiblaView(),
                                            withNavigationTitle: localization.localizedString("home.qiblaShortcut"),
                                            navigationBarHidden: false,
                                            isShowRightButton: false
                                        )
                                    )
                                }
                            }
                            HStack(spacing: 12) {
                                quickAccessButton(title: localization.localizedString("menu_zakat"), icon: "dollarsign.circle.fill") {
                                    router.pushTo(
                                        view: MainNavigationView.builder.makeView(
                                            ZakatCalculatorView(),
                                            withNavigationTitle: localization.localizedString("home.zakatCalculator"),
                                            isShowRightButton: false
                                        )
                                    )
                                }
                                quickAccessButton(title: localization.localizedString("home.searchShortcut"), icon: "magnifyingglass") {
                                    NotificationCenter.default.post(name: Notification.Name("NavigateToTab"), object: 1)
                                }
                            }
                        }
                        
                        // ── TESBİHAT BUTONU ──
                        Button(action: { 
                            router.pushTo(
                                view: MainNavigationView.builder.makeView(
                                    TasbihModeView(),
                                    withNavigationTitle: "Tasbihat",
                                    navigationBarHidden: false,
                                    isShowRightButton: false
                                )
                            )
                        }) {
                            HStack {
                                Image(systemName: "hand.tap.fill")
                                Text(localization.localizedString("tasbih_start"))
                                    .nurFont(16, weight: .bold)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [.nurGold, .nurGold.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(16)
                            .shadow(color: .nurGold.opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(.top, 8)
                        
                        // ── ALT BİLGİ BANDI ──
                        Text(String(format: localization.localizedString("completed_prayers_count"), vm.completedPrayers))
                            .nurFont(12)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .task { await vm.onAppear() }
        .task {
            await IslamicCalendarService.shared.scheduleEventNotifications(
                language: localization.currentLanguage
            )
        }
        .onChange(of: localization.currentLanguage) { lang in
            vm.languageDidChange(lang)
        }
    }
    
    private func quickAccessButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .nurFont(14, weight: .bold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.1), radius: 10)
        }
    }
    
    private func prayerDate(for name: PrayerName, in prayers: PrayerTime) -> Date {
        switch name {
        case .imsak: return prayers.imsak
        case .fajr: return prayers.fajr
        case .sunrise: return prayers.sunrise
        case .dhuhr: return prayers.dhuhr
        case .asr: return prayers.asr
        case .maghrib: return prayers.maghrib
        case .isha: return prayers.isha
        }
    }
    
    private func isPast(prayer: PrayerName, in prayers: PrayerTime) -> Bool {
        let date = prayerDate(for: prayer, in: prayers)
        return date < Date()
    }
}
