import SwiftUI

struct PrayerGuideMainView: View {
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        ZStack {
            Color(hex: "0F172A").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    menuItem(
                        title: "prayerGuide.howToPray",
                        subtitle: "prayerGuide.howToPray.desc",
                        icon: "figure.pray",
                        color: .blue
                    ) {
                        router.pushTo(view: MainNavigationView.builder.makeView(
                            HowToPrayView(),
                            withNavigationTitle: localization.localizedString("prayerGuide.howToPray")
                        ))
                    }
                    
                    menuItem(
                        title: "prayerGuide.duas",
                        subtitle: "prayerGuide.duas.desc",
                        icon: "hand.raised.fill",
                        color: .nurGold
                    ) {
                        router.pushTo(view: MainNavigationView.builder.makeView(
                            PrayerDuasView(),
                            withNavigationTitle: localization.localizedString("prayerGuide.duas")
                        ))
                    }
                    
                    menuItem(
                        title: "prayerGuide.tasbih",
                        subtitle: "prayerGuide.tasbih.desc",
                        icon: "circle.grid.3x3.fill",
                        color: .green
                    ) {
                        router.pushTo(view: MainNavigationView.builder.makeView(
                            TesbihatView(),
                            withNavigationTitle: "Tesbihat"
                        ))
                    }
                    
                    menuItem(
                        title: "prayerGuide.postPrayer",
                        subtitle: "prayerGuide.postPrayer.desc",
                        icon: "sparkles",
                        color: .purple
                    ) {
                        router.pushTo(view: MainNavigationView.builder.makeView(
                            PostPrayerDuasView(),
                            withNavigationTitle: localization.localizedString("prayerGuide.postPrayer")
                        ))
                    }
                    
                    menuItem(
                        title: "prayerGuide.monthlySpecial",
                        subtitle: "prayerGuide.monthlySpecial.desc",
                        icon: "calendar.badge.clock",
                        color: .orange
                    ) {
                        router.pushTo(view: MainNavigationView.builder.makeView(
                            SpecialPrayersView(),
                            withNavigationTitle: localization.localizedString("prayerGuide.monthlySpecial")
                        ))
                    }
                }
                .padding()
            }
        }
    }
    
    private func menuItem(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(localization.localizedString(title))
                        .nurFont(20, weight: .bold)
                        .foregroundColor(.white)
                    
                    Text(localization.localizedString(subtitle))
                        .nurFont(14)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(20)
            .background(Color.white.opacity(0.05))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}
