import SwiftUI

struct AlarmView: View {
    @StateObject var vm: AlarmViewModel
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // İZİN BANNER
                    if vm.permissionStatus != .authorized {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "bell.badge.fill")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                                Text(localization.localizedString("alarm.permissionRequired"))
                                    .nurFont(16, weight: .bold)
                                    .foregroundColor(Color(hex: "1A1A2E"))
                                Spacer()
                            }
                            
                            Text(localization.localizedString("alarm.permissionDesc"))
                                .nurFont(13)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.65))
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Button(action: {
                                HapticManager.shared.light()
                                Task { await vm.requestPermission() }
                            }) {
                                Text(localization.localizedString("alarm.allowNow"))
                                    .nurFont(14, weight: .bold)
                                    .foregroundColor(Color(hex: "1A1A2E"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 46)
                                    .background(Color.nurGold)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(BouncyButtonStyle())
                        }
                        .padding(18)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.02), radius: 8, y: 2)
                    }
                    
                    // BAŞLIK
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localization.localizedString("alarm.vakitReminder"))
                                .nurFont(26, weight: .bold)
                                .foregroundColor(Color(hex: "1A1A2E"))
                        }
                        Spacer()
                    }
                    .padding(.top, 6)
                    
                    // ALARMLAR LİSTESİ (Inset Grouped)
                    VStack(spacing: 14) {
                        ForEach(vm.alarms) { alarm in
                            AlarmCard(alarm: alarm, vm: vm, language: localization.currentLanguage)
                        }
                    }
                    
                    // ALT BİLGİ
                    Text(localization.localizedString("alarm.footerNote"))
                        .nurFont(11)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
                .padding(20)
            }
        }
        .onAppear { Task { await vm.onAppear() } }
    }
}

struct AlarmCard: View {
    let alarm: AlarmModel
    @ObservedObject var vm: AlarmViewModel
    let language: LanguageCode
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                // İkon ve İsim
                ZStack {
                    Circle()
                        .fill(alarm.prayerName.startColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: alarm.prayerName.symbol)
                        .foregroundColor(.nurGold)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(alarm.prayerName.localizedName(for: language))
                        .nurFont(16, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E"))
                    
                    if alarm.isActive {
                        Text(alarm.minutesBefore == 0 
                             ? LocalizationManager.shared.localizedString("alarm.onTime") 
                             : "\(alarm.minutesBefore) \(LocalizationManager.shared.localizedString("general.minutesShort")) \(LocalizationManager.shared.localizedString("alarm.before"))")
                            .nurFont(12)
                            .foregroundColor(.nurGold)
                    } else {
                        Text(LocalizationManager.shared.localizedString("alarm.closed"))
                            .nurFont(12)
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.4))
                    }
                }
                
                Spacer()
                
                // Toggle
                Toggle("", isOn: Binding(
                    get: { alarm.isActive },
                    set: { _ in
                        HapticManager.shared.selectionChanged()
                        Task { await vm.toggleAlarm(alarm) }
                    }
                ))
                .labelsHidden()
                .tint(.nurGold)
            }
            
            // Ayarlar Genişletme Butonu
            if alarm.isActive {
                Divider().opacity(0.06)
                
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 12))
                            Text(LocalizationManager.shared.localizedString("alarm.settings"))
                                .nurFont(12, weight: .semibold)
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Ses Tipi Seçimi
                    Text(alarm.soundType.localizedName(for: language))
                        .nurFont(11, weight: .bold)
                        .foregroundColor(.nurGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.nurGold.opacity(0.12))
                        .cornerRadius(8)
                }
                
                if isExpanded {
                    VStack(spacing: 12) {
                        // Dakika Seçimi (Vakit Öncesi)
                        Picker("", selection: Binding(
                            get: { alarm.minutesBefore },
                            set: { val in
                                vm.updateMinutesBefore(val, for: alarm.id)
                            }
                        )) {
                            Text("Tam Vaktinde").tag(0)
                            Text("15 dk önce").tag(15)
                            Text("30 dk önce").tag(30)
                            Text("45 dk önce").tag(45)
                        }
                        .pickerStyle(.segmented)
                        
                        // Ses Tipi Picker
                        Picker("", selection: Binding(
                            get: { alarm.soundType },
                            set: { val in
                                vm.updateSound(val, for: alarm.id)
                            }
                        )) {
                            ForEach(AlarmSound.allCases, id: \.self) { sound in
                                Text(sound.localizedName(for: language)).tag(sound)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
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
        .shadow(color: Color.black.opacity(0.025), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    AlarmView(vm: AlarmViewModel())
        .environmentObject(LocalizationManager.shared)
}
