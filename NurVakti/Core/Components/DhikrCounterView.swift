import SwiftUI

struct DhikrCounterView: View {
    @Binding var item: DhikrItem
    let language: LanguageCode
    let fontSize: FontSize
    let onComplete: () -> Void
    
    @State private var isAnimating = false
    @State private var ringPulse = false
    
    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                // Outer Ambient Warm Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.nurGold.opacity(0.18), Color.clear],
                            center: .center,
                            startRadius: 60,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .scaleEffect(isAnimating ? 1.08 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                
                // Track Background
                Circle()
                    .stroke(Color.black.opacity(0.04), lineWidth: 14)
                    .frame(width: 270, height: 270)
                
                // Progress Arc (Gold Luxury Gradient)
                Circle()
                    .trim(from: 0, to: item.progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#D4AF37"), Color(hex: "#C9A84C"), Color(hex: "#B8860B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 270, height: 270)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: item.currentCount)
                
                // Central Interactive Pearl Card
                Button(action: increment) {
                    VStack(spacing: 8) {
                        // Arabic Text
                        Text(item.arabicText)
                            .font(.custom("ScheherazadeNew-Bold", size: 26))
                            .minimumScaleFactor(0.6)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .foregroundColor(Color(hex: "2C1E11"))
                            .frame(height: 38)
                        
                        // Counter Number
                        Text(String(item.currentCount))
                            .nurFont(78, weight: .heavy, design: .rounded)
                            .foregroundColor(Color(hex: "1A1A2E"))
                            .contentTransition(.numericText())
                            .scaleEffect(isAnimating ? 1.12 : 1.0)
                            .shadow(color: Color.nurGold.opacity(isAnimating ? 0.3 : 0), radius: 8)
                        
                        // Target Badge
                        HStack(spacing: 4) {
                            Text(String(item.targetCount))
                                .nurFont(14, weight: .bold, design: .rounded)
                            Text(LocalizationManager.shared.localizedString("dhikr.target").uppercased())
                                .nurFont(9, weight: .bold)
                                .kerning(1.0)
                        }
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                        .background(Color(hex: "1A1A2E").opacity(0.05))
                        .cornerRadius(12)
                    }
                    .frame(width: 236, height: 236)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 6)
                }
                .buttonStyle(BouncyButtonStyle())
            }
            .frame(width: 320, height: 320)
            
            // Bottom Action Controls (Ivan Vorobei Inset Capsule Buttons)
            HStack(spacing: 24) {
                Button(action: reset) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 13, weight: .bold))
                        Text(LocalizationManager.shared.localizedString("dhikr.reset"))
                            .nurFont(12, weight: .bold)
                    }
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.02), radius: 4, y: 2)
                }
                .buttonStyle(BouncyButtonStyle())
            }
        }
    }
    
    private func increment() {
        if item.vibrateOnCount {
            HapticManager.shared.dhikrCount()
        }

        withAnimation(.spring(response: 0.25, dampingFraction: 0.5, blendDuration: 0)) {
            item.increment()
            isAnimating = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeOut(duration: 0.25)) {
                isAnimating = false
            }
        }

        if item.isCompleted && item.currentCount == item.targetCount {
            HapticManager.shared.dhikrDone()
            onComplete()
        }
    }

    private func reset() {
        HapticManager.shared.warning()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            item.reset()
        }
    }
}

#Preview {
    @Previewable @State var item = DhikrItem(id: UUID(), type: .subhanallah, arabicText: "سُبْحَانَ اللَّهِ", transliterationTR: "", meanings: [:], targetCount: 33, currentCount: 12, isCustom: false, vibrateOnCount: true, dailyCompletions: 1, totalCompletions: 34)
    
    ZStack {
        Color(hex: "F8F6F0").ignoresSafeArea()
        DhikrCounterView(item: $item, language: .tr, fontSize: .large) {}
    }
}
