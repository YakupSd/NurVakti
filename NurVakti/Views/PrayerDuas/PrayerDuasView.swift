import SwiftUI

struct PrayerDuasView: View {
    @EnvironmentObject var localization: LocalizationManager
    
    let duas = PrayerGuideData.getNamazDuas()
    
    var body: some View {
        ZStack {
            // Arka plan
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // ── Header Banner ──────────────────────────────────
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.nurGold.opacity(0.12))
                                .frame(width: 80, height: 80)
                            Image(systemName: "hands.sparkles.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.nurGold)
                        }
                        
                        Text(localization.localizedString("prayerGuide.duas"))
                            .nurFont(24, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                        
                        Text(localization.localizedString("prayerGuide.duasSubtitle"))
                            .nurFont(14)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.55))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 28)
                    .padding(.horizontal, 24)
                    
                    // ── Bölüm Başlığı ──────────────────────────────────
                    HStack {
                        Rectangle()
                            .fill(Color.nurGold.opacity(0.4))
                            .frame(width: 4, height: 18)
                            .cornerRadius(2)
                        Text(localization.localizedString("prayerGuide.prayerDuasSection"))
                            .nurFont(13, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                            .tracking(1.5)
                            .textCase(.uppercase)
                        Spacer()
                        Text("\(duas.count)")
                            .nurFont(12, weight: .bold)
                            .foregroundColor(.nurGold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.nurGold.opacity(0.12))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                    
                    // ── Dua Kartları ───────────────────────────────────
                    if duas.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.2))
                            Text(localization.localizedString("general.noContent"))
                                .nurFont(15)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.4))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(duas) { dua in
                                DuaCard(dua: dua, language: localization.currentLanguage)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                    
                    Spacer(minLength: 60)
                }
            }
        }
    }
}
