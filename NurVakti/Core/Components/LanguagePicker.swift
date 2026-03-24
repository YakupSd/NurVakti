import SwiftUI

struct LanguagePicker: View {
    @Binding var selectedLanguage: LanguageCode
    let onChange: (LanguageCode) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(LanguageCode.allCases, id: \.self) { language in
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.spring()) {
                            selectedLanguage = language
                            onChange(language)
                        }
                    }) {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(selectedLanguage == language ? Color.nurGold.opacity(0.2) : Color.white.opacity(0.05))
                                    .frame(width: 64, height: 64)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedLanguage == language ? Color.nurGold : Color.clear, lineWidth: 2)
                                    )
                                    .shadow(color: selectedLanguage == language ? .nurGold.opacity(0.3) : .clear, radius: 8)
                                
                                Text(language.flag)
                                    .font(.system(size: 32))
                            }
                            
                            Text(language.displayName)
                                .font(.system(size: 14, weight: selectedLanguage == language ? .bold : .medium))
                                .foregroundColor(selectedLanguage == language ? .nurGold : .white.opacity(0.7))
                        }
                        .frame(width: 90)
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

#Preview {
    @State var lang: LanguageCode = .tr
    return LanguagePicker(selectedLanguage: $lang) { _ in }
        .padding(.vertical)
        .background(Color.black)
}
