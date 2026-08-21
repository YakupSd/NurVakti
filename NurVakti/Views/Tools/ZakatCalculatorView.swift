import SwiftUI

struct ZakatCalculatorView: View {
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    
    @State private var assets = ZakatAssets()
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Step Indicator (VIP Capsule)
                HStack(spacing: 6) {
                    ForEach(0..<5) { step in
                        Capsule()
                            .fill(step <= currentStep ? Color.nurGold : Color(hex: "1A1A2E").opacity(0.1))
                            .frame(height: 5)
                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentStep)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if currentStep == 0 {
                            stepView(title: "zakat.step.cash", icon: "banknote.fill") {
                                zakatInput(label: "zakat.cash", value: $assets.cash)
                                zakatInput(label: "zakat.receivables", value: $assets.receivables)
                            }
                        } else if currentStep == 1 {
                            stepView(title: "zakat.step.precious", icon: "bitcoinsign.circle.fill") {
                                zakatInput(label: "zakat.gold", value: $assets.goldGrams, unit: "g")
                                zakatInput(label: "zakat.silver", value: $assets.silverGrams, unit: "g")
                            }
                        } else if currentStep == 2 {
                            stepView(title: "zakat.step.trade", icon: "cart.fill") {
                                zakatInput(label: "zakat.tradeGoods", value: $assets.tradeGoods)
                            }
                        } else if currentStep == 3 {
                            stepView(title: "zakat.step.debts", icon: "minus.circle.fill") {
                                zakatInput(label: "zakat.debts", value: $assets.debts)
                            }
                        } else {
                            resultView
                        }
                    }
                    .padding(20)
                }
                
                // Footer Buttons
                HStack(spacing: 14) {
                    if currentStep > 0 && currentStep < 4 {
                        Button(action: {
                            HapticManager.shared.light()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                currentStep -= 1
                            }
                        }) {
                            Text(localization.localizedString("general.back"))
                                .nurFont(15, weight: .bold)
                                .foregroundColor(Color(hex: "1A1A2E"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                    
                    if currentStep < 4 {
                        Button(action: {
                            HapticManager.shared.light()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                currentStep += 1
                            }
                        }) {
                            Text(localization.localizedString("general.next"))
                                .nurFont(15, weight: .bold)
                                .foregroundColor(Color(hex: "1A1A2E"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.nurGold)
                                .cornerRadius(16)
                                .shadow(color: Color.nurGold.opacity(0.3), radius: 8, y: 3)
                        }
                        .buttonStyle(BouncyButtonStyle())
                    } else {
                        Button(action: {
                            HapticManager.shared.success()
                            router.pop()
                        }) {
                            Text(localization.localizedString("general.done"))
                                .nurFont(15, weight: .bold)
                                .foregroundColor(Color(hex: "1A1A2E"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.nurGold)
                                .cornerRadius(16)
                                .shadow(color: Color.nurGold.opacity(0.3), radius: 8, y: 3)
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
    
    private func stepView<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.nurGold.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.nurGold)
            }
            .padding(.top, 10)
            
            Text(localization.localizedString(title))
                .nurFont(22, weight: .bold)
                .foregroundColor(Color(hex: "1A1A2E"))
            
            VStack(spacing: 16) {
                content()
            }
        }
    }
    
    private func zakatInput(label: String, value: Binding<Double>, unit: String = "") -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(localization.localizedString(label))
                .nurFont(12, weight: .bold)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.65))
            
            HStack {
                TextField("0", value: value, format: .number)
                    .keyboardType(.decimalPad)
                    .nurFont(18, weight: .bold, design: .rounded)
                    .foregroundColor(Color(hex: "1A1A2E"))
                
                if !unit.isEmpty {
                    Text(unit)
                        .nurFont(14, weight: .bold)
                        .foregroundColor(.nurGold)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
        }
    }
    
    private var resultView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill((assets.isEligible ? Color.green : Color.nurGold).opacity(0.12))
                    .frame(width: 84, height: 84)
                Image(systemName: assets.isEligible ? "checkmark.circle.fill" : "info.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(assets.isEligible ? .green : .nurGold)
            }
            
            VStack(spacing: 6) {
                Text(localization.localizedString(assets.isEligible ? "zakat.result.eligible" : "zakat.result.notEligible"))
                    .nurFont(22, weight: .bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "1A1A2E"))
                
                if assets.isEligible {
                    Text(localization.localizedString("zakat.result.due"))
                        .nurFont(14)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                    
                    Text("\(assets.zakatDue, specifier: "%.2f") ₺")
                        .nurFont(42, weight: .heavy, design: .rounded)
                        .foregroundColor(.nurGold)
                }
            }
            
            VStack(spacing: 12) {
                resultRow(label: "zakat.totalAssets", value: assets.totalValue)
                Divider().opacity(0.06)
                resultRow(label: "zakat.nisabThreshold", value: assets.nisabThreshold)
            }
            .padding(18)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, y: 2)
        }
    }
    
    private func resultRow(label: String, value: Double) -> some View {
        HStack {
            Text(localization.localizedString(label))
                .nurFont(13)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
            Spacer()
            Text("\(value, specifier: "%.2f") ₺")
                .nurFont(14, weight: .bold, design: .rounded)
                .foregroundColor(Color(hex: "1A1A2E"))
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "F8F6F0").ignoresSafeArea()
        ZakatCalculatorView()
            .environmentObject(LocalizationManager.shared)
            .environmentObject(AppRouter.shared)
    }
}
