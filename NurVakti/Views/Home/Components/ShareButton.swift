import SwiftUI
import UIKit

struct ShareButton: View {
    let text: String
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        Button {
            let av = UIActivityViewController(
                activityItems: [text], 
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(av, animated: true)
            }
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
}
