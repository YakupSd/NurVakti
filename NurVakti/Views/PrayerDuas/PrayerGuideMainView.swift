import SwiftUI

struct PrayerGuideMainView: View {
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
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
                        icon: "hands.sparkles.fill",
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
                .padding(20)
                .padding(.bottom, 60)
            }
        }
    }
    
    private func menuItem(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(0.12))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(localization.localizedString(title))
                        .nurFont(16, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E"))
                    
                    Text(localization.localizedString(subtitle))
                        .nurFont(12)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.25))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.025), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(CardPressableButtonStyle())
    }
}

#Preview {
    PrayerGuideMainView()
        .environmentObject(LocalizationManager.shared)
        .environmentObject(AppRouter.shared)
}
