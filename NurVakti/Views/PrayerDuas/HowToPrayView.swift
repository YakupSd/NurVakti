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
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── Progress Indicators ──
                progressIndicatorView
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
                
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Progress Indicators Component
    private var progressIndicatorView: some View {
        HStack(spacing: 6) {
            ForEach(0..<steps.count, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStepIndex ? Color.nurGold : Color(hex: "1A1A2E").opacity(0.08))
                    .frame(height: 5)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentStepIndex)
            }
        }
    }
    
    // MARK: - Navigation Controls Component
    private var navigationControls: some View {
        HStack(spacing: 16) {
            // Previous Button
            if currentStepIndex > 0 {
                Button(action: {
                    HapticManager.shared.light()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        currentStepIndex -= 1
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "1A1A2E"))
                        .frame(width: 52, height: 52)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
                }
                .buttonStyle(BouncyButtonStyle())
            }
            
            // Next / Finish Button
            Button(action: {
                if currentStepIndex < steps.count - 1 {
                    HapticManager.shared.light()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        currentStepIndex += 1
                    }
                } else {
                    HapticManager.shared.success()
                    dismiss()
                }
            }) {
                HStack(spacing: 8) {
                    Text(currentStepIndex < steps.count - 1 
                         ? localization.localizedString("general.next") 
                         : localization.localizedString("general.finish"))
                        .nurFont(15, weight: .bold)
                    
                    Image(systemName: currentStepIndex < steps.count - 1 ? "arrow.right" : "checkmark")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(Color(hex: "1A1A2E"))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#D4AF37"), Color(hex: "#C9A84C")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.nurGold.opacity(0.3), radius: 8, y: 3)
            }
            .buttonStyle(BouncyButtonStyle())
        }
    }
}

#Preview {
    HowToPrayView()
        .environmentObject(LocalizationManager.shared)
}
