import SwiftUI

struct DuaCard: View {
    let dua: PrayerDua
    let language: LanguageCode
    
    @StateObject private var audioManager = AudioManager.shared
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(dua.title(for: language))
                    .nurFont(18, weight: .bold)
                    .foregroundColor(.nurGold)
                
                Spacer()
                
                if let audio = dua.audioFileName {
                    Button(action: {
                        HapticManager.shared.light()
                        if audioManager.isPlaying {
                            audioManager.stop()
                        } else {
                            audioManager.playPrayerDua(dua)
                        }
                    }) {
                        Image(systemName: audioManager.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.nurGold)
                    }
                }
            }
            
            Text(dua.arabicText)
                .dynamicArabicFont(text: dua.arabicText, baseSize: 28)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(.white)
                .lineSpacing(8)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(dua.transliteration)
                    .nurFont(14)
                    .italic()
                    .foregroundColor(.white.opacity(0.7))
                
                if isExpanded {
                    let meaningText = dua.meaning(for: language)
                    Text(meaningText)
                        .dynamicMeaningFont(text: meaningText, baseSize: 15)
                        .foregroundColor(.white.opacity(0.9))
                        .transition(.opacity)
                }
                
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }) {
                    Text(isExpanded ? "general.less" : "general.more")
                        .nurFont(12, weight: .bold)
                        .foregroundColor(.nurGold)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
