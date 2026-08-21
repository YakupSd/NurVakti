import SwiftUI

struct PrayerStepInteractiveView: View {
    let step: PrayerStep
    let language: LanguageCode
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                Spacer()
                
                // ── Main Illustration Card ──
                ZStack {
                    Color.white
                    
                    if let imageName = step.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .padding(24)
                            .transition(.opacity.combined(with: .scale))
                    } else {
                        Image(systemName: "figure.pray")
                            .font(.system(size: 72))
                            .foregroundColor(.nurGold.opacity(0.4))
                    }
                }
                .frame(width: geometry.size.width * 0.88)
                .aspectRatio(16/11, contentMode: .fit)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
                
                // ── Description Card ──
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Text(step.title(for: language))
                            .nurFont(20, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                        
                        Text("🤲")
                            .font(.system(size: 18))
                    }
                    
                    Text(step.description(for: language))
                        .nurFont(14)
                        .lineSpacing(5)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.75))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .frame(width: geometry.size.width * 0.88, alignment: .leading)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 3)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "F8F6F0").ignoresSafeArea()
        PrayerStepInteractiveView(step: PrayerGuideData.getPrayerSteps()[0], language: .tr)
    }
}
