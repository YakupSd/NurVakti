import SwiftUI

struct TesbihatView: View {
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    let steps = PrayerGuideData.getDetailedTesbihat()
    
    @State private var currentStepIndex = 0
    @State private var count = 0
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        ZStack {
            Color(hex: "0F172A").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Header
                progressHeader
                    .padding(.top, 10)
                
                TabView(selection: $currentStepIndex) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        stepContent(for: steps[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom Controls
                bottomControls
                    .padding(.bottom, 30)
            }
        }
    }
    
    private var progressHeader: some View {
        HStack(spacing: 6) {
            ForEach(0..<steps.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentStepIndex ? Color.nurGold : (index < currentStepIndex ? Color.nurGold.opacity(0.4) : Color.white.opacity(0.1)))
                    .frame(width: index == currentStepIndex ? 30 : 10, height: 4)
                    .animation(.spring(), value: currentStepIndex)
            }
        }
    }
    
    private func stepContent(for step: PrayerDua) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 10)
                
                VStack(spacing: 16) {
                    Text(step.title(for: localization.currentLanguage))
                        .nurFont(18, weight: .bold)
                        .foregroundColor(.nurGold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text(step.arabicText)
                        .dynamicArabicFont(text: step.arabicText, baseSize: 34)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .lineSpacing(12)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if step.audioFileName != nil || step.audioURL != nil {
                        Button(action: {
                            HapticManager.shared.dhikrCount()
                            if audioManager.isPlaying {
                                audioManager.stop()
                            } else {
                                audioManager.playPrayerDua(step)
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill")
                                Text("dua.listenArabic")
                            }
                            .nurFont(14, weight: .medium)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.nurGold.opacity(0.2))
                            .foregroundColor(.nurGold)
                            .cornerRadius(20)
                        }
                    }
                }
                
                VStack(spacing: 10) {
                    Text(step.transliteration)
                        .dynamicMeaningFont(text: step.transliteration, baseSize: 15)
                        .italic()
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(step.meaning(for: localization.currentLanguage))
                        .dynamicMeaningFont(text: step.meaning(for: localization.currentLanguage), baseSize: 13)
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Interaction Area
                if isCounterStep(step) {
                    counterUI
                        .padding(.top, 8)
                } else {
                    Spacer().frame(height: 100)
                }
                
                Spacer().frame(height: 10)
            }
        }
    }
    
    private var counterUI: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.05), lineWidth: 12)
                .frame(width: 180, height: 180)
            
            Circle()
                .trim(from: 0, to: CGFloat(count) / 33.0)
                .stroke(
                    LinearGradient(colors: [.nurGold, .nurGold.opacity(0.5)], startPoint: .top, endPoint: .bottom),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(-90))
            
            Text("\(count)")
                .nurFont(60, weight: .bold)
                .foregroundColor(.white)
        }
        .onTapGesture {
            increment()
        }
    }
    
    private var isLastStep: Bool {
        currentStepIndex == steps.count - 1
    }
    
    private var bottomControls: some View {
        HStack(spacing: 40) {
            Button(action: prevStep) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(currentStepIndex > 0 ? .white : .white.opacity(0.1))
            }
            .disabled(currentStepIndex == 0)
            
            if isLastStep {
                // Son sayfada "Bitir" butonu
                Button(action: {
                    HapticManager.shared.success()
                    audioManager.stop()
                    dismiss()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.nurGold)
                            .frame(width: 80, height: 80)
                            .shadow(color: .nurGold.opacity(0.4), radius: 12, y: 5)
                        
                        VStack(spacing: 2) {
                            Image(systemName: "checkmark")
                                .font(.title2.bold())
                                .foregroundColor(.black)
                            Text("Bitir")
                                .font(.caption.bold())
                                .foregroundColor(.black)
                        }
                    }
                }
            } else {
                Button(action: increment) {
                    ZStack {
                        Circle()
                            .fill(Color.nurGold)
                            .frame(width: 80, height: 80)
                            .shadow(color: .nurGold.opacity(0.3), radius: 10, y: 5)
                        
                        Image(systemName: isCounterStep(steps[currentStepIndex]) ? "plus" : "chevron.right")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }
            }
            
            Button(action: nextStep) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(currentStepIndex < steps.count - 1 ? .white : .white.opacity(0.1))
            }
            .disabled(isLastStep)
        }
        .padding(.horizontal, 40)
    }
    
    private func isCounterStep(_ step: PrayerDua) -> Bool {
        return step.title(for: .tr).contains("33x") || step.title(for: .en).contains("33x")
    }
    
    private func increment() {
        HapticManager.shared.dhikrCount()
        if isCounterStep(steps[currentStepIndex]) {
            if count < 33 {
                withAnimation(.spring()) {
                    count += 1
                }
                if count == 33 {
                    HapticManager.shared.success()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        nextStep()
                    }
                }
            }
        } else {
            nextStep()
        }
    }
    
    private func nextStep() {
        if currentStepIndex < steps.count - 1 {
            withAnimation {
                currentStepIndex += 1
                count = 0
                audioManager.stop()
            }
        }
    }
    
    private func prevStep() {
        if currentStepIndex > 0 {
            withAnimation {
                currentStepIndex -= 1
                count = 0
                audioManager.stop()
            }
        }
    }
}
