import SwiftUI
import UIKit

public struct SpiritualShareSheet: View {
    public let message: SpiritualMessage
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localization: LocalizationManager
    
    @State private var selectedTheme: StoryTheme = .midnight
    @State private var renderedImage: UIImage?
    @State private var isRendering = false
    @State private var showCopiedAlert = false
    
    public init(message: SpiritualMessage) {
        self.message = message
    }
    
    public var body: some View {
        ZStack {
            // Warm Cream Light Luxury background
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── HEADER BAR ──
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.nurGold)
                            .font(.system(size: 16, weight: .bold))
                        Text(localization.localizedString("general.share"))
                            .nurFont(20, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                    }
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 36, height: 36)
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                        }
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 10)
                
                // ── THEME SELECTOR PILLS ──
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(StoryTheme.allCases) { theme in
                            Button(action: {
                                if selectedTheme != theme {
                                    HapticManager.shared.selectionChanged()
                                    selectedTheme = theme
                                    Task {
                                        await renderStoryImage()
                                    }
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: theme.icon)
                                        .font(.system(size: 12, weight: .semibold))
                                    Text(theme.title)
                                        .nurFont(13, weight: selectedTheme == theme ? .bold : .medium)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .foregroundColor(selectedTheme == theme ? (theme == .ivory ? Color(hex: "#1A1A2E") : .white) : Color(hex: "1A1A2E").opacity(0.7))
                                .background(
                                    ZStack {
                                        if selectedTheme == theme {
                                            LinearGradient(
                                                colors: theme.backgroundColors,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        } else {
                                            Color.white
                                        }
                                    }
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            selectedTheme == theme ? Color.nurGold : Color(hex: "1A1A2E").opacity(0.1),
                                            lineWidth: selectedTheme == theme ? 1.5 : 1
                                        )
                                )
                                .shadow(color: selectedTheme == theme ? Color.nurGold.opacity(0.2) : Color.black.opacity(0.02), radius: 6, y: 2)
                            }
                            .buttonStyle(BouncyButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                }
                
                // ── STORY PREVIEW AREA ──
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        if let image = renderedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(22)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.white, Color.nurGold.opacity(0.5), Color.white.opacity(0.7)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: Color(hex: "1A1A2E").opacity(0.18), radius: 20, x: 0, y: 10)
                                .shadow(color: Color.nurGold.opacity(0.15), radius: 8, x: 0, y: 3)
                                .padding(.horizontal, 48)
                                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(9/16, contentMode: .fit)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.03), radius: 10, y: 4)
                                    .padding(.horizontal, 48)
                                
                                VStack(spacing: 12) {
                                    ProgressView().tint(.nurGold)
                                    Text(localization.localizedString("general.loading"))
                                        .nurFont(13, weight: .medium)
                                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                                }
                            }
                        }
                        
                        // Subtitle
                        HStack(spacing: 6) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 12))
                                .foregroundColor(.nurGold)
                            Text(localization.localizedString("share.storyOptimized"))
                                .nurFont(12, weight: .medium)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 8)
                }
                
                // ── BOTTOM ACTION BUTTONS ──
                VStack(spacing: 10) {
                    // Primary Share Button
                    Button(action: {
                        HapticManager.shared.success()
                        shareImage()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "square.and.arrow.up.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("Görseli Paylaş / Story")
                                .nurFont(16, weight: .bold)
                        }
                        .foregroundColor(Color(hex: "1A1A2E"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [Color.nurGold, Color(hex: "E5C158")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.nurGold.opacity(0.35), radius: 10, y: 4)
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .disabled(renderedImage == nil)
                    
                    // Secondary Actions (Copy Text & Direct Text Share)
                    HStack(spacing: 10) {
                        Button(action: {
                            HapticManager.shared.light()
                            UIPasteboard.general.string = message.formattedShareText
                            showCopiedAlert = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCopiedAlert = false
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.doc.fill")
                                    .font(.system(size: 13))
                                Text(showCopiedAlert ? "Kopyalandı!" : "Metni Kopyala")
                                    .nurFont(13, weight: .semibold)
                            }
                            .foregroundColor(showCopiedAlert ? Color(hex: "#2D8B56") : Color(hex: "1A1A2E"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(showCopiedAlert ? Color(hex: "#2D8B56").opacity(0.4) : Color(hex: "1A1A2E").opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(BouncyButtonStyle())
                        
                        Button(action: {
                            HapticManager.shared.light()
                            shareText()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 13))
                                Text("Metin Olarak Paylaş")
                                    .nurFont(13, weight: .semibold)
                            }
                            .foregroundColor(Color(hex: "1A1A2E"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "1A1A2E").opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    Color.white
                        .shadow(color: Color.black.opacity(0.04), radius: 12, y: -4)
                )
            }
        }
        .task {
            await renderStoryImage()
        }
    }
    
    @MainActor
    private func renderStoryImage() async {
        let canvas = SpiritualStoryShareCanvas(
            message: message,
            theme: selectedTheme,
            language: localization.currentLanguage
        )
        
        if let uiImage = ShareImageRenderer.render(view: canvas, scale: 1.0) {
            withAnimation(.easeInOut(duration: 0.2)) {
                renderedImage = uiImage
            }
        }
    }
    
    private func shareImage() {
        guard let image = renderedImage else { return }
        presentActivityController(items: [image])
    }
    
    private func shareText() {
        presentActivityController(items: [message.formattedShareText])
    }
    
    private func presentActivityController(items: [Any]) {
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
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
