import SwiftUI

struct PrayerDuasView: View {
    @EnvironmentObject var localization: LocalizationManager
    let duas = PrayerGuideData.getNamazDuas()
    
    var body: some View {
        ZStack {
            Color(hex: "0F172A").ignoresSafeArea()
            
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
