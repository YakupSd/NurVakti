import SwiftUI

struct PrayerStepInteractiveView: View {
    let step: PrayerStep
    let language: LanguageCode
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 32) {
                Spacer()
                
                // ── Main Illustration Card ──
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "#3A4568"), Color.prayerCard],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    if let imageName = step.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .padding(24)
                            .transition(.opacity.combined(with: .scale))
                    } else {
                        Image(systemName: "figure.pray")
                            .font(.system(size: 80))
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.1))
                    }
                }
                .frame(width: geometry.size.width * 0.8)
                .aspectRatio(16/10, contentMode: .fit)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.3), radius: 24, x: 0, y: 8)
                
                // ── Description Card ──
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Text(step.title(for: language))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.prayerGold)
                        
                        Text("🤲")
                            .font(.system(size: 20))
                    }
                    
                    Text(step.description(for: language))
                        .font(.system(size: 16))
                        .lineSpacing(6)
                        .foregroundColor(Color(hex: "#E5E7EB"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .frame(width: geometry.size.width * 0.85, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [Color.prayerCard, Color(hex: "#3A4568")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 4)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}
