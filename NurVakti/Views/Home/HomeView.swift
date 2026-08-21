import SwiftUI

struct HomeView: View {
    @ObservedObject var vm: HomeViewModel
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var library: DuaLibraryService
    
    @State private var selectedShareContent: DailyContent?
    @State private var selectedSpiritualMessage: SpiritualMessage?
    @State private var activeRoutineSlot: RoutineSlot = .none
    @State private var showLibrary = false
    
    let skyView: AnyView
    
    init(skyView: AnyView, vm: HomeViewModel) {
        self.skyView = skyView
        self._vm = ObservedObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Layer 1: Sky simulation (existing, passed in)
            skyView
                .ignoresSafeArea()
            
            // Top shadow gradient for visibility
            LinearGradient(colors: [.black.opacity(0.35), .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: 120)
                .ignoresSafeArea()
            
            // Layer 2: Scrollable content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // ── Offline Banner ──────────────────────────────
                    if vm.isOffline {
                        HStack(spacing: 8) {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 13, weight: .bold))
                            Text(LocalizationManager.shared.localizedString("general.offline"))
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "8A5A00").opacity(0.85))
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: vm.isOffline)
                    }
                    // ── Location Error Banner ──────────────────────
                    if let errMsg = vm.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "location.slash.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text(errMsg)
                                .font(.system(size: 13, weight: .bold))
                                .lineLimit(1)
                            Spacer()
                            Button(action: { vm.errorMessage = nil }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 11, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "C44536").opacity(0.85))
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: vm.errorMessage)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                vm.errorMessage = nil
                            }
                        }
                    }
                    SkyHeroSection()
                    PrayerMiniStrip()
                    
                    VStack(spacing: 20) {
                        // ── Friday / Special Day Banner ──
                        if let specialTitle = SpiritualMessageService.shared.todaysSpecialBannerTitle {
                            FridayOrSpecialDayBanner(title: specialTitle)
                                .padding(.horizontal, 14)
                        }
                        
                        FavouritesStrip()
                            .padding(.horizontal, 14)
                        
                        if vm.currentRoutineSlot != .none {
                            DailyRoutineCard(
                                slot: vm.currentRoutineSlot,
                                items: vm.currentRoutineSlot == .morning ? library.morningRoutine : library.eveningRoutine,
                                completedCount: vm.currentRoutineSlot == .morning ? library.morningCompletedCount : library.eveningCompletedCount
                            )
                        }
                        
                        ContentCardsSection()
                    }
                    .padding(.top, 10)
                }
            }
            
            // Layer 3: Custom Loading Overlay
            if vm.isLoading {
                NurLoadingView()
                    .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                    .zIndex(100) // Ensure it stays on top
            }
        }
        .task { await vm.onAppear() }
        .sheet(isPresented: $showLibrary) {
            DuaLibraryView(initialMode: activeRoutineSlot == .none ? .browse : .pickRoutine(activeRoutineSlot))
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenDuaLibrary"))) { note in
            if let slot = note.object as? RoutineSlot {
                activeRoutineSlot = slot
                showLibrary = true
            }
        }
        .sheet(item: $selectedShareContent) { content in
            GuidanceShareSheet(content: content)
        }
        .sheet(item: $selectedSpiritualMessage) { msg in
            SpiritualShareSheet(message: msg)
        }
    }
    
    // MARK: - SECTION 1: SkyHeroSection
    @ViewBuilder
    private func SkyHeroSection() -> some View {
        VStack(spacing: 20) {
            // Top Bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 14))
                    Text(vm.cityName)
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(Color(hex: "1A1A2E"))
                .shadow(color: .black.opacity(0.4), radius: 3)
                
                Spacer()
                
                if let prayers = vm.todayPrayers {
                    HijriDateBadge(hijriDate: prayers.hijriDate, 
                                   miladi: Date(), 
                                   language: localization.currentLanguage, 
                                   fontSize: .medium)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Center Hero
            VStack(spacing: 4) {
                Text(localization.localizedString("home.nextPrayer").uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .kerning(3)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.9))
                    .shadow(color: .black.opacity(0.5), radius: 2)
                
                if let next = vm.nextPrayer {
                    HStack(spacing: 10) {
                        Text(localization.localizedString("prayer.\(next.name.rawValue)"))
                        Text("·")
                        Text(next.name.arabicName)
                    }
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color(hex: "1A1A2E"))
                    .shadow(color: .black.opacity(0.4), radius: 4)
                }
                
                Text(vm.countdown)
                    .font(.system(size: 20, design: .monospaced).monospacedDigit())
                    .fontWeight(.bold)
                    .foregroundColor(.nurGold)
                    .shadow(color: .nurGold.opacity(0.3), radius: 6)
                    .padding(.top, 4)
            }
            .shadow(color: .black.opacity(0.5), radius: 4)
            .padding(.top, 10)
        }
        .frame(height: 200)
    }
    
    // MARK: - SECTION 2: PrayerMiniStrip
    @ViewBuilder
    private func PrayerMiniStrip() -> some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    if let prayers = vm.todayPrayers {
                        ForEach(PrayerName.allCases, id: \.self) { name in
                            PrayerPillView(
                                name: name,
                                time: vm.formattedTime(prayerDate(for: name, in: prayers), language: localization.currentLanguage),
                                isActive: vm.nextPrayer?.name == name
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 60)
            .background(Color.white)
            
            HStack(spacing: 8) {
                Text(String(format: localization.localizedString("home.completedToday"), vm.completedPrayers))
                Text("·")
                Text(localization.localizedString("home.allCompleted") + " →")
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(Color(hex: "1A1A2E"))
            .shadow(color: .black.opacity(0.5), radius: 4)
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .background(Color(hex: "1A1A2E").opacity(0.1))
            .cornerRadius(20)
            .onTapGesture {
                HapticManager.shared.tap()
                NotificationCenter.default.post(name: Notification.Name("NavigateToTab"), object: 1)
            }
        }
    }
    
    // MARK: - SECTION 3: ContentCardsSection
    @ViewBuilder
    private func ContentCardsSection() -> some View {
        VStack(spacing: 12) {
            // Card A: Günün Ayeti
            NurCardWithHeader(
                title: localization.localizedString("guidance.dailyAyat"),
                icon: "sparkles",
                content: vm.dailyAyah
            )
            
            // Card B: Günün Duası
            NurCardWithHeader(
                title: localization.localizedString("guidance.dailyHadith"),
                icon: "hands.sparkles.fill",
                content: vm.dailyDua
            )
            
            // Card C: Günün Hikmetli Sözü
            DailyWisdomCard()
            
            // Tesbihat Button
            Button(action: { 
                HapticManager.shared.tap()
                router.pushTo(view: MainNavigationView.builder.makeView(
                    TesbihatView(),
                    withNavigationTitle: "Tesbihat"
                ))
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "circle.grid.3x3.fill")
                        .font(.system(size: 16))
                    Text(localization.localizedString("tasbih_start"))
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(Color(hex: "1A1A2E"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#C9A84C"), Color(hex: "#8B6914")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 14)
            
            // Zikir Progress Row
            VStack(spacing: 12) {
                HStack {
                    Label(localization.localizedString("dhikr.dailyTotal"), systemImage: "bolt.heart.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                    
                    Spacer()
                    
                    Text("\(vm.dhikrCount) / \(vm.dhikrTarget)")
                        .font(.system(size: 12, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.nurGold)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "1A1A2E").opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.nurGold, .nurGold.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(vm.dhikrProgress))
                            .shadow(color: .nurGold.opacity(0.3), radius: 4)
                    }
                }
                .frame(height: 6)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "1A1A2E").opacity(0.05), lineWidth: 1)
            )
            .padding(.horizontal, 14)
            
            // Quick Access Grid — Tüm özellikler
            VStack(spacing: 8) {
                // Row 1: Namaz ile ilgili
                HStack(spacing: 8) {
                    QuickAccessCard(
                        icon: "figure.stand",
                        iconBg: Color(hex: "#1A6B4A").opacity(0.35),
                        title: localization.localizedString("prayerGuide.howToPray"),
                        subtitle: localization.localizedString("guidance.prayerSteps"),
                        action: { 
                            router.pushTo(view: MainNavigationView.builder.makeView(
                                HowToPrayView(),
                                withNavigationTitle: localization.localizedString("prayerGuide.howToPray")
                            ))
                        }
                    )
                    QuickAccessCard(
                        icon: "text.book.closed.fill",
                        iconBg: Color(hex: "#3D2B8A").opacity(0.35),
                        title: localization.localizedString("prayerGuide.title"),
                        subtitle: localization.localizedString("guidance.namazGuide"),
                        action: { 
                            router.pushTo(view: MainNavigationView.builder.makeView(
                                PrayerGuideMainView(),
                                withNavigationTitle: localization.localizedString("prayerGuide.title")
                            ))
                        }
                    )
                }
                
                // Row 2: Dualar
                HStack(spacing: 8) {
                    QuickAccessCard(
                        icon: "hands.sparkles.fill",
                        iconBg: Color(hex: "#8B3A62").opacity(0.35),
                        title: localization.localizedString("prayerGuide.duas"),
                        subtitle: localization.localizedString("guidance.namazDuas"),
                        action: { 
                            router.pushTo(view: MainNavigationView.builder.makeView(
                                PrayerDuasView(),
                                withNavigationTitle: localization.localizedString("prayerGuide.duas")
                            ))
                        }
                    )
                    QuickAccessCard(
                        icon: "arrow.turn.down.right",
                        iconBg: Color(hex: "#2E5C8A").opacity(0.35),
                        title: localization.localizedString("prayerGuide.postPrayer"),
                        subtitle: localization.localizedString("guidance.afterPrayer"),
                        action: { 
                            router.pushTo(view: MainNavigationView.builder.makeView(
                                PostPrayerDuasView(),
                                withNavigationTitle: localization.localizedString("prayerGuide.postPrayer")
                            ))
                        }
                    )
                }
                
                // Row 3: Araçlar
                HStack(spacing: 8) {
                    QuickAccessCard(
                        icon: "sparkles.rectangle.stack.fill",
                        iconBg: Color(hex: "5D3FD3").opacity(0.3),
                        title: localization.localizedString("prayerGuide.monthlySpecial"),
                        subtitle: localization.localizedString("guidance.specialDays"),
                        action: { 
                            router.pushTo(view: MainNavigationView.builder.makeView(
                                SpecialPrayersView(),
                                withNavigationTitle: localization.localizedString("prayerGuide.monthlySpecial")
                            ))
                        }
                    )
                    QuickAccessCard(
                        icon: "location.north.fill",
                        iconBg: Color(hex: "185FA5").opacity(0.3),
                        title: localization.localizedString("home.qiblaShortcut"),
                        subtitle: vm.qiblaDirectionText,
                        action: { 
                            router.pushTo(view: MainNavigationView.builder.makeView(
                                QiblaView(),
                                withNavigationTitle: localization.localizedString("home.qiblaShortcut")
                            ))
                        }
                    )
                }
                
                // Row 4: Daha fazla
                HStack(spacing: 8) {
                    QuickAccessCard(
                        icon: "calendar.badge.clock",
                        iconBg: Color.nurGold.opacity(0.2),
                        title: localization.localizedString("home.calendar"),
                        subtitle: vm.nextReligiousDay,
                        action: { 
                            router.pushTo(view: MainNavigationView.builder.makeView(
                                IslamicCalendarView(),
                                withNavigationTitle: localization.localizedString("home.calendar")
                            ))
                        }
                    )
                    QuickAccessCard(
                        icon: "sparkles",
                        iconBg: Color.nurOlive.opacity(0.2),
                        title: "Esmaü'l-Hüsna",
                        subtitle: "Allah'ın 99 İsmi",
                        action: { 
                            router.pushTo(view: MainNavigationView.builder.makeView(
                                EsmaulHusnaView(),
                                withNavigationTitle: "Esmaü'l-Hüsna"
                            ))
                        }
                    )
                }
                
                // Row 5: Manevi Mesajlar & Zekât
                HStack(spacing: 8) {
                    QuickAccessCard(
                        icon: "envelope.badge.fill",
                        iconBg: Color.nurGold.opacity(0.3),
                        title: "Manevi Mesajlar",
                        subtitle: "Cuma, Kandil, Bayram",
                        action: { 
                            router.pushTo(view: MainNavigationView.builder.makeView(
                                SpiritualMessagesView(),
                                withNavigationTitle: "Manevi Mesajlar"
                            ))
                        }
                    )
                    QuickAccessCard(
                        icon: "scalemass.fill",
                        iconBg: Color(hex: "B8860B").opacity(0.3),
                        title: localization.localizedString("home.zakatCalculator"),
                        subtitle: localization.localizedString("guidance.zakatDesc"),
                        action: { 
                            router.pushTo(view: MainNavigationView.builder.makeView(
                                ZakatCalculatorView(),
                                withNavigationTitle: localization.localizedString("home.zakatCalculator")
                            ))
                        }
                    )
                }
            }
            .padding(.horizontal, 14)
        }
        .padding(.top, 40)
        .padding(.bottom, 150) // More space for tab bar
        .background(
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [.clear, NurTheme.background],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
                
                NurTheme.background
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .offset(y: -50)
            .padding(.bottom, -1000) // Deep floor to ensure no gaps ever
        )
    }
    
    // MARK: - Sub-Components
    private func PrayerPillView(name: PrayerName, time: String, isActive: Bool) -> some View {
        VStack(spacing: 3) {
            Text(localization.localizedString("prayer.\(name.rawValue)"))
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(isActive ? .nurGold : Color(hex: "1A1A2E").opacity(0.5))
            
            Text(time)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.nurGold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? Color.nurGold.opacity(0.1) : Color(hex: "1A1A2E").opacity(0.05))
                
                if isActive {
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.nurGold.opacity(0.15))
                            .frame(width: geo.size.width * CGFloat(vm.prayerProgress[name] ?? 0))
                    }
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isActive ? Color.nurGold.opacity(0.4) : Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1)
        )
    }
    
    private func NurCardWithHeader(title: String, icon: String, content: DailyContent) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title.uppercased(), systemImage: icon)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                    .tracking(1.5)
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Copy Button
                    Button(action: { 
                        HapticManager.shared.light()
                        UIPasteboard.general.string = content.translation(for: localization.currentLanguage) 
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                            .padding(6)
                            .background(Color(hex: "1A1A2E").opacity(0.1))
                            .clipShape(Circle())
                    }

                    Button(action: { 
                        HapticManager.shared.tap()
                        selectedShareContent = content 
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 10))
                            Text(localization.localizedString("general.share"))
                                .font(.system(size: 9, weight: .medium))
                        }
                        .foregroundColor(.nurGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.nurGold.opacity(0.12))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.nurGold.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            
            Text(content.arabicText)
                .font(.custom("KFGQPCUthmanicScriptHAFS", size: 16))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)
                .foregroundColor(Color(hex: "1A1A2E"))
                .lineSpacing(6)
            
            Divider().opacity(0.15).padding(.vertical, 6)
            
            Text(content.translation(for: localization.currentLanguage))
                .font(.system(size: 12, weight: .light))
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                .italic()
                .lineSpacing(3)
            
            Text(content.source)
                .font(.system(size: 9))
                .foregroundColor(.nurGold.opacity(0.7))
                .padding(.top, 4)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "1A1A2E").opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 14)
    }
    
    private func FridayOrSpecialDayBanner(title: String) -> some View {
        Button(action: {
            HapticManager.shared.tap()
            let initialCat: SpiritualCategory = SpiritualMessageService.shared.isTodayFriday ? .friday : .kandil
            router.pushTo(view: MainNavigationView.builder.makeView(
                SpiritualMessagesView(initialCategory: initialCat),
                withNavigationTitle: "Manevi Mesajlar"
            ))
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#FFE58F"), Color(hex: "#D4AF37")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 38, height: 38)
                    Image(systemName: "sparkles")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(hex: "#0E1626"))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A2E"))
                    Text("Özel tebrik ve duaları paylaşmak için dokunun →")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "#1A1A2E").opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.nurGold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.white, Color(hex: "#FFFBF0")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.nurGold.opacity(0.6), Color.nurGold.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.nurGold.opacity(0.12), radius: 8, y: 3)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func DailyWisdomCard() -> some View {
        let wisdom = SpiritualMessageService.shared.dynamicWisdomMessage ?? SpiritualMessageService.shared.todaysFeaturedMessage()
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("GÜNÜN HİKMETLİ SÖZÜ", systemImage: "quote.opening")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                    .tracking(1.5)
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Copy
                    Button(action: {
                        HapticManager.shared.light()
                        UIPasteboard.general.string = wisdom.formattedShareText
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                            .padding(6)
                            .background(Color(hex: "1A1A2E").opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    // Story Share
                    Button(action: {
                        HapticManager.shared.tap()
                        selectedSpiritualMessage = wisdom
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 10))
                            Text(localization.localizedString("general.share"))
                                .font(.system(size: 9, weight: .medium))
                        }
                        .foregroundColor(.nurGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.nurGold.opacity(0.12))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.nurGold.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            
            Text(wisdom.text)
                .font(.system(size: 13, weight: .regular, design: .serif))
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.85))
                .lineSpacing(4)
            
            if let author = wisdom.authorOrSource, !author.isEmpty {
                Text("— \(author)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.nurGold)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "1A1A2E").opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 14)
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
}
