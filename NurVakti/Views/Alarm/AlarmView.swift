import SwiftUI

struct AlarmView: View {
    @StateObject var vm: AlarmViewModel
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        ZStack {
            // Arka plan
            LinearGradient(colors: [Color(hex: "0D1B2A"), Color(hex: "000000")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            StarFieldView(opacity: 0.2)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // İZİN BANNER
                    if vm.permissionStatus != .authorized {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "bell.badge.fill")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                                Text(localization.localizedString("alarm.permissionRequired"))
                                    .nurFont(18, weight: .bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            Text(localization.localizedString("alarm.permissionDesc"))
                                .nurFont(14)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Button(action: {
                                HapticManager.shared.light()
                                Task { await vm.requestPermission() }
                            }) {
                                Text(localization.localizedString("alarm.allowNow"))
                                    .nurFont(14, weight: .bold)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.nurGold)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                    
                    // BAŞLIK
                    HStack {
                        Text(localization.localizedString("alarm.vakitReminder"))
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    // ALARMLAR LİSTESİ
                    VStack(spacing: 18) {
                        ForEach(vm.alarms) { alarm in
                            AlarmCard(alarm: alarm, vm: vm, language: localization.currentLanguage)
                        }
                    }
                    
                    // ALT BİLGİ
                    Text(localization.localizedString("alarm.footerNote"))
                        .nurFont(11)
                        .foregroundColor(.white.opacity(0.3))
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                }
                .padding()
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
        NurCard {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    // İkon ve İsim
                    ZStack {
                        Circle()
                            .fill(alarm.prayerName.startColor.opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: alarm.prayerName.symbol)
                            .foregroundColor(alarm.prayerName.startColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(alarm.prayerName.localizedName(for: language))
                            .nurFont(18, weight: .bold)
                            .foregroundColor(.white)
                        Text(LocalizationManager.shared.localizedString("alarm.vakitBased"))
                            .nurFont(12)
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { alarm.isActive },
                        set: { _ in 
                            HapticManager.shared.light()
                            Task { await vm.toggleAlarm(alarm) } 
                        }
                    ))
                    .tint(.nurGold)
                    .labelsHidden()
                }
                
                if alarm.isActive {
                    Divider().background(Color.white.opacity(0.08))
                    
                    DisclosureGroup(isExpanded: $isExpanded) {
                        VStack(spacing: 24) {
                            // Dakika Seçimi
                            HStack {
                                Text(LocalizationManager.shared.localizedString("alarm.minutesBeforeLabel"))
                                    .nurFont(14)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Stepper(value: Binding(
                                    get: { alarm.minutesBefore },
                                    set: { 
                                        HapticManager.shared.light()
                                        vm.updateMinutesBefore($0, for: alarm.id) 
                                    }
                                ), in: 0...60, step: 5) {
                                    Text("\(alarm.minutesBefore) \(LocalizationManager.shared.localizedString("general.minutesShort"))")
                                        .nurFont(14, weight: .bold)
                                        .foregroundColor(.nurGold)
                                }
                            }
                            
                            // Ses Seçimi
                            HStack {
                                Text(LocalizationManager.shared.localizedString("alarm.soundLabel"))
                                    .nurFont(14)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Menu {
                                    ForEach(AlarmSound.allCases, id: \.self) { sound in
                                        Button(sound.localizedName(for: language)) {
                                            HapticManager.shared.light()
                                            vm.updateSound(sound, for: alarm.id)
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(alarm.soundType.localizedName(for: language))
                                            .nurFont(14, weight: .bold)
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 10))
                                    }
                                    .foregroundColor(.nurGold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.nurGold.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // Günler (Basitleştirilmiş)
                            HStack(spacing: 8) {
                                ForEach(Weekday.allCases, id: \.self) { day in
                                    Text(day.shortName(for: language))
                                        .nurFont(10, weight: .bold)
                                        .frame(width: 32, height: 32)
                                        .background(day.isFriday ? Color.nurGold.opacity(0.2) : Color.white.opacity(0.05))
                                        .foregroundColor(day.isFriday ? .nurGold : .white.opacity(0.6))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(day.isFriday ? Color.nurGold.opacity(0.5) : Color.clear, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 12)
                    } label: {
                        HStack {
                            Text(LocalizationManager.shared.localizedString("alarm.editSettings"))
                                .nurFont(12, weight: .medium)
                                .foregroundColor(.nurGold.opacity(0.8))
                            Spacer()
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(.nurGold.opacity(0.5))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AlarmView(vm: AlarmViewModel())
        .environmentObject(LocalizationManager.shared)
}
