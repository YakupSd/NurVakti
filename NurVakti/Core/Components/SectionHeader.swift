import SwiftUI

struct SectionHeader: View {
    let title: String
    var icon: String? = nil
    
    var body: some View {
        HStack(spacing: 10) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.nurGold)
                    .frame(width: 32, height: 32)
                    .background(Color.nurGold.opacity(0.15))
                    .clipShape(Circle())
            }
            
            Text(title.uppercased())
                .font(.system(size: 13, weight: .black))
                .spacing(1.2)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Rectangle()
                .fill(LinearGradient(colors: [.nurGold.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
                .frame(maxWidth: 60)
        }
        .padding(.vertical, 4)
    }
}

extension Text {
    func spacing(_ spacing: CGFloat) -> Text {
        self.kerning(spacing)
    }
}

#Preview {
    VStack {
        SectionHeader(title: "DİL SEÇİMİ", icon: "globe")
        SectionHeader(title: "GÖRÜNÜM", icon: "textformat.size")
    }
    .padding()
    .background(Color.black)
}
