import SwiftUI

struct ZakatCalculatorView: View {
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    
    @State private var assets = ZakatAssets()
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            Color(hex: "0F172A").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Step Indicator
                HStack {
                    Spacer()
                    Text("\(currentStep + 1) / 5")
                        .nurFont(14, weight: .medium)
                        .foregroundColor(.nurGold)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                ScrollView {
                    VStack(spacing: 30) {
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
                    .padding()
                }
                
                // Footer Buttons
                HStack(spacing: 16) {
                    if currentStep > 0 && currentStep < 4 {
                        Button(action: { withAnimation { currentStep -= 1 } }) {
                            Text(localization.localizedString("general.back"))
                                .nurFont(16, weight: .bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    
                    if currentStep < 4 {
                        Button(action: { withAnimation { currentStep += 1 } }) {
                            Text(localization.localizedString("general.next"))
                                .nurFont(16, weight: .bold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.nurGold)
                                .cornerRadius(12)
                        }
                    } else {
                        Button(action: { router.pop() }) {
                            Text(localization.localizedString("general.done"))
                                .nurFont(16, weight: .bold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.nurGold)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private func stepView<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.nurGold)
                .padding(.top, 20)
            
            Text(localization.localizedString(title))
                .nurFont(24, weight: .bold)
                .foregroundColor(.white)
            
            VStack(spacing: 20) {
                content()
            }
        }
    }
    
    private func zakatInput(label: String, value: Binding<Double>, unit: String = "") -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localization.localizedString(label))
                .nurFont(14, weight: .medium)
                .foregroundColor(.white.opacity(0.6))
            
            HStack {
                TextField("0", value: value, format: .number)
                    .keyboardType(.decimalPad)
                    .nurFont(20, weight: .bold)
                    .foregroundColor(.white)
                
                if !unit.isEmpty {
                    Text(unit)
                        .nurFont(16, weight: .bold)
                        .foregroundColor(.nurGold)
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    private var resultView: some View {
        VStack(spacing: 32) {
            Image(systemName: assets.isEligible ? "checkmark.circle.fill" : "info.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(assets.isEligible ? .green : .nurGold)
            
            VStack(spacing: 8) {
                Text(localization.localizedString(assets.isEligible ? "zakat.result.eligible" : "zakat.result.notEligible"))
                    .nurFont(24, weight: .bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                if assets.isEligible {
                    Text(localization.localizedString("zakat.result.due"))
                        .nurFont(16)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("\(assets.zakatDue, specifier: "%.2f")")
                        .nurFont(48, weight: .bold)
                        .foregroundColor(.nurGold)
                }
            }
            
            VStack(spacing: 16) {
                resultRow(label: "zakat.totalAssets", value: assets.totalValue)
                resultRow(label: "zakat.nisabThreshold", value: assets.nisabThreshold)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(20)
        }
    }
    
    private func resultRow(label: String, value: Double) -> some View {
        HStack {
            Text(localization.localizedString(label))
                .nurFont(14)
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text("\(value, specifier: "%.2f")")
                .nurFont(14, weight: .bold)
                .foregroundColor(.white)
        }
    }
}
