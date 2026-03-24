import SwiftUI

struct DhikrCounterView: View {
    @Binding var item: DhikrItem
    let language: LanguageCode
    let fontSize: FontSize
    let onComplete: () -> Void
    
    @State private var isAnimating = false
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                // Outer Glow / Shadow
                Circle()
                    .fill(Color.nurGold.opacity(0.15))
                    .blur(radius: 20)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                
                // Main Jewel Body (Glassmorphism)
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(colors: [.white.opacity(0.5), .clear, .nurGold.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // Progress Ring (Gold)
                Circle()
                    .trim(from: 0, to: item.progress)
                    .stroke(
                        LinearGradient(colors: [Color(hex: "D4AF37"), Color(hex: "FFDF00"), Color(hex: "B8860B")], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .padding(6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: item.currentCount)
                
                // Tap Area & Content
                Button(action: increment) {
                    VStack(spacing: 12) {
                        Text(item.arabicText)
                            .nurFont(24, weight: .bold)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .foregroundColor(.white)
                        
                        Text(String(item.currentCount))
                            .nurFont(80, weight: .heavy, design: .rounded)
                            .foregroundColor(.nurGold)
                            .contentTransition(.numericText())
                            .scaleEffect(isAnimating ? 1.15 : 1.0)
                        
                        HStack(spacing: 4) {
                            Text(String(item.targetCount))
                                .nurFont(16, weight: .medium)
                            Text("HEDEF")
                                .nurFont(10, weight: .bold)
                        }
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                    }
                    .frame(width: 300, height: 300)
                    .contentShape(Circle())
                }
                .buttonStyle(CounterButtonStyle())
            }
            .frame(width: 320, height: 320)
            
            // Bottom Controls
            HStack(spacing: 40) {
                // Add / Subtract (Maybe just reset for now as per original)
                Button(action: reset) {
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20, weight: .bold))
                        Text("Sıfırla")
                            .nurFont(12, weight: .bold)
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
                
                // Settings for this Dhikr
                Button(action: { /* Future: Edit Target */ }) {
                    VStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 20, weight: .bold))
                        Text("Düzenle")
                            .nurFont(12, weight: .bold)
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
            }
        }
    }
    
    private func increment() {
        if item.vibrateOnCount {
            HapticManager.shared.dhikrCount()
        }

        withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
            item.increment()
            isAnimating = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.2)) {
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
        withAnimation {
            item.reset()
        }
    }
}

struct CounterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.interactiveSpring(), value: configuration.isPressed)
    }
}

#Preview {
    @State var item = DhikrItem(id: UUID(), type: .subhanallah, arabicText: "سبحان الله", transliterationTR: "", meanings: [:], targetCount: 33, currentCount: 10, isCustom: false, vibrateOnCount: true, dailyCompletions: 0, totalCompletions: 0)
    
    return ZStack {
        Color(hex: "0D1B2A").ignoresSafeArea()
        DhikrCounterView(item: $item, language: .tr, fontSize: .large) {}
    }
}
