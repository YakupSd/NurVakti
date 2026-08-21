import SwiftUI
import UIKit

struct ShareButton: View {
    let text: String
    var title: String? = nil
    var arabicText: String? = nil
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        Button {
            HapticManager.shared.tap()
            shareContent()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 10))
                Text(localization.localizedString("general.share"))
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundColor(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.nurGold)
            .cornerRadius(8)
            .shadow(color: Color.nurGold.opacity(0.2), radius: 4, y: 1)
        }
    }
    
    @MainActor
    private func shareContent() {
        var items: [Any] = [text]
        
        if let cardImage = renderShareCard() {
            items.insert(cardImage, at: 0)
        }
        
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController ?? windowScene.windows.first?.rootViewController {
            if let popover = av.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            rootVC.present(av, animated: true)
        }
    }
    
    @MainActor
    private func renderShareCard() -> UIImage? {
        let cardView = VStack(spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.nurGold)
                    Text("NurVakti")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            
            if let ar = arabicText, !ar.isEmpty {
                Text(ar)
                    .font(.custom("KFGQPCUthmanicScriptHAFS", size: 22))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
            
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .serif))
                .italic()
                .multilineTextAlignment(.center)
                .foregroundColor(Color.white.opacity(0.92))
                .lineSpacing(4)
                .padding(.horizontal)
            
            HStack {
                Spacer()
                Text("nurvakti.app")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.nurGold)
            }
        }
        .padding(24)
        .frame(width: 320)
        .background(
            LinearGradient(
                colors: [Color(hex: "#0E1626"), Color(hex: "#050811")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.nurGold.opacity(0.4), lineWidth: 1.2)
        )
        
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
