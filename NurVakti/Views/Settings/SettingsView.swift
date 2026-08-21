import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject var vm: SettingsViewModel
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        ZStack {
            // Background — Warm Cream Light Luxury
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 8)
                    
                    // 1. DİL SEÇİMİ (Language Selection)
                    languageSection
                    
                    // 2. GÖRÜNÜM VE YAZI BOYUTU (Appearance & Font Size)
                    appearanceSection
                    
                    // 3. HESAPLAMA VE MEZHEP (Calculation & Madhab)
                    calculationSection
                    
                    // 4. BİLDİRİMLER VE İZİNLER (Notifications)
                    notificationSection
                    
                    // 5. UYGULAMA VE DESTEK (App Info & Review)
                    appInfoSection
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            Task { await vm.onAppear() }
        }
    }
    
    // MARK: - 1. Dil Seçimi Section
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: localization.localizedString("settings.language"), icon: "globe")
            
            VStack(spacing: 8) {
                let languages: [(LanguageCode, String, String)] = [
                    (.tr, "🇹🇷", "Türkçe"),
                    (.en, "🇬🇧", "English"),
                    (.ar, "🇸🇦", "العربية"),
                    (.de, "🇩🇪", "Deutsch"),
                    (.pt, "🇧🇷", "Português")
                ]
                
                ForEach(languages, id: \.0) { code, flag, name in
                    let isSelected = vm.selectedLanguage == code
                    Button(action: {
                        HapticManager.shared.selectionChanged()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            vm.selectedLanguage = code
                            vm.changeLanguage(code)
                        }
                    }) {
                        HStack(spacing: 14) {
                            Text(flag)
                                .font(.title3)
                            
                            Text(name)
                                .nurFont(15, weight: isSelected ? .bold : .semibold)
                                .foregroundColor(Color(hex: "1A1A2E"))
                            
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.nurGold)
                            } else {
                                Circle()
                                    .stroke(Color(hex: "1A1A2E").opacity(0.12), lineWidth: 1.5)
                                    .frame(width: 18, height: 18)
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.nurGold : Color(hex: "1A1A2E").opacity(0.06), lineWidth: isSelected ? 1.5 : 1)
                        )
                        .shadow(color: isSelected ? Color.nurGold.opacity(0.15) : Color.black.opacity(0.02), radius: 6, y: 2)
                    }
                    .buttonStyle(CardPressableButtonStyle(scale: 0.98))
                }
            }
        }
    }
    
    // MARK: - 2. Görünüm ve Yazı Boyutu Section
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: localization.localizedString("settings.appearance"), icon: "textformat.size")
            
            VStack(spacing: 16) {
                // Font Size Selector Pills
                HStack(spacing: 8) {
                    ForEach(FontSize.allCases, id: \.self) { size in
                        let isSelected = vm.fontSize == size
                        Button(action: {
                            HapticManager.shared.light()
                            withAnimation(.spring()) {
                                vm.changeFontSize(size)
                            }
                        }) {
                            VStack(spacing: 4) {
                                Text("A")
                                    .font(.system(size: fontSizeToDisplay(size), weight: .bold))
                                Text(fontSizeLabel(size))
                                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isSelected ? Color.nurGold : Color(hex: "1A1A2E").opacity(0.04))
                            .foregroundColor(isSelected ? Color.white : Color(hex: "1A1A2E").opacity(0.75))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isSelected ? Color.nurGold : Color.clear, lineWidth: 1.5)
                            )
                        }
                    }
                }
                
                // Canlı Önizleme Kartı (Proper Arabic & Translation Preview)
                VStack(spacing: 8) {
                    Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                        .font(.custom("Amiri-Bold", size: previewArabicSize(vm.fontSize)))
                        .foregroundColor(Color(hex: "8A5A00"))
                    
                    Text("Rahmân ve Rahîm olan Allah'ın adıyla")
                        .nurFont(previewTrSize(vm.fontSize), weight: .semibold)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "1A1A2E").opacity(0.03))
                .cornerRadius(14)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
        }
    }
    
    // MARK: - 3. Hesaplama ve Mezhep Section
    private var calculationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: localization.localizedString("settings.calculation"), icon: "calendar.badge.clock")
            
            VStack(spacing: 16) {
                // Mezhep Seçimi (Segmented Wide Selector)
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.nurGold)
                        Text(localization.localizedString("settings.madhab"))
                            .nurFont(15, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        ForEach(Madhab.allCases, id: \.self) { m in
                            let isSelected = vm.madhab == m
                            Button(action: {
                                HapticManager.shared.light()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    vm.changeMadhab(m)
                                }
                            }) {
                                Text(m.displayName(for: localization.currentLanguage))
                                    .nurFont(13, weight: isSelected ? .bold : .medium)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(isSelected ? Color.nurGold : Color(hex: "1A1A2E").opacity(0.06))
                                    .foregroundColor(isSelected ? Color.white : Color(hex: "1A1A2E").opacity(0.7))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                
                Divider()
                    .background(Color(hex: "1A1A2E").opacity(0.06))
                
                // Hesaplama Metodu
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.nurGold)
                        Text(localization.localizedString("settings.method"))
                            .nurFont(15, weight: .bold)
                            .foregroundColor(Color(hex: "1A1A2E"))
                    }
                    
                    Spacer()
                    
                    Menu {
                        ForEach(AppConstants.supportedCalcMethods, id: \.self) { method in
                            Button(method) {
                                HapticManager.shared.selectionChanged()
                                vm.changeCalcMethod(method)
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(vm.calcMethod)
                                .nurFont(14, weight: .bold)
                                .foregroundColor(.nurGold)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.nurGold)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.nurGold.opacity(0.12))
                        .cornerRadius(10)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
        }
    }
    
    // MARK: - 4. Bildirimler Section
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: localization.localizedString("settings.notifications"), icon: "bell.badge.fill")
            
            HStack(spacing: 14) {
                Image(systemName: vm.notifStatus == .authorized ? "checkmark.seal.fill" : "bell.slash.fill")
                    .font(.system(size: 24))
                    .foregroundColor(vm.notifStatus == .authorized ? Color(hex: "#10B981") : .orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.notifStatus == .authorized
                         ? localization.localizedString("settings.notifAuthorized")
                         : localization.localizedString("settings.notifRequired"))
                        .nurFont(14, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E"))
                    
                    Text(vm.notifStatus == .authorized ? "Ezan ve vakit uyarıları aktif" : "Vakitleri kaçırmamak için izin verin")
                        .nurFont(12)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                }
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.light()
                    vm.openAppSettings()
                }) {
                    Text(localization.localizedString("settings.goToApps"))
                        .nurFont(12, weight: .bold)
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.nurGold)
                        .cornerRadius(12)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 6, y: 2)
        }
    }
    
    // MARK: - 5. Uygulama Bilgisi Section
    private var appInfoSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                HapticManager.shared.success()
                vm.requestReview()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.nurGold)
                        .font(.system(size: 14))
                    Text(localization.localizedString("settings.rateApp"))
                        .nurFont(14, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E"))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.nurGold.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, y: 1)
            }
            
            VStack(spacing: 4) {
                Text("NurVakti © 2026")
                    .nurFont(12, weight: .semibold)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                
                Text(String(format: localization.localizedString("settings.versionInfo"), vm.appVersion, vm.buildNumber))
                    .nurFont(11)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.35))
            }
            .padding(.top, 6)
        }
    }
    
    // MARK: - Section Header Helper
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.nurGold)
            Text(title.uppercased())
                .nurFont(11, weight: .bold)
                .foregroundColor(Color(hex: "8A5A00"))
                .tracking(1.4)
        }
        .padding(.leading, 4)
    }
    
    private func fontSizeLabel(_ size: FontSize) -> String {
        switch size {
        case .small:  return "Küçük"
        case .medium: return "Orta"
        case .large:  return "Büyük"
        case .xlarge: return "Ekstra"
        }
    }
    
    private func fontSizeToDisplay(_ size: FontSize) -> CGFloat {
        switch size {
        case .small:  return 13
        case .medium: return 16
        case .large:  return 19
        case .xlarge: return 22
        }
    }
    
    private func previewArabicSize(_ size: FontSize) -> CGFloat {
        switch size {
        case .small:  return 18
        case .medium: return 22
        case .large:  return 26
        case .xlarge: return 30
        }
    }
    
    private func previewTrSize(_ size: FontSize) -> CGFloat {
        switch size {
        case .small:  return 13
        case .medium: return 15
        case .large:  return 17
        case .xlarge: return 19
        }
    }
}

#Preview {
    SettingsView(vm: SettingsViewModel())
        .environmentObject(LocalizationManager.shared)
}
