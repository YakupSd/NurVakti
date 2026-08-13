import SwiftUI

struct PostPrayerDuasView: View {
    @EnvironmentObject var localization: LocalizationManager
    let duas = PrayerGuideData.getPostPrayerDuas()
    
    var body: some View {
        ZStack {
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(duas) { dua in
                        DuaCard(dua: dua, language: localization.currentLanguage)
                    }
                }
                .padding()
            }
        }
    }
}
