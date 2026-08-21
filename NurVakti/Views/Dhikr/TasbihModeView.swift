import SwiftUI

struct TasbihStage: Identifiable {
    let id = UUID()
    let nameKey: String
    let count: Int = 33
    let color: Color
    let arabic: String
}

struct TasbihModeView: View {
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    
    @State private var currentStageIndex = 0
    @State private var currentCount = 0
    @State private var totalCompleted = 0
    @State private var isFinished = false
    
    private let stages = [
        TasbihStage(nameKey: "tasbih_subhanallah", color: .blue, arabic: "سُبْحَانَ اللَّهِ"),
        TasbihStage(nameKey: "tasbih_alhamdulillah", color: .green, arabic: "الْحَمْدُ لِلَّهِ"),
        TasbihStage(nameKey: "tasbih_allahuakbar", color: .nurGold, arabic: "اللَّهُ أَكْبَرُ")
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            // Dynamic Background Ambient Glow
            RadialGradient(
                colors: [stages[currentStageIndex].color.opacity(0.12), .clear], 
                center: .center, 
                startRadius: 40, 
                endRadius: 280
            )
            .ignoresSafeArea()
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStageIndex)
            
            VStack(spacing: 32) {
                // Header Progress Dots (VIP Apple Capsule)
                HStack(spacing: 8) {
                    ForEach(0..<3) { idx in
                        Capsule()
                            .fill(idx <= currentStageIndex ? stages[idx].color : Color(hex: "1A1A2E").opacity(0.1))
                            .frame(width: idx == currentStageIndex ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentStageIndex)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                if isFinished {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.nurGold.opacity(0.15))
                                .frame(width: 100, height: 100)
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 54))
                                .foregroundColor(.nurGold)
                        }
                        
                        Text(localization.localizedString("tasbih_finish"))
                            .nurFont(26, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                        
                        Button(action: { router.pop() }) {
                            Text(localization.localizedString("general.done"))
                                .nurFont(16, weight: .bold)
                                .foregroundColor(Color(hex: "1A1A2E"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.nurGold)
                                .cornerRadius(16)
                                .shadow(color: Color.nurGold.opacity(0.3), radius: 8, y: 3)
                        }
                        .buttonStyle(BouncyButtonStyle())
                        .padding(.horizontal, 40)
                        .padding(.top, 12)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    VStack(spacing: 8) {
                        Text(stages[currentStageIndex].arabic)
                            .font(.custom("ScheherazadeNew-Bold", size: 44))
                            .foregroundColor(Color(hex: "2C1E11"))
                        
                        Text(localization.localizedString(stages[currentStageIndex].nameKey))
                            .nurFont(20, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.75))
                    }
                    
                    // Counter Ring (Apple VIP Inset Style)
                    Button(action: increment) {
                        ZStack {
                            Circle()
                                .stroke(Color.black.opacity(0.04), lineWidth: 14)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(currentCount) / 33.0)
                                .stroke(
                                    stages[currentStageIndex].color, 
                                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentCount)
                            
                            VStack(spacing: 4) {
                                Text("\(currentCount)")
                                    .nurFont(68, weight: .heavy, design: .rounded)
                                    .foregroundColor(Color(hex: "1A1A2E"))
                                    .contentTransition(.numericText())
                                
                                Text("33")
                                    .nurFont(13, weight: .bold)
                                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.35))
                            }
                        }
                        .frame(width: 240, height: 240)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 4)
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    if currentStageIndex < 2 {
                        let nextKey = stages[currentStageIndex+1].nameKey
                        Text(String(format: localization.localizedString("tasbih_next"), localization.localizedString(nextKey)))
                            .nurFont(13)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.45))
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func increment() {
        HapticManager.shared.dhikrCount()
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            if currentCount < 32 {
                currentCount += 1
            } else {
                // Stage transition
                if currentStageIndex < 2 {
                    HapticManager.shared.selectionChanged()
                    currentStageIndex += 1
                    currentCount = 0
                } else {
                    // Final finish
                    HapticManager.shared.dhikrDone()
                    isFinished = true
                }
            }
        }
    }
}

#Preview {
    TasbihModeView()
        .environmentObject(LocalizationManager.shared)
        .environmentObject(AppRouter.shared)
}
