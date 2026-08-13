import SwiftUI

struct EsmaulHusnaView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var loc: LocalizationManager
    @StateObject private var viewModel = AsmaViewModel()
    @StateObject private var audioManager = AudioManager.shared
    @State private var selectedName: EsmaulHusna? = nil
    @State private var isPlayingAll = false
    
    // Listen to AudioManager's isPlaying to reset isPlayingAll if audio stops externally
    @State private var isAudioPlaying = false
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            Color.nurOffWhite.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // ── HERO CARD ─────────────────────
                        VStack(spacing: 12) {
                            Text("أَسْمَاءُ اللَّهِ الْحُسْنَى")
                                .font(.custom("Amiri-Bold", size: 36))
                                .foregroundColor(Color(hex: "1A1A2E"))
                            
                            VStack(spacing: 4) {
                                Text("Allah'ın 99 Güzel İsmi")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: "1A1A2E"))
                                Text("Her isim eşsiz bir sıfatı ifade eder")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.8))
                            }
                        }
                        .padding(.vertical, 40)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.nurOlive)
                        )
                        .padding(.top, 10)
                        
                        // ── API STATUS / LOADING ──────────
                        if viewModel.isLoading {
                            ProgressView("Yükleniyor...")
                                .padding(.top, 40)
                        } else if viewModel.isApiKeyMissing {
                            // Fallback to local data if API Key is missing
                            VStack(spacing: 20) {
                                Text("API Anahtarı Bekleniyor...")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.nurOlive)
                                
                                // STILL SHOW THE LIST (Local Fallback)
                                asmaList(allNames: EsmaData.all)
                            }
                        } else if let error = viewModel.errorMessage {
                            VStack(spacing: 12) {
                                Text(error)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                Button("Tekrar Dene") {
                                    Task { await viewModel.retry() }
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.top, 40)
                        } else {
                            // API Success Flow
                            asmaList(allNames: viewModel.names)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onChange(of: audioManager.isPlaying) { newValue in
            if !newValue {
                isPlayingAll = false
            }
        }
        .onAppear {
            Task {
                await viewModel.loadNames(language: loc.currentLanguage.rawValue)
            }
        }
        .sheet(item: $selectedName) { name in
            EsmaDetailSheet(name: name)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    @ViewBuilder
    private func asmaList(allNames: [EsmaulHusna]) -> some View {
        VStack(spacing: 20) {
            // ── THE FIRST NAME (Large Card) ──
            if let first = allNames.first {
                EsmaBigCard(name: first)
                    .onTapGesture { triggerSelection(first) }
                    .onLongPressGesture(minimumDuration: 0.1) { triggerSelection(first) }
            }
            
            // ── GRID OF NAMES ─────────────────
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(allNames.dropFirst(), id: \.id) { name in
                    EsmaSmallCard(name: name)
                        .onTapGesture { triggerSelection(name) }
                        .onLongPressGesture(minimumDuration: 0.1) { triggerSelection(name) }
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    private func triggerSelection(_ name: EsmaulHusna) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        selectedName = name
    }
    
    @ViewBuilder
    private func EsmaBigCard(name: EsmaulHusna) -> some View {
        VStack(spacing: 12) {
            Text(name.name)
                .font(.custom("Amiri-Bold", size: 48))
                .foregroundColor(.black)
            
            Text(name.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.03), radius: 10, y: 5)
    }
}

struct EsmaSmallCard: View {
    @EnvironmentObject var loc: LocalizationManager
    let name: EsmaulHusna
    
    var body: some View {
        VStack(spacing: 8) {
            Text(name.name)
                .font(.custom("Amiri-Bold", size: 24))
                .foregroundColor(.black)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            VStack(spacing: 2) {
                Text(name.title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(name.meaning(for: loc.currentLanguage))
                    .font(.system(size: 9))
                    .foregroundColor(.black.opacity(0.4))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.02), radius: 5, y: 3)
    }
}

struct EsmaDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var loc: LocalizationManager
    @StateObject private var audioManager = AudioManager.shared
    @State private var showCopiedAlert = false
    let name: EsmaulHusna
    
    var body: some View {
        VStack(spacing: 0) {
            // Manuscript Indicator
            Capsule()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Name Display
                    VStack(spacing: 8) {
                        Text(name.name)
                            .font(.custom("Amiri-Bold", size: 64))
                            .foregroundColor(.nurOlive)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        
                        Text(name.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                    }
                    
                    // Action Buttons
                    HStack(spacing: 20) {
                        ActionButton(
                            icon: audioManager.isPlaying ? "stop.fill" : "play.fill",
                            title: audioManager.isPlaying ? "Durdur" : "Dinle",
                            color: .nurOlive
                        ) {
                            if audioManager.isPlaying {
                                audioManager.stop()
                            } else if let audioURLStr = name.audioURL,
                                      let url = URL(string: audioURLStr) {
                                audioManager.play(idType: .directURL(url))
                            }
                        }
                        .disabled(name.audioURL == nil)
                        .opacity(name.audioURL == nil ? 0.3 : 1)
                        
                        ActionButton(
                            icon: showCopiedAlert ? "checkmark" : "doc.on.doc.fill",
                            title: showCopiedAlert ? "Kopyalandı" : "Kopyala",
                            color: .gray
                        ) {
                            copyToClipboard()
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // Meaning Card
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.nurOlive)
                            Text("Anlamı")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black.opacity(0.5))
                                .textCase(.uppercase)
                        }
                        
                        Text(name.meaning(for: loc.currentLanguage))
                            .font(.system(size: 18, weight: .medium, design: .serif))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.nurOffWhite)
                    .cornerRadius(20)
                    
                    if let virtue = name.virtue {
                        VStack(spacing: 8) {
                            Text("Fazileti")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black.opacity(0.4))
                            Text(virtue)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black.opacity(0.7))
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.bottom, 20)
            }
            
            Button("Kapat") {
                audioManager.stop()
                dismiss()
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(Color(hex: "1A1A2E"))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.nurOlive)
            .cornerRadius(27)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .background(Color.white)
        .onDisappear {
            audioManager.stop()
        }
    }
    
    private func copyToClipboard() {
        let text = name.copyText(for: loc.currentLanguage)
        UIPasteboard.general.string = text
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        withAnimation {
            showCopiedAlert = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedAlert = false
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(color)
            }
        }
    }
}
