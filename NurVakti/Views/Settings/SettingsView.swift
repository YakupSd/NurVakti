import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject var vm: SettingsViewModel
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        ZStack {
            // Arka plan: Zengin Gradyan
            // Arka plan: Zengin Gradyan
            LinearGradient(colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")], 
                           startPoint: .topLeading, 
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            StarFieldView(opacity: 0.3)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // ÜSTBAR / BAŞLIK
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(localization.localizedString("settings.title"))
                                .font(.system(size: 36, weight: .black))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "gearshape.fill")
                                .font(.title)
                                .foregroundColor(.nurGold)
                        }
                        Text(localization.localizedString("settings.journeyHint"))
                            .nurFont(14)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 20)
                    
                    // ── DİL SEÇİMİ ──
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: localization.localizedString("settings.language"), icon: "globe")
                        
                        LanguagePicker(selectedLanguage: $vm.selectedLanguage) { code in
                            HapticManager.shared.success()
                            vm.changeLanguage(code)
                        }
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(24)
                    }
                    
                    // ── GÖRÜNÜM (Font) ──
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: localization.localizedString("settings.appearance"), icon: "textformat.size")
                        
                        NurCard {
                            VStack(spacing: 24) {
                                // Gelişmiş Font Seçici (AAA)
                                HStack(spacing: 12) {
                                    ForEach(FontSize.allCases, id: \.self) { size in
                                        Button(action: { 
                                            HapticManager.shared.light()
                                            vm.changeFontSize(size) 
                                        }) {
                                            VStack(spacing: 8) {
                                                Text("A")
                                                    .font(.system(size: fontSizeToDisplay(size), weight: .bold))
                                                Text(size.rawValue.capitalized)
                                                    .font(.system(size: 10))
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 70)
                                            .background(vm.fontSize == size ? Color.nurGold : Color.white.opacity(0.05))
                                            .foregroundColor(vm.fontSize == size ? .black : .white)
                                            .cornerRadius(16)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(vm.fontSize == size ? Color.nurGold : Color.clear, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                
                                // Canlı Önizleme
                                VStack(alignment: .center, spacing: 12) {
                                    Text(localization.localizedString("settings.previewText"))
                                        .nurFont(12)
                                        .foregroundColor(.white.opacity(0.4))
                                    
                                    Text("Bismillahirrahmanirrahim")
                                        .nurFont(20, weight: .bold) // scaled font test
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(.white.opacity(0.05))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(.white.opacity(0.1), lineWidth: 1)
                                                )
                                        )
                                }
                            }
                        }
                    }
                    
                    // ── KONUM & HESAPLAMA ──
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: localization.localizedString("settings.calculation"), icon: "location.viewfinder")
                        
                        NurCard {
                            VStack(spacing: 20) {
                                // Mezhep (Stil Değişikliği)
                                settingRow(title: localization.localizedString("settings.madhab"), icon: "person.2.fill") {
                                    HStack(spacing: 8) {
                                        ForEach(Madhab.allCases, id: \.self) { m in
                                            Button(m.displayName(for: localization.currentLanguage)) {
                                                HapticManager.shared.light()
                                                vm.changeMadhab(m)
                                            }
                                            .font(.system(size: 13, weight: .bold))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(vm.madhab == m ? Color.nurGold : Color.white.opacity(0.1))
                                            .foregroundColor(vm.madhab == m ? .black : .white)
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                // Hesap Metodu
                                settingRow(title: localization.localizedString("settings.method"), icon: "calendar.badge.clock") {
                                    Menu {
                                        ForEach(AppConstants.supportedCalcMethods, id: \.self) { method in
                                            Button(method) { vm.changeCalcMethod(method) }
                                        }
                                    } label: {
                                        HStack {
                                            Text(vm.calcMethod)
                                                .font(.system(size: 14, weight: .bold))
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12))
                                        }
                                        .foregroundColor(.nurGold)
                                    }
                                }
                            }
                        }
                    }
                    
                    // ── BİLDİRİMLER ──
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: localization.localizedString("settings.notifications"), icon: "bell.badge.fill")
                        
                        NurCard {
                            HStack {
                                Image(systemName: vm.notifStatus == .authorized ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                    .foregroundColor(vm.notifStatus == .authorized ? .green : .orange)
                                    .font(.title2)
                                
                                Text(vm.notifStatus == .authorized ? localization.localizedString("settings.notifAuthorized") : localization.localizedString("settings.notifRequired"))
                                    .nurFont(16, weight: .bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(localization.localizedString("settings.goToApps")) {
                                    HapticManager.shared.light()
                                    vm.openAppSettings()
                                }
                                .nurFont(13, weight: .bold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.nurGold)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    // ── FOOTER ──
                    VStack(spacing: 12) {
                        Text("NurVakti © 2024")
                            .nurFont(12)
                            .foregroundColor(.white.opacity(0.4))
                        
                        Text(String(format: localization.localizedString("settings.versionInfo"), vm.appVersion, vm.buildNumber))
                            .nurFont(10)
                            .foregroundColor(.white.opacity(0.3))
                        
                        NurButton(title: localization.localizedString("settings.rateApp"), style: .secondary, fontSize: .small) {
                            HapticManager.shared.success()
                            // Rate implementation
                        }
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 50)
                }
                .padding(.horizontal)
            }
        }
        .onAppear { Task { await vm.onAppear() } }
    }
    
    // Yardımcı Görünüm: Ayar Satırı
    private func settingRow<V: View>(title: String, icon: String, @ViewBuilder content: () -> V) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.nurGold.opacity(0.8))
                .frame(width: 24)
            Text(title)
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            content()
        }
    }
    
    private func fontSizeToDisplay(_ size: FontSize) -> CGFloat {
        switch size {
        case .small: return 14
        case .medium: return 18
        case .large: return 22
        case .xlarge: return 26
        }
    }
}

#Preview {
    SettingsView(vm: SettingsViewModel())
        .environmentObject(LocalizationManager.shared)
}
