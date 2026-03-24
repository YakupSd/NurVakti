import SwiftUI

struct GuidanceShareSheet: View {
    let item: GuidanceItem
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localization: LocalizationManager
    
    @State private var renderedImage: UIImage?
    @State private var isRendering = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: [Color(hex: "0F172A"), Color(hex: "020408")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(localization.localizedString("general.share"))
                        .nurFont(20, weight: .bold)
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
                                .padding(.horizontal, 24)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white.opacity(0.05))
                                    .frame(height: 400)
                                    .padding(.horizontal, 24)
                                
                                ProgressView()
                                    .tint(.nurGold)
                            }
                        }
                        
                        Text("Görsel Instagram Story boyutunda optimize edilmiştir.")
                            .nurFont(12)
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
                        .nurFont(18, weight: .bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14) // Reduced padding for a sleeker look
                        .background(
                            LinearGradient(colors: [Color.nurGold, Color(hex: "D4AF37")], startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(18)
                        .shadow(color: Color.nurGold.opacity(0.3), radius: 10, y: 5)
                    }
                }
                .padding(24)
                .background(.ultraThinMaterial)
            }
        }
        .onAppear {
            generatePreview()
        }
    }
    
    private func generatePreview() {
        Task {
            let view = GuidanceShareView(item: item)
                .frame(width: 1080, height: 1920) // Instagram Story size
            
            if let uiImage = await ShareImageRenderer.render(view: view) {
                renderedImage = uiImage
            }
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
            
            // iPad desteği için (crash olmaması adına popover ayarlaması)
            if let popover = av.popoverPresentationController {
                popover.sourceView = topController.view
                popover.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            topController.present(av, animated: true)
        }
    }
}

// Görsel olarak çıktı alınacak gizli view
struct GuidanceShareView: View {
    let item: GuidanceItem
    
    var body: some View {
        ZStack {
            // ── BACKGROUND ──
            LinearGradient(colors: [Color(hex: "0F172A"), Color(hex: "000000")], startPoint: .topLeading, endPoint: .bottomTrailing)
            
            // Decorative Glowing Orbs
            Circle()
                .fill(Color.nurGold.opacity(0.12))
                .frame(width: 1200, height: 1200)
                .offset(x: -400, y: -800)
                .blur(radius: 120)
            
            Circle()
                .fill(Color.nurGold.opacity(0.08))
                .frame(width: 800, height: 800)
                .offset(x: 500, y: 700)
                .blur(radius: 100)
            
            // Large Background Watermark (Islamic Geometric Pattern)
            Image(systemName: "seal.fill")
                .font(.system(size: 800))
                .foregroundColor(.nurGold.opacity(0.03))
                .rotationEffect(.degrees(15))
                .offset(x: 200, y: 100)
            
            VStack(spacing: 0) {
                // ── HEADER ──
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(.nurGold)
                        .shadow(color: .nurGold.opacity(0.5), radius: 20)
                    
                    Text("NurVakti")
                        .font(.system(size: 64, weight: .heavy))
                        .tracking(8)
                        .foregroundColor(.nurGold)
                }
                .padding(.top, 140)
                
                Spacer()
                
                // ── MAIN CONTENT CARD ──
                ZStack {
                    // Card Background
                    RoundedRectangle(cornerRadius: 60)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 60)
                                .stroke(
                                    LinearGradient(colors: [.nurGold.opacity(0.4), .clear, .nurGold.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 2
                                )
                        )
                    
                    VStack(spacing: 40) {
                        Image(systemName: item.type == .ayat ? "quote.bubble.fill" : "person.fill.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.nurGold.opacity(0.7))
                        
                        Text(item.text)
                            .font(.system(size: 68, weight: .medium))
                            .italic()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(18)
                            .padding(.horizontal, 40)
                            .shadow(color: .black.opacity(0.5), radius: 10, y: 5)
                        
                        if let source = item.source {
                            HStack {
                                Rectangle().fill(Color.nurGold.opacity(0.3)).frame(width: 40, height: 1)
                                Text(source)
                                    .font(.system(size: 34, weight: .light))
                                    .foregroundColor(.white.opacity(0.5))
                                Rectangle().fill(Color.nurGold.opacity(0.3)).frame(width: 40, height: 1)
                            }
                        }
                    }
                    .padding(80)
                }
                .padding(.horizontal, 60)
                .frame(maxHeight: 1200)
                
                Spacer()
                
                // ── FOOTER ──
                VStack(spacing: 20) {
                    Text("NurVakti ile Manevi Yolculuğuna Başla")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text("App Store & Play Store")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.nurGold.opacity(0.3))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            Capsule().stroke(Color.nurGold.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.bottom, 120)
            }
        }
    }
}
