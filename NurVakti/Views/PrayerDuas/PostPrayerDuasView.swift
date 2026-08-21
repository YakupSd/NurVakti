import SwiftUI

struct PostPrayerDuasView: View {
    @EnvironmentObject var localization: LocalizationManager
    
    let duas = PrayerGuideData.getPostPrayerDuas()
    
    var body: some View {
        ZStack {
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // ── Header Banner ──────────────────────────────────
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "2E5C8A").opacity(0.10))
                                .frame(width: 80, height: 80)
                            Image(systemName: "arrow.turn.down.right")
                                .font(.system(size: 32))
                                .foregroundColor(Color(hex: "2E5C8A"))
                        }
                        
                        Text(localization.localizedString("prayerGuide.postPrayer"))
                            .nurFont(24, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                        
                        Text(localization.localizedString("prayerGuide.postPrayerSubtitle"))
                            .nurFont(14)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.55))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 28)
                    .padding(.horizontal, 24)
                    
                    // ── Öneri Kartı ────────────────────────────────────
                    HStack(spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.nurGold)
                        Text(localization.localizedString("prayerGuide.postPrayerTip"))
                            .nurFont(13)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(Color.nurGold.opacity(0.07))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.nurGold.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // ── Bölüm Başlığı ──────────────────────────────────
                    HStack {
                        Rectangle()
                            .fill(Color(hex: "2E5C8A").opacity(0.5))
                            .frame(width: 4, height: 18)
                            .cornerRadius(2)
                        Text(localization.localizedString("prayerGuide.postPrayerSection"))
                            .nurFont(13, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                            .tracking(1.5)
                            .textCase(.uppercase)
                        Spacer()
                        Text("\(duas.count)")
                            .nurFont(12, weight: .bold)
                            .foregroundColor(Color(hex: "2E5C8A"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(hex: "2E5C8A").opacity(0.10))
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
