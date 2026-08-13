import SwiftUI

struct ProfileView: View {
    @StateObject var vm: ProfileViewModel
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        ZStack {
            Color.nurDarkBlue.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    
                    statsSection
                    
                    actionsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.nurGold.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.nurGold)
            }
            .overlay(
                Circle()
                    .stroke(Color.nurGold.opacity(0.3), lineWidth: 2)
            )
            
            VStack(spacing: 4) {
                Text(vm.userSession.userName ?? "Misafir")
                    .nurFont(24, weight: .bold)
                    .foregroundColor(Color(hex: "1A1A2E"))
                
                Text(vm.userSession.userEmail ?? "nurvakti@example.com")
                    .nurFont(14, weight: .medium)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
            }
        }
        .padding(.vertical, 20)
    }
    
    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(title: "Zikir", value: "1.2k", icon: "suit.heart.fill")
            StatCard(title: "Hatim", value: "3", icon: "book.fill")
            StatCard(title: "Gün", value: "45", icon: "calendar")
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            ProfileActionButton(title: "Profili Düzenle", icon: "pencil") {}
            ProfileActionButton(title: "Bildirim Ayarları", icon: "bell") {}
            ProfileActionButton(title: "Hesabı Sil", icon: "trash", color: .red) {}
            
            Button(action: {
                HapticManager.shared.warning()
                vm.logout()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Oturumu Kapat")
                }
                .nurFont(16, weight: .bold)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.red.opacity(0.1))
                .cornerRadius(16)
            }
            .padding(.top, 20)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.nurGold)
                .font(.system(size: 14))
            
            Text(value)
                .nurFont(18, weight: .bold)
                .foregroundColor(Color(hex: "1A1A2E"))
            
            Text(title)
                .nurFont(10, weight: .medium)
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(ColorColor(hex: "1A1A2E").opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ColorColor(hex: "1A1A2E").opacity(0.1), lineWidth: 1)
        )
    }
}

struct ProfileActionButton: View {
    let title: String
    let icon: String
    var color: Color = .white
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.nurGold)
                    .frame(width: 24)
                
                Text(title)
                    .nurFont(14, weight: .medium)
                    .foregroundColor(color)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.3))
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(ColorColor(hex: "1A1A2E").opacity(0.05))
            .cornerRadius(12)
        }
    }
}

#Preview {
    ProfileView(vm: ProfileViewModel())
        .environmentObject(LocalizationManager.shared)
}
