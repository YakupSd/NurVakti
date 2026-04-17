import SwiftUI

struct DuaDetailView: View {
    let dua: DuaItem
    let language: LanguageCode
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var loc: LocalizationManager
    @StateObject private var audioManager = AudioManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var showNoteAlert = false
    @State private var noteText = ""
    @State private var isFavourited = false
    
    var body: some View {
        ZStack {
            Color.nurOffWhite.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // ── ARABIC MANUSCRIPT SECTION ─────
                    VStack(spacing: 20) {
                        Text(dua.arabicText)
                            .font(.custom("Amiri-Bold", size: 30))
                            .lineSpacing(12)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding(30)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.04), radius: 15, y: 10)
                            )
                    }
                    .padding(.top, 10)
                    
                    HStack(spacing: 12) {
                        DuaActionButton(
                            icon: audioManager.isPlaying ? "stop.fill" : "speaker.wave.2",
                            title: loc.localizedString("action.listen")
                        ) {
                            if dua.hasAudio {
                                if audioManager.isPlaying {
                                    audioManager.stop()
                                } else {
                                    audioManager.playDua(item: dua)
                                }
                            } else {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                            }
                        }
                        .opacity(dua.hasAudio ? 1.0 : 0.4)
                        .disabled(!dua.hasAudio)
                        
                        DuaActionButton(icon: "square.and.arrow.up", title: loc.localizedString("action.share")) {
                            shareDua()
                        }
                        
                        DuaActionButton(icon: "doc.on.doc", title: loc.localizedString("action.copy")) {
                            copyDua()
                        }
                        
                        DuaActionButton(icon: "square.and.pencil", title: loc.localizedString("action.addNote")) {
                            showNoteAlert = true
                        }
                    }
                    
                    // ── FAZILETI (VIRTUE) ─────────────
                    DuaContentSection(title: "Fazileti", icon: "sparkles", color: .nurOlive) {
                        Text(dua.virtue?[language] ?? "Bu duanın fazileti yakında eklenecektir.")
                            .font(.system(size: 14))
                            .lineSpacing(6)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    
                    // ── OKUNUŞU (TRANSLITERATION) ─────
                    DuaContentSection(title: "Okunuşu", icon: "text.alignleft", color: .nurOlive) {
                        Text(dua.transliteration[language] ?? "")
                            .font(.system(size: 15, weight: .medium, design: .serif))
                            .italic()
                            .lineSpacing(4)
                            .foregroundColor(.black.opacity(0.9))
                    }
                    
                    // ── ANLAMI (MEANING) ──────────────
                    DuaContentSection(title: "Anlamı", icon: "book.fill", color: .nurOlive) {
                        Text(dua.translation[language] ?? "")
                            .font(.system(size: 15))
                            .lineSpacing(6)
                            .foregroundColor(.black.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        .alert("Not Ekle", isPresented: $showNoteAlert) {
            TextField("Notunuz", text: $noteText)
            Button("Kaydet", action: {})
            Button("İptal", role: .cancel, action: {})
        }
    }
}

// MARK: - Actions
    private func copyDua() {
        UIPasteboard.general.string = "\(dua.arabicText)\n\n\(dua.translation[language] ?? "")"
        HapticManager.shared.success()
    }
    
    private func shareDua() {
        let text = "\(dua.title[language] ?? "")\n\n\(dua.arabicText)\n\n\(dua.translation[language] ?? "")"
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.first?.rootViewController?.present(vc, animated: true)
        }
    }
}

// MARK: - Subviews
struct DuaActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(.black.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.03), radius: 5, y: 5)
        }
    }
}

struct DuaContentSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
                    .textCase(.uppercase)
                    .tracking(1)
            }
            
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.02), radius: 10, y: 5)
    }
}
