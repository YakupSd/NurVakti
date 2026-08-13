import SwiftUI

// MARK: - PrayerTimesView (Premium Sky Blend)

struct PrayerTimesView: View {
    @ObservedObject var vm: HomeViewModel
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // ── Layer 1: Real-time sky, full screen ───────────────
            SkySimulationView(prayerTimes: vm.todayPrayers)
                .ignoresSafeArea()
            
            // ── Layer 2: Long bottom-up dark fade (Apple Music style)
            VStack {
                Spacer()
                LinearGradient(
                    colors: [
                        .clear,
                        Color(hex: "050A15").opacity(0.3),
                        Color(hex: "050A15").opacity(0.75),
                        Color(hex: "050A15").opacity(0.96),
                        Color(hex: "050A15")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: UIScreen.main.bounds.height * 0.72)
            }
            .ignoresSafeArea()
            
            // ── Layer 3: Top status bar shade ────────────────────
            LinearGradient(
                colors: [.black.opacity(0.4), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 90)
            .ignoresSafeArea()
            
            // ── Layer 4: Scrollable content ───────────────────────
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // ── Hero spacer (gökyüzü görünsün) ────────────
                    Spacer().frame(height: UIScreen.main.bounds.height * 0.28)
                    
                    // ── City + Dates ───────────────────────────────
                    VStack(spacing: 5) {
                        HStack(spacing: 5) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                            Text(vm.cityName.isEmpty ? "···" : vm.cityName)
                                .nurFont(28, weight: .bold)
                                .foregroundColor(Color(hex: "1A1A2E"))
                        }
                        .shadow(color: .black.opacity(0.5), radius: 6)
                        
                        HStack(spacing: 6) {
                            if let prayers = vm.todayPrayers {
                                Text(prayers.hijriDate.formatted(for: localization.currentLanguage))
                                    .nurFont(13)
                                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                                Text("·").foregroundColor(Color(hex: "1A1A2E").opacity(0.2))
                            }
                            Text(localizedDate())
                                .nurFont(13)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                    
                    // ── Next Prayer Countdown ─────────────────────
                    if let next = vm.nextPrayer {
                        nextPrayerCard(next: next)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 32)
                    }
                    
                    // ── Section Divider ───────────────────────────
                    HStack {
                        Text(NSLocalizedString("vakitler.title", comment: "").uppercased())
                            .nurFont(11, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.25))
                            .tracking(2.5)
                        Spacer()
                        if let prayers = vm.todayPrayers {
                            let done = PrayerName.allCases.filter { isPrayerPast($0, in: prayers) }.count
                            Text("\(done)/\(PrayerName.allCases.count)")
                                .nurFont(12, weight: .semibold)
                                .foregroundColor(.nurGold.opacity(0.5))
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 12)
                    
                    // ── Prayer Rows ───────────────────────────────
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
                        VStack(spacing: 14) {
                            ProgressView().tint(.nurGold)
                            Text(NSLocalizedString("general.loading", comment: ""))
                                .nurFont(13)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.3))
                        }
                        .padding(.top, 40)
                    }
                    
                    Spacer().frame(height: 110)
                }
            }
        }
        .navigationBarHidden(true)
        .task { await vm.onAppear() }
    }
    
    // MARK: - Next Prayer Card
    
    private func nextPrayerCard(next: (name: PrayerName, time: Date)) -> some View {
        HStack(spacing: 0) {
            // Left: Prayer name
            VStack(alignment: .leading, spacing: 5) {
                Text(NSLocalizedString("vakitler.nextPrayer", comment: "").uppercased())
                    .nurFont(9, weight: .bold)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.35))
                    .tracking(1.5)
                Text(next.name.localizedName(for: localization.currentLanguage))
                    .nurFont(22, weight: .bold)
                    .foregroundColor(Color(hex: "1A1A2E"))
            }
            
            Spacer()
            
            // Thin separator
            Rectangle()
                .fill(ColorColor(hex: "1A1A2E").opacity(0.12))
                .frame(width: 1, height: 38)
                .padding(.horizontal, 18)
            
            // Right: Countdown
            VStack(alignment: .trailing, spacing: 3) {
                Text(vm.countdown)
                    .nurFont(24, weight: .bold, design: .monospaced)
                    .foregroundColor(.nurGold)
                    .shadow(color: .nurGold.opacity(0.4), radius: 10)
                Text(NSLocalizedString("prayer.remaining", comment: ""))
                    .nurFont(10)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.35))
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 17)
        .background(
            ZStack {
                // Glass base
                RoundedRectangle(cornerRadius: 22)
                    .fill(.ultraThinMaterial)
                
                // Subtle gold tint
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color.nurGold.opacity(0.08), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(ColorColor(hex: "1A1A2E").opacity(0.14), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 24, y: 10)
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
}

#Preview {
    PrayerTimesView(vm: HomeViewModel.shared)
        .environmentObject(LocalizationManager.shared)
}
