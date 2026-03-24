import SwiftUI

struct DuaDetailView: View {
    let dua: DuaItem
    let language: LanguageCode
    @EnvironmentObject var router: AppRouter
    @StateObject private var audioService = AudioService.shared
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color(hex: "0D1B2A"), Color(hex: "000000")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            // Decorative Glow
            Circle()
                .fill(Color.nurGold.opacity(0.08))
                .frame(width: 300)
                .offset(y: -200)
                .blur(radius: 60)
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        // ── ARABIC BLOCK (Manuscript Style) ──────────
                        VStack(spacing: 20) {
                            Text(dua.arabicText)
                                .font(.custom("Traditional Arabic", size: 36))
                                .multilineTextAlignment(.center)
                                .lineSpacing(12)
                                .foregroundColor(.white)
                                .padding(30)
                                .frame(maxWidth: .infinity)
                                .background(
                                    ZStack {
                                        // Manuscript Paper Texture Effect
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color(hex: "FDFBF0").opacity(0.1))
                                        
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(.ultraThinMaterial)
                                        
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(
                                                LinearGradient(colors: [.nurGold.opacity(0.5), .clear, .nurGold.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 1
                                            )
                                    }
                                )
                                .shadow(color: .black.opacity(0.3), radius: 20)
                            
                            // Audio Control Bar
                            HStack(spacing: 20) {
                                // Arabic Audio
                                audioButton(
                                    title: audioService.isBuffering ? LocalizationManager.shared.localizedString("dua.loadingAudio") : LocalizationManager.shared.localizedString("dua.listenArabic"),
                                    icon: audioService.isPlaying ? "stop.fill" : "play.fill",
                                    isBuffering: audioService.isBuffering,
                                    color: .nurGold
                                ) {
                                    HapticManager.shared.light()
                                    if audioService.isPlaying {
                                        audioService.stop()
                                    } else {
                                        if let url = dua.audioArabicURL {
                                            audioService.playStream(urlStr: url)
                                        } else {
                                            audioService.speak(dua.arabicText, language: "ar-SA")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 10)
                        
                        // ── TRANSLATION & TRANSCRIPTION ──────────────
                        VStack(spacing: 24) {
                            ExpandableSectionBox(title: LocalizationManager.shared.localizedString("dua.transliteration"), 
                                       content: dua.transliteration[language] ?? "", 
                                       icon: "text.quote", 
                                       isItalic: true)
                            
                            ExpandableSectionBox(title: LocalizationManager.shared.localizedString("dua.translation"), 
                                       content: dua.translation[language] ?? "", 
                                       icon: "doc.text.fill", 
                                       hasAudio: true) {
                                HapticManager.shared.light()
                                audioService.speak(dua.translation[language] ?? "", language: language == .tr ? "tr-TR" : "en-US")
                            }
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onDisappear {
            audioService.stop()
        }
    }
    
    // Helper Components
    private func audioButton(title: String, icon: String, isBuffering: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                if isBuffering {
                    ProgressView().tint(.black)
                } else {
                    Image(systemName: icon)
                }
                Text(title)
                    .nurFont(14, weight: .bold)
            }
            .foregroundColor(.black)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.3), radius: 10, y: 5)
        }
    }
}

struct ExpandableSectionBox: View {
    let title: String
    let content: String
    let icon: String
    var isItalic: Bool = false
    var hasAudio: Bool = false
    var audioAction: (() -> Void)? = nil
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title, systemImage: icon)
                    .nurFont(16, weight: .bold)
                    .foregroundColor(.nurGold)
                Spacer()
                if hasAudio {
                    Button(action: { audioAction?() }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.nurGold)
                    }
                }
            }
            
            Text(content)
                .nurFont(16)
                .foregroundColor(.white.opacity(0.9))
                .italic(isItalic)
                .lineSpacing(6)
                .lineLimit(isExpanded ? nil : 4)
            
            if content.count > 120 {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Text(isExpanded ? "Daha Az Göster" : "Devamını Gör")
                        .nurFont(12, weight: .bold)
                        .foregroundColor(.nurGold)
                        .padding(.top, 4)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}

#Preview {
    DuaDetailView(dua: DuaItem(
        id: UUID(),
        title: [.tr: "Ayet-el Kürsi"],
        arabicText: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...",
        transliteration: [.tr: "Allâhu lâ ilâhe illâ huvel hayyul kayyûm..."],
        translation: [.tr: "Allah, O'ndan başka ilah yoktur. Diridir, kaimdir..."],
        category: .morning
    ), language: .tr)
}
