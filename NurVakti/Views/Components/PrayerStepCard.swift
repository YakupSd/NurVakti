import SwiftUI

struct PrayerStepCard: View {
    let step: PrayerStep
    let index: Int
    let language: LanguageCode
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Index Circle
            ZStack {
                Circle()
                    .fill(Color.nurGold.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Text("\(index + 1)")
                    .nurFont(16, weight: .bold)
                    .foregroundColor(.nurGold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(step.title(for: language))
                    .nurFont(20, weight: .bold)
                    .foregroundColor(Color(hex: "1A1A2E"))
                
                Text(step.description(for: language))
                    .nurFont(16)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                
                if let imageName = step.imageName {
                    ZStack {
                        // Fallback background
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "1A1A2E").opacity(0.05))
                        
                        Image(systemName: "figure.pray")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.1))
                        
                        // Actual Image
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "1A1A2E").opacity(0.1), lineWidth: 1)
                    )
                    .padding(.top, 8)
                }
            }
        }
        .padding(24)
        .background(Color(hex: "1A1A2E").opacity(0.05))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(hex: "1A1A2E").opacity(0.1), lineWidth: 1)
        )
    }
}
