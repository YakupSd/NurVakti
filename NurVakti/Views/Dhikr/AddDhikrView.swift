import SwiftUI

struct AddDhikrView: View {
    @ObservedObject var vm: DhikrViewModel
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        ZStack {
            Color(hex: "0D1B2A").ignoresSafeArea()
            
            VStack(spacing: 24) {
                ScrollView {
                    VStack(spacing: 30) {
                        // Zikir İsmi
                        inputField(title: localization.localizedString("dhikr.name"), 
                                   placeholder: localization.localizedString("dhikr.subhanallah"), 
                                   text: $vm.newDhikrName)
                        
                        // Arapça Metin
                        VStack(alignment: .leading, spacing: 12) {
                            Text(localization.localizedString("dhikr.arabicOptional"))
                                .nurFont(14, weight: .bold)
                                .foregroundColor(.nurGold)
                            
                            ZStack(alignment: .topTrailing) {
                                TextEditor(text: $vm.newDhikrArabic)
                                    .scrollContentBackground(.hidden) // Show background
                                    .frame(height: 120)
                                    .padding(12)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(16)
                                    .foregroundColor(.white)
                                    .nurFont(24)
                                
                                if vm.newDhikrArabic.isEmpty {
                                    Text(localization.localizedString("dhikr.subhanallah") + "...")
                                        .nurFont(24)
                                        .foregroundColor(.white.opacity(0.1))
                                        .padding(20)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        
                        // Hedef Sayı
                        inputField(title: localization.localizedString("dhikr.targetCount"), 
                                   placeholder: "33, 99, 100...", 
                                   text: $vm.newDhikrTarget, 
                                   keyboardType: .numberPad)
                        
                        Text(localization.localizedString("dhikr.addHint"))
                            .nurFont(13)
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.horizontal)
                    }
                    .padding()
                }
            }
        }
    }
    
    private func inputField(title: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .nurFont(14, weight: .bold)
                .foregroundColor(.nurGold)
            
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .padding(16)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}
