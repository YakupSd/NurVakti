import SwiftUI

struct SpecialPrayersView: View {
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var monthlyService: MonthlyDuaService
    @StateObject private var audioManager = AudioManager.shared
    
    private let currentMonth = PrayerGuideData.getCurrentHijriMonth()
    private let seasonalDuas = PrayerGuideData.getSeasonalPrayers()
    private let eidSteps = PrayerGuideData.getEidPrayerSteps()
    
    var body: some View {
        ZStack {
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.nurGold)
                        
                        Text(currentMonth.name[localization.currentLanguage.rawValue] ?? "")
                            .nurFont(24, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                        
                        Text(localization.localizedString("prayerGuide.specialForMonth"))
                            .nurFont(14)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                    }
                    .padding(.top, 20)
                    
                    // Dynamic Monthly Duas
                    VStack(alignment: .leading, spacing: 16) {
                        Text(localization.localizedString("prayerGuide.specialForMonth"))
                            .nurFont(18, weight: .bold)
                            .foregroundColor(.nurGold)
                            .padding(.horizontal)
                        
                        if monthlyService.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .tint(.nurGold)
                                Spacer()
                            }
                            .padding(.vertical, 20)
                        } else if monthlyService.monthlyDuas.isEmpty {
                            Text(localization.localizedString("error.network")) // Or appropriate empty message
                                .nurFont(14)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                                .padding(.horizontal)
                        } else {
                            ForEach(monthlyService.monthlyDuas) { dua in
                                DuaCard(dua: dua, language: localization.currentLanguage)
                            }
                        }
                    }
                    
                    // Seasonal / Hardcoded Duas section
                    if !seasonalDuas.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(localization.localizedString("prayerGuide.specialDuas"))
                                .nurFont(18, weight: .bold)
                                .foregroundColor(.nurGold)
                                .padding(.horizontal)
                            
                            ForEach(seasonalDuas) { dua in
                                DuaCard(dua: dua, language: localization.currentLanguage)
                            }
                        }
                    }
                    
                    // Eid Prayer Guidance (if relevant)
                    if currentMonth == .ramadan || currentMonth == .shawwal || currentMonth == .dhuAlHijjah {
                        VStack(alignment: .leading, spacing: 16) {
                            Divider().background(Color(hex: "1A1A2E").opacity(0.1))
                                .padding(.vertical, 10)
                            
                            Text(localization.localizedString("prayerGuide.howToEidPrayer"))
                                .nurFont(18, weight: .bold)
                                .foregroundColor(.nurGold)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(0..<eidSteps.count, id: \.self) { index in
                                    PrayerStepCard(step: eidSteps[index], index: index, language: localization.currentLanguage)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
        }
        .task {
            await monthlyService.refreshIfNeeded()
        }
    }
}
