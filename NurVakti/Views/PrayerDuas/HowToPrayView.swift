import SwiftUI

struct HowToPrayView: View {
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    let steps = PrayerGuideData.getPrayerSteps()
    
    @State private var currentStepIndex = 0
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            // ── Background ──
            LinearGradient(
                colors: [.prayerBgTop, .prayerBgBot],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── Progress Indicators ──
                progressIndicatorView
                    .padding(.top, 16)
                
                // ── Paged Content ──
                TabView(selection: $currentStepIndex) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        PrayerStepInteractiveView(step: steps[index], language: localization.currentLanguage)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // ── Navigation Controls ──
                navigationControls
                    .padding(.bottom, 34)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                // Entrance animation trigger if needed
            }
        }
    }
    
    // MARK: - Header Component
    private var headerView: some View {
        HStack {
            // Back Button
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .stroke(
                                LinearGradient(colors: [.prayerGold, .prayerOrange], startPoint: .top, endPoint: .bottom),
                                lineWidth: 2
                            )
                    )
            }
            
            Spacer()
            
            // Title
            Text("Namaz Nasıl Kılınır?")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Counter
            Text("\(currentStepIndex + 1)/\(steps.count)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.prayerGold)
        }
    }
    
    // MARK: - Progress Indicators Component
    private var progressIndicatorView: some View {
        HStack(spacing: 8) {
            ForEach(0..<steps.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(progressColor(for: index))
                    .frame(width: 40, height: 6)
                    .overlay(
                        Group {
                            if index < currentStepIndex {
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.prayerGold.opacity(0.5), lineWidth: 1)
                                    .blur(radius: 2)
                            }
                        }
                    )
                    .modifier(ProgressAnimationModifier(isActive: index == currentStepIndex))
            }
        }
    }
    
    private func progressColor(for index: Int) -> AnyShapeStyle {
        if index < currentStepIndex {
            return AnyShapeStyle(LinearGradient(colors: [.prayerGold, .prayerOrange], startPoint: .leading, endPoint: .trailing))
        } else if index == currentStepIndex {
            return AnyShapeStyle(Color.prayerGold)
        } else {
            return AnyShapeStyle(Color.prayerBarPending.opacity(0.3))
        }
    }
    
    // MARK: - Navigation Controls
    private var navigationControls: some View {
        HStack(spacing: 16) {
            // Circular Back Button
            Button(action: prevStep) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.prayerCard)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.prayerBarPending, lineWidth: 2)
                    )
            }
            .buttonStyle(ScaleButtonStyle(scale: 0.95))
            .opacity(currentStepIndex > 0 ? 1 : 0.5)
            .disabled(currentStepIndex == 0)
            
            // Next / Finish Button
            Button(action: nextStep) {
                Text(currentStepIndex == steps.count - 1 ? "Bitir" : "Sonraki")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.prayerDarkText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(colors: [.prayerGold, .prayerOrange], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(16)
                    .shadow(color: .prayerGold.opacity(0.4), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(ScaleButtonStyle(scale: 0.95))
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Actions
    private func nextStep() {
        if currentStepIndex < steps.count - 1 {
            withAnimation(.easeInOut(duration: 0.6)) {
                currentStepIndex += 1
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } else {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            dismiss()
        }
    }
    
    private func prevStep() {
        if currentStepIndex > 0 {
            withAnimation(.easeInOut(duration: 0.6)) {
                currentStepIndex -= 1
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

// MARK: - Helper Modifiers
struct ProgressAnimationModifier: ViewModifier {
    let isActive: Bool
    func body(content: Content) -> some View {
        if isActive {
            content.pulseAnimation()
        } else {
            content
        }
    }
}

