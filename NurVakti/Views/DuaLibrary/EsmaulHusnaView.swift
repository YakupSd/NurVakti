import SwiftUI

struct EsmaulHusnaView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var loc: LocalizationManager
    @StateObject private var viewModel = AsmaViewModel()
    @StateObject private var audioManager = AudioManager.shared
    @State private var selectedName: EsmaulHusna? = nil
    @State private var isPlayingAll = false
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // ── HERO CARD ─────────────────────
                        VStack(spacing: 12) {
                            Text("أَسْمَاءُ اللَّهِ الْحُسْنَى")
                                .font(.custom("ScheherazadeNew-Bold", size: 36))
                                .foregroundColor(Color(hex: "2C1E11"))
                            
                            VStack(spacing: 4) {
                                Text(loc.localizedString("esma.title"))
                                    .nurFont(18, weight: .bold)
                                    .foregroundColor(Color(hex: "1A1A2E"))
                                Text(loc.localizedString("esma.subtitle"))
                                    .nurFont(12)
                                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                            }
                        }
                        .padding(.vertical, 32)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.nurGold.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 3)
                        .padding(.top, 10)
                        
                        // ── API STATUS / LOADING ──────────
                        if viewModel.isLoading {
                            ProgressView(loc.localizedString("general.loading"))
                                .tint(.nurGold)
                                .padding(.top, 40)
                        } else if viewModel.isApiKeyMissing {
                            asmaList(allNames: EsmaData.all)
                        } else if let error = viewModel.errorMessage {
                            VStack(spacing: 12) {
                                Text(error)
                                    .nurFont(13)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                Button(loc.localizedString("general.tryAgain")) {
                                    Task { await viewModel.retry() }
                                }
                                .buttonStyle(BouncyButtonStyle())
                            }
                            .padding(.top, 40)
                        } else {
                            asmaList(allNames: viewModel.names)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
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
        VStack(spacing: 16) {
            // ── THE FIRST NAME (Large Card) ──
            if let first = allNames.first {
                Button(action: { triggerSelection(first) }) {
                    EsmaBigCard(name: first)
                }
                .buttonStyle(CardPressableButtonStyle())
            }
            
            // ── GRID OF NAMES ─────────────────
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(allNames.dropFirst(), id: \.id) { name in
                    Button(action: { triggerSelection(name) }) {
                        EsmaSmallCard(name: name)
                    }
                    .buttonStyle(CardPressableButtonStyle())
                }
            }
        }
    }
    
    private func triggerSelection(_ name: EsmaulHusna) {
        HapticManager.shared.light()
        selectedName = name
    }
    
    @ViewBuilder
    private func EsmaBigCard(name: EsmaulHusna) -> some View {
        VStack(spacing: 10) {
            Text(name.name)
                .font(.custom("ScheherazadeNew-Bold", size: 48))
                .foregroundColor(Color(hex: "2C1E11"))
            
            Text(name.title)
                .nurFont(16, weight: .bold)
                .foregroundColor(Color(hex: "1A1A2E"))
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.nurGold.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
    }
}

struct EsmaSmallCard: View {
    @EnvironmentObject var loc: LocalizationManager
    let name: EsmaulHusna
    
    var body: some View {
        VStack(spacing: 6) {
            Text(name.name)
                .font(.custom("ScheherazadeNew-Bold", size: 24))
                .foregroundColor(Color(hex: "2C1E11"))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            
            VStack(spacing: 2) {
                Text(name.title)
                    .nurFont(11, weight: .bold)
                    .foregroundColor(Color(hex: "1A1A2E"))
                    .lineLimit(1)
                
                Text(name.meaning(for: loc.currentLanguage))
                    .nurFont(9)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, minHeight: 96)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
    }
}

struct EsmaDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var loc: LocalizationManager
    @StateObject private var audioManager = AudioManager.shared
    @State private var showCopiedAlert = false
    let name: EsmaulHusna
    
    var body: some View {
        ZStack {
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Name Display
                    VStack(spacing: 8) {
                        Text(name.name)
                            .font(.custom("ScheherazadeNew-Bold", size: 56))
                            .foregroundColor(Color(hex: "2C1E11"))
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        
                        Text(name.title)
                            .nurFont(22, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                    }
                    .padding(.top, 16)
                    
                    // Action Buttons (Play Audio & Copy)
                    HStack(spacing: 16) {
                        Button(action: {
                            if audioManager.isPlaying {
                                audioManager.stop()
                            } else if let audioURLStr = name.audioURL,
                                      let url = URL(string: audioURLStr) {
                                audioManager.play(idType: .directURL(url))
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill")
                                    .font(.system(size: 13, weight: .bold))
                                Text(audioManager.isPlaying ? loc.localizedString("audio.pause") : loc.localizedString("audio.listen"))
                                    .nurFont(13, weight: .bold)
                            }
                            .foregroundColor(Color(hex: "1A1A2E"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.nurGold)
                            .cornerRadius(14)
                        }
                        .buttonStyle(BouncyButtonStyle())
                        .disabled(name.audioURL == nil)
                        .opacity(name.audioURL == nil ? 0.4 : 1)
                        
                        Button(action: copyToClipboard) {
                            HStack(spacing: 8) {
                                Image(systemName: showCopiedAlert ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 13, weight: .bold))
                                Text(showCopiedAlert ? loc.localizedString("general.copied") : loc.localizedString("general.copy"))
                                    .nurFont(13, weight: .bold)
                            }
                            .foregroundColor(Color(hex: "1A1A2E"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: "1A1A2E").opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    
                    // Meaning Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.nurGold)
                                .font(.system(size: 13))
                            Text(loc.localizedString("general.meaning"))
                                .nurFont(12, weight: .bold)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                        }
                        
                        Text(name.meaning(for: loc.currentLanguage))
                            .nurFont(15)
                            .foregroundColor(Color(hex: "1A1A2E"))
                            .lineSpacing(5)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Virtues Card
                    if let virtue = name.virtue, !virtue.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.nurGold)
                                    .font(.system(size: 13))
                                Text(loc.localizedString("general.virtues"))
                                    .nurFont(12, weight: .bold)
                                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                            }
                            
                            Text(virtue)
                                .nurFont(14)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.85))
                                .lineSpacing(5)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Close Button
                    Button(action: { dismiss() }) {
                        Text(loc.localizedString("general.close"))
                            .nurFont(14, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(hex: "1A1A2E").opacity(0.06))
                            .cornerRadius(14)
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = "\(name.name) - \(name.title)\n\(name.meaning(for: loc.currentLanguage))"
        HapticManager.shared.success()
        withAnimation { showCopiedAlert = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showCopiedAlert = false }
        }
    }
}

#Preview {
    EsmaulHusnaView()
        .environmentObject(LocalizationManager.shared)
}
