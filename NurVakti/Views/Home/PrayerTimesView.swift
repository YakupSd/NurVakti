import SwiftUI

// MARK: - PrayerTimesView (Warm Luxury Spiritual Aesthetic)

struct PrayerTimesView: View {
    @ObservedObject var vm: HomeViewModel
    @EnvironmentObject var localization: LocalizationManager
    
    @State private var showQiblaSheet = false
    @State private var showCalendarSheet = false
    
    var body: some View {
        ZStack {
            // ── Background: Warm Cream Base ──
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            // ── Ambient Spiritual Golden Light Aura ──
            VStack {
                RadialGradient(
                    colors: [
                        Color.nurGold.opacity(0.14),
                        Color(hex: "EFEAE0").opacity(0.35),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 20,
                    endRadius: 360
                )
                .frame(height: 380)
                .ignoresSafeArea()
                Spacer()
            }
            
            // ── Scrollable Content ──
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    
                    // ── Header: Location Pill & Quick Action Buttons ──
                    headerBar
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    // ── Grand Next Prayer Countdown Hero Card ──
                    if let next = vm.nextPrayer {
                        nextPrayerHeroCard(next: next)
                            .padding(.horizontal, 20)
                    }
                    
                    // ── Daily Prayer Times Section Header ──
                    sectionHeader
                        .padding(.horizontal, 22)
                        .padding(.top, 4)
                    
                    // ── Prayer Rows List ──
                    if let prayers = vm.todayPrayers {
                        VStack(spacing: 6) {
                            ForEach(PrayerName.allCases, id: \.self) { name in
                                PrayerTimeRow(
                                    prayer: name,
                                    time: prayerDate(for: name, in: prayers),
                                    isActive: vm.nextPrayer?.name == name,
                                    isPast: isPrayerPast(name, in: prayers),
                                    progress: vm.prayerProgress[name],
                                    remainingTime: vm.nextPrayer?.name == name ? vm.countdown : nil,
                                    notificationEnabled: vm.isNotificationEnabled(for: name),
                                    fontSize: .medium,
                                    language: localization.currentLanguage,
                                    onNotificationToggle: {
                                        vm.toggleNotification(for: name)
                                        HapticManager.shared.light()
                                    }
                                )
                            }
                        }
                    } else {
                        loadingStateView
                    }
                    
                    // ── Inspirational Footer Quote ──
                    inspirationalCard
                        .padding(.horizontal, 20)
                        .padding(.top, 6)
                        .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .task { await vm.onAppear() }
        .sheet(isPresented: $showQiblaSheet) {
            QiblaView()
                .environmentObject(localization)
        }
        .sheet(isPresented: $showCalendarSheet) {
            IslamicCalendarView()
                .environmentObject(localization)
        }
    }
    
    // MARK: - Header Bar
    private var headerBar: some View {
        VStack(spacing: 8) {
            HStack {
                // Location Pill
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.nurGold)
                    
                    Text(vm.cityName.isEmpty ? "···" : vm.cityName)
                        .nurFont(18, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
                
                Spacer()
                
                // Quick Actions (Qibla & Calendar)
                HStack(spacing: 8) {
                    Button(action: {
                        HapticManager.shared.light()
                        showQiblaSheet = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                            Image(systemName: "location.north.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.nurGold)
                        }
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    Button(action: {
                        HapticManager.shared.light()
                        showCalendarSheet = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                            Image(systemName: "calendar")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.75))
                        }
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
            
            // Date subtitle
            HStack(spacing: 6) {
                if let prayers = vm.todayPrayers {
                    Text(prayers.hijriDate.formatted(for: localization.currentLanguage))
                        .nurFont(13, weight: .medium)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                    
                    Text("•")
                        .foregroundColor(.nurGold)
                        .font(.system(size: 12))
                }
                
                Text(localizedDate())
                    .nurFont(13, weight: .medium)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                
                Spacer()
            }
            .padding(.horizontal, 4)
        }
    }
    
    // MARK: - Grand Next Prayer Countdown Hero Card
    private func nextPrayerHeroCard(next: (name: PrayerName, time: Date)) -> some View {
        VStack(spacing: 16) {
            // Top row: Category tag & Symbol
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: next.name.symbol)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.nurGold)
                    
                    Text(NSLocalizedString("vakitler.nextPrayer", comment: "").uppercased())
                        .nurFont(11, weight: .bold)
                        .foregroundColor(Color(hex: "A37D1D"))
                        .tracking(1.5)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.nurGold.opacity(0.12))
                .cornerRadius(10)
                
                Spacer()
                
                Text(timeFormatter.string(from: next.time))
                    .nurFont(15, weight: .bold, design: .rounded)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.75))
            }
            
            // Middle row: Prayer Name & Big Countdown
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(next.name.localizedName(for: localization.currentLanguage))
                        .nurFont(28, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E"))
                    
                    Text(next.name.arabicName)
                        .font(.custom("Amiri-Bold", size: 16))
                        .foregroundColor(Color.nurGold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(vm.countdown)
                        .nurFont(30, weight: .bold, design: .monospaced)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "D4AF37"), Color(hex: "A07818")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text(NSLocalizedString("prayer.remaining", comment: ""))
                        .nurFont(11, weight: .medium)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.45))
                }
            }
            
            // Progress Bar
            if let p = vm.prayerProgress[next.name] {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.nurGold.opacity(0.12))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.nurGold, Color(hex: "E5C158")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(10, geo.size.width * CGFloat(p)), height: 6)
                            .shadow(color: .nurGold.opacity(0.35), radius: 3)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(20)
        .background(
            ZStack {
                Color.white
                LinearGradient(
                    colors: [Color.white, Color(hex: "FFFDF9")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.white, Color.nurGold.opacity(0.35), Color.white.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Color(hex: "1A1A2E").opacity(0.05), radius: 16, y: 6)
        .shadow(color: Color.nurGold.opacity(0.06), radius: 8, y: 2)
    }
    
    // MARK: - Section Header
    private var sectionHeader: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "clock.badge.checkmark.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.nurGold)
                
                Text(NSLocalizedString("vakitler.title", comment: "").uppercased())
                    .nurFont(12, weight: .bold)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.75))
                    .tracking(1.5)
            }
            
            Spacer()
            
            if let prayers = vm.todayPrayers {
                let done = PrayerName.allCases.filter { isPrayerPast($0, in: prayers) }.count
                Text("\(done)/\(PrayerName.allCases.count) \(NSLocalizedString("prayer.completed", comment: ""))")
                    .nurFont(11, weight: .bold)
                    .foregroundColor(Color(hex: "2D8B56"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "2D8B56").opacity(0.08))
                    .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Inspirational Quote Card
    private var inspirationalCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.nurGold.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: "sparkles")
                    .font(.system(size: 17))
                    .foregroundColor(.nurGold)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(localization.currentLanguage == .tr ? "Namaz dinin direğidir" : "Prayer is the pillar of faith")
                    .nurFont(14, weight: .bold)
                    .foregroundColor(Color(hex: "1A1A2E"))
                
                Text(localization.currentLanguage == .tr ? "Vaktinde kılınan namaz, amellerin en faziletlisidir." : "Performing prayer on time is the most virtuous of deeds.")
                    .nurFont(12)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
    }
    
    // MARK: - Loading View
    private var loadingStateView: some View {
        VStack(spacing: 14) {
            ProgressView().tint(.nurGold)
            Text(NSLocalizedString("general.loading", comment: ""))
                .nurFont(13)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.4))
        }
        .padding(.top, 40)
    }
    
    // MARK: - Helpers
    private func prayerDate(for name: PrayerName, in prayers: PrayerTime) -> Date {
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
    
    private func isPrayerPast(_ name: PrayerName, in prayers: PrayerTime) -> Bool {
        Date() > prayerDate(for: name, in: prayers)
    }
    
    private func localizedDate() -> String {
        let f = DateFormatter()
        f.locale = localization.currentLanguage.locale
        f.dateStyle = .long
        f.timeStyle = .none
        return f.string(from: Date())
    }
    
    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }
}

#Preview {
    PrayerTimesView(vm: HomeViewModel.shared)
        .environmentObject(LocalizationManager.shared)
}
