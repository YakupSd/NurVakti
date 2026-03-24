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
            Color(hex: "0F172A").ignoresSafeArea()
            
            // Dynamic Background Glow
            RadialGradient(colors: [stages[currentStageIndex].color.opacity(0.15), .clear], 
                           center: .center, startRadius: 0, endRadius: 300)
                .ignoresSafeArea()
                .animation(.easeInOut, value: currentStageIndex)
            
            VStack(spacing: 40) {
                // Header Progress
                HStack {
                    Spacer()
                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<3) { idx in
                            Circle()
                                .fill(idx == currentStageIndex ? stages[idx].color : Color.white.opacity(0.1))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                Spacer()
                
                if isFinished {
                    VStack(spacing: 24) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.nurGold)
                        Text(localization.localizedString("tasbih_finish"))
                            .nurFont(28, weight: .bold)
                            .foregroundColor(.white)
                        
                        Button(action: { router.pop() }) {
                            Text(localization.localizedString("general.done"))
                                .nurFont(18, weight: .bold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 14)
                                .background(Color.nurGold)
                                .cornerRadius(20)
                        }
                        
                        Button(action: {
                            router.pop()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                router.pushTo(
                                    view: MainNavigationView.builder.makeView(
                                        AddDhikrView(vm: DhikrViewModel()),
                                        withNavigationTitle: localization.localizedString("dhikr.addNew"),
                                        isShowRightButton: false
                                    )
                                )
                            }
                        }) {
                            Text("Özel Zikir Ekle")
                                .nurFont(14, weight: .bold)
                                .foregroundColor(.nurGold.opacity(0.8))
                                .underline()
                        }
                        .padding(.top, 8)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    VStack(spacing: 12) {
                        Text(stages[currentStageIndex].arabic)
                            .font(.custom("Traditional Arabic", size: 60))
                            .foregroundColor(.white)
                            .shadow(color: stages[currentStageIndex].color.opacity(0.5), radius: 10)
                        
                        Text(localization.localizedString(stages[currentStageIndex].nameKey))
                            .nurFont(22, weight: .medium)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Counter Ring
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.05), lineWidth: 15)
                        Circle()
                            .trim(from: 0, to: CGFloat(currentCount) / 33.0)
                            .stroke(stages[currentStageIndex].color, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(), value: currentCount)
                        
                        Text("\(currentCount)")
                            .nurFont(64, weight: .bold)
                            .foregroundColor(.white)
                    }
                    .frame(width: 240, height: 240)
                    .contentShape(Circle())
                    .onTapGesture {
                        increment()
                    }
                    
                    if currentStageIndex < 2 {
                        let nextKey = stages[currentStageIndex+1].nameKey
                        Text(String(format: localization.localizedString("tasbih_next"), localization.localizedString(nextKey)))
                            .nurFont(14)
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                Spacer()
                
                Text(localization.localizedString("dhikr.addHint")) // Or similar info
                    .nurFont(12)
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.bottom)
            }
        }
    }
    
    private func increment() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        withAnimation {
            if currentCount < 32 {
                currentCount += 1
            } else {
                // Stage transition
                if currentStageIndex < 2 {
                    UISelectionFeedbackGenerator().selectionChanged()
                    currentStageIndex += 1
                    currentCount = 0
                } else {
                    // Final finish
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    isFinished = true
                }
            }
        }
    }
}
