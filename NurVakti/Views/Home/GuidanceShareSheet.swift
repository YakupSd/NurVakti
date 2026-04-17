import SwiftUI

struct GuidanceShareSheet: View {
    let content: DailyContent
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localization: LocalizationManager
    
    @State private var renderedImage: UIImage?
    @State private var isRendering = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: [Color(hex: "#0F172A"), Color(hex: "#020408")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(localization.localizedString("general.share"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
                .padding(24)
                
                // Preview Area
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if let image = renderedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(24)
                                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                                .padding(.horizontal, 48) // Narrower preview for story aspect ratio
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white.opacity(0.05))
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(9/16, contentMode: .fit)
                                    .padding(.horizontal, 48)
                                
                                ProgressView()
                                    .tint(.nurGold)
                            }
                        }
                        
                        Text("Görsel Instagram Story boyutunda optimize edilmiştir.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 40)
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: shareToInstagram) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up.fill")
                            Text(localization.localizedString("general.share"))
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color.nurGold, Color(hex: "#D4AF37")], startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(18)
                        .shadow(color: Color.nurGold.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(renderedImage == nil)
                }
                .padding(24)
                .background(.ultraThinMaterial)
            }
        }
        .task {
            await generatePreview()
        }
    }
    
    @MainActor
    private func generatePreview() async {
        // Prepare view for rendering
        let view = GuidanceShareView(content: content, language: localization.currentLanguage)
            .frame(width: 1080, height: 1920) // Official Story Dimensions
        
        if let uiImage = ShareImageRenderer.render(view: view) {
            renderedImage = uiImage
        }
    }
    
    private func shareToInstagram() {
        guard let image = renderedImage else { return }
        let av = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            
            var topController = root
            while let presented = topController.presentedViewController {
                topController = presented
            }
            
            if let popover = av.popoverPresentationController {
                popover.sourceView = topController.view
                popover.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            topController.present(av, animated: true)
        }
    }
}

// The Hidden View for Rendering
struct GuidanceShareView: View {
    let content: DailyContent
    let language: LanguageCode
    
    var body: some View {
        ZStack {
            // ── BACKGROUND ──
            LinearGradient(
                colors: [Color(hex: "#0F172A"), Color(hex: "#020617"), Color(hex: "#000000")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Decorative Glowing Orbs
            Circle()
                .fill(Color.nurGold.opacity(0.15))
                .frame(width: 1400, height: 1400)
                .offset(x: -500, y: -900)
                .blur(radius: 120)
            
            Circle()
                .fill(Color(hex: "#5D3FD3").opacity(0.1)) // Subtle deep purple glow from HomeView
                .frame(width: 1000, height: 1000)
                .offset(x: 600, y: 800)
                .blur(radius: 100)
            
            // Large Background Watermark
            Image(systemName: "seal.fill")
                .font(.system(size: 900))
                .foregroundColor(.nurGold.opacity(0.04))
                .rotationEffect(.degrees(10))
                .offset(x: 300, y: 200)
            
            VStack(spacing: 0) {
                // ── HEADER: LOGO AREA ──
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [.nurGold, Color(hex: "#8B6914")], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: 160, height: 160)
                            .shadow(color: .nurGold.opacity(0.4), radius: 30)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("NurVakti")
                        .font(.system(size: 80, weight: .heavy))
                        .tracking(10)
                        .foregroundColor(.nurGold)
                        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.top, 180)
                
                Spacer()
                
                // ── MAIN CONTENT CARD ──
                ZStack {
                    // Glassmorphic Card Background
                    RoundedRectangle(cornerRadius: 60)
                        .fill(Color.white.opacity(0.04))
                        .background(
                            RoundedRectangle(cornerRadius: 60)
                                .fill(Color.white.opacity(0.02))
                                .blur(radius: 20)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 60)
                                .stroke(
                                    LinearGradient(colors: [.white.opacity(0.2), .clear, .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 2
                                )
                        )
                    
                    VStack(spacing: 60) {
                        Image(systemName: content.type == .ayat ? "quote.bubble.fill" : "hands.sparkles.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.nurGold.opacity(0.8))
                        
                        if !content.arabicText.isEmpty {
                            Text(content.arabicText)
                                .font(.custom("KFGQPCUthmanicScriptHAFS", size: 60))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .lineSpacing(20)
                                .padding(.horizontal, 40)
                                .environment(\.layoutDirection, .rightToLeft)
                        }
                        
                        let translation = content.translation(for: language)
                        if !translation.isEmpty {
                            VStack(spacing: 20) {
                                if !content.arabicText.isEmpty {
                                    Rectangle()
                                        .fill(Color.nurGold.opacity(0.2))
                                        .frame(width: 200, height: 1)
                                }
                                
                                Text(translation)
                                    .font(.system(size: 50, weight: .light))
                                    .italic()
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(15)
                                    .padding(.horizontal, 40)
                            }
                        }
                        
                        HStack {
                            Rectangle().fill(Color.nurGold.opacity(0.4)).frame(width: 60, height: 1)
                            Text(content.source)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.nurGold)
                            Rectangle().fill(Color.nurGold.opacity(0.4)).frame(width: 60, height: 1)
                        }
                        .padding(.top, 20)
                    }
                    .padding(80)
                }
                .padding(.horizontal, 60)
                .frame(maxHeight: 1100)
                
                Spacer()
                
                // ── FOOTER ──
                VStack(spacing: 30) {
                    Text("NurVakti ile Manevi Yolculuğuna Başla")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                    
                    HStack(spacing: 40) {
                        HStack(spacing: 12) {
                            Image(systemName: "apple.logo")
                            Text("App Store")
                        }
                        .font(.system(size: 28, weight: .medium))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 14)
                        .background(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                            Text("Play Store")
                        }
                        .font(.system(size: 28, weight: .medium))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 14)
                        .background(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                    .foregroundColor(.nurGold.opacity(0.6))
                }
                .padding(.bottom, 140)
            }
        }
    }
}
