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
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundColor(.nurGold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.nurGold.opacity(0.12))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.nurGold.opacity(0.3), lineWidth: 1)
            )
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
                Text("NurVakti 🕌")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#D4AF37"))
                Spacer()
            }
            
            if let ar = arabicText, !ar.isEmpty {
                Text(ar)
                    .font(.system(size: 20, weight: .medium, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "1A1A2E"))
                    .padding(.horizontal)
            }
            
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.9))
                .padding(.horizontal)
            
            HStack {
                Spacer()
                Text("nurvakti.app")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "#D4AF37").opacity(0.7))
            }
        }
        .padding(24)
        .frame(width: 320)
        .background(
            LinearGradient(colors: [Color(hex: "#0D1B2A"), Color(hex: "#1B263B")], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#D4AF37").opacity(0.3), lineWidth: 1)
        )
        
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
