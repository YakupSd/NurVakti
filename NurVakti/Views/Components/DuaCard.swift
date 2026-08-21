import SwiftUI

struct DuaCard: View {
    let dua: PrayerDua
    let language: LanguageCode
    
    @StateObject private var audioManager = AudioManager.shared
    @State private var isExpanded = false
    @State private var copied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // ── Header ────────────────────────────────────────────────
            HStack(alignment: .top, spacing: 12) {
                Text(dua.title(for: language))
                    .nurFont(17, weight: .bold)
                    .foregroundColor(.nurGold)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Kopyala butonu
                    Button(action: copyArabic) {
                        Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                            .font(.system(size: 15))
                            .foregroundColor(copied ? .green : Color(hex: "1A1A2E").opacity(0.45))
                            .frame(width: 34, height: 34)
                            .background(Color(hex: "1A1A2E").opacity(0.06))
                            .clipShape(Circle())
                    }
                    
                    // Ses butonu (audioFileName veya audioURL varsa)
                    if dua.audioFileName != nil || dua.audioURL != nil {
                        Button(action: toggleAudio) {
                            Image(systemName: audioManager.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.nurGold)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // ── Arapça Metin ──────────────────────────────────────────
            Text(dua.arabicText)
                .dynamicArabicFont(text: dua.arabicText, baseSize: 26)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(Color(hex: "1A1A2E"))
                .lineSpacing(10)
                .environment(\.layoutDirection, .rightToLeft)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            // ── Ayırıcı ───────────────────────────────────────────────
            Rectangle()
                .fill(Color(hex: "1A1A2E").opacity(0.07))
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            // ── Transkripsyon ─────────────────────────────────────────
            Text(dua.transliteration)
                .nurFont(13)
                .italic()
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.55))
                .lineSpacing(4)
                .padding(.horizontal, 20)
                .padding(.top, 14)
            
            // ── Açılır Bölüm: Mana + Fazilet ─────────────────────────
            if isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    let meaningText = dua.meaning(for: language)
                    if !meaningText.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(NSLocalizedString("general.meaning", comment: ""))
                                .nurFont(11, weight: .bold)
                                .foregroundColor(.nurGold)
                                .tracking(1)
                                .textCase(.uppercase)
                            
                            Text(meaningText)
                                .dynamicMeaningFont(text: meaningText, baseSize: 14)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.85))
                                .lineSpacing(5)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    // Fazilet
                    if let virtues = dua.virtues,
                       let virtue = virtues[language.rawValue] ?? virtues["tr"],
                       !virtue.isEmpty {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.nurGold)
                                .padding(.top, 2)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(NSLocalizedString("general.virtues", comment: ""))
                                    .nurFont(11, weight: .bold)
                                    .foregroundColor(.nurGold)
                                    .tracking(1)
                                    .textCase(.uppercase)
                                Text(virtue)
                                    .nurFont(13)
                                    .foregroundColor(.nurGold.opacity(0.9))
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(14)
                        .background(Color.nurGold.opacity(0.07))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.nurGold.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // ── Alt Aksiyon Çubuğu ────────────────────────────────────
            HStack(spacing: 0) {
                // Daha Fazla / Az butonu
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                    HapticManager.shared.light()
                }) {
                    HStack(spacing: 5) {
                        Text(isExpanded
                             ? NSLocalizedString("general.less", comment: "")
                             : NSLocalizedString("general.more", comment: ""))
                            .nurFont(12, weight: .bold)
                            .foregroundColor(.nurGold)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.nurGold)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(Color.nurGold.opacity(0.09))
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 20)
        }
        .background(Color(hex: "1A1A2E").opacity(0.04))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "1A1A2E").opacity(0.09), lineWidth: 1)
        )
    }
    
    // MARK: - Actions
    private func copyArabic() {
        UIPasteboard.general.string = dua.arabicText
        HapticManager.shared.success()
        withAnimation(.easeInOut(duration: 0.2)) { copied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.2)) { copied = false }
        }
    }
    
    private func toggleAudio() {
        HapticManager.shared.light()
        if audioManager.isPlaying {
            audioManager.stop()
        } else {
            audioManager.playPrayerDua(dua)
        }
    }
}
