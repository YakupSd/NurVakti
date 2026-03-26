import SwiftUI
import UIKit

// MARK: - Ayah Text View (UIKit Bridge)
struct AyahTextView: UIViewRepresentable {
    let text: String
    let tajweedRanges: [MushafRange]
    let fontSize: CGFloat
    let lineSpacing: CGFloat = 18
    @Binding var dynamicHeight: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textAlignment = .right
        textView.isSelectable = false // Metin seçimini kapat, kazara kaydırmayı engeller
        textView.semanticContentAttribute = .forceRightToLeft
        
        // Anti-aliasing and rendering tweaks
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = buildAttributedString()
        
        DispatchQueue.main.async {
            let newSize = uiView.sizeThatFits(CGSize(width: uiView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            if abs(self.dynamicHeight - newSize.height) > 0.1 {
                self.dynamicHeight = newSize.height
            }
        }
    }
    
    private func buildAttributedString() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.baseWritingDirection = .rightToLeft
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        // Font handling with fallback
        let font = UIFont(name: "AmiriQuran", size: fontSize) ?? .systemFont(ofSize: fontSize)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor(hex: "#2C1E11") // Mushaf Dark Brown for readability
        ]
        
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        
        // Tajweed Coloring removed as per user request to revert to "saf" (Uthmani) form
        
        return attributedString
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.mushafBackground.ignoresSafeArea()
        AyahTextView(
            text: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
            tajweedRanges: [],
            fontSize: 32,
            dynamicHeight: .constant(100)
        )
        .frame(height: 100)
    }
}
