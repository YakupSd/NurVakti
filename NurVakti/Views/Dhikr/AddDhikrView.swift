import SwiftUI

struct AddDhikrView: View {
    @ObservedObject var vm: DhikrViewModel
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Zikir İsmi
                    inputField(
                        title: localization.localizedString("dhikr.name"), 
                        placeholder: localization.localizedString("dhikr.subhanallah"), 
                        text: $vm.newDhikrName
                    )
                    
                    // Arapça Metin (Opsiyonel)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localization.localizedString("dhikr.arabicOptional"))
                            .nurFont(12, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                        
                        ZStack(alignment: .topTrailing) {
                            TextEditor(text: $vm.newDhikrArabic)
                                .scrollContentBackground(.hidden)
                                .frame(height: 100)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(16)
                                .foregroundColor(Color(hex: "1A1A2E"))
                                .font(.custom("ScheherazadeNew-Bold", size: 22))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
                            
                            if vm.newDhikrArabic.isEmpty {
                                Text(localization.localizedString("dhikr.subhanallah") + "...")
                                    .font(.custom("ScheherazadeNew-Bold", size: 20))
                                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.2))
                                    .padding(16)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    
                    // Hedef Sayı (Standart VIP 54px Input)
                    inputField(
                        title: localization.localizedString("dhikr.targetCount"), 
                        placeholder: "33, 99, 100...", 
                        text: $vm.newDhikrTarget, 
                        keyboardType: .numberPad
                    )
                    
                    // Açıklama / İpucu Kartı
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.nurGold)
                        
                        Text(localization.localizedString("dhikr.addHint"))
                            .nurFont(12)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.nurGold.opacity(0.08))
                    .cornerRadius(14)
                    .padding(.top, 8)
                }
                .padding(20)
            }
        }
    }
    
    private func inputField(title: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .nurFont(12, weight: .bold)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
            
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .nurFont(15)
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(Color.white)
                .cornerRadius(16)
                .foregroundColor(Color(hex: "1A1A2E"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
        }
    }
}

#Preview {
    AddDhikrView(vm: DhikrViewModel())
        .environmentObject(LocalizationManager.shared)
        .environmentObject(AppRouter.shared)
}
