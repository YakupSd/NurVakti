import SwiftUI

struct LoginView: View {
    @StateObject var vm: LoginViewModel
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        ZStack {
            // Background
            Color.nurDarkBlue.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Decorative icon (smaller and refined)
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.nurGold.opacity(0.1))
                    
                    headerSection
                    
                    formSection
                    
                    socialSection
                    
                    footerSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text(localization.localizedString("account.welcome"))
                .nurFont(28, weight: .bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            
            Text("NurVakti müridleri arasına katılın.")
                .nurFont(14, weight: .medium)
                .foregroundColor(.white.opacity(0.5))
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 20) {
            // Email
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .nurFont(12, weight: .bold)
                    .foregroundColor(.nurGold)
                
                TextField("email@example.com", text: $vm.email)
                    .textFieldStyle(NurTextFieldStyle())
            }
            
            // Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Şifre")
                    .nurFont(12, weight: .bold)
                    .foregroundColor(.nurGold)
                
                SecureField("••••••••", text: $vm.password)
                    .textFieldStyle(NurTextFieldStyle())
            }
            
            // Login Button
            Button(action: {
                HapticManager.shared.success()
                vm.login()
            }) {
                ZStack {
                    if vm.isLoading {
                        ProgressView().tint(.black)
                    } else {
                        Text(localization.localizedString("general.login"))
                            .nurFont(16, weight: .bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.nurGold)
                .foregroundColor(.black)
                .cornerRadius(16)
                .shadow(color: .nurGold.opacity(0.3), radius: 10, y: 5)
            }
            .disabled(vm.isLoading)
        }
    }
    
    private var socialSection: some View {
        VStack(spacing: 16) {
            HStack {
                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                Text("veya").nurFont(12).foregroundColor(.white.opacity(0.3))
                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
            }
            
            HStack(spacing: 16) {
                SocialLoginButton(icon: "apple.logo", title: "Apple", action: vm.loginWithApple)
                SocialLoginButton(icon: "google.logo", title: "Google", action: vm.loginWithGoogle)
            }
        }
    }
    
    private var footerSection: some View {
        Button(action: vm.goToRegister) {
            HStack {
                Text("Hesabınız yok mu?")
                    .foregroundColor(.white.opacity(0.5))
                Text("Kayıt Ol")
                    .foregroundColor(.nurGold)
                    .bold()
            }
            .nurFont(14)
        }
        .padding(.top, 20)
    }
}

// MARK: - Helper Components
struct NurTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .foregroundColor(.white)
            .accentColor(.nurGold)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

struct SocialLoginButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .nurFont(14, weight: .bold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white.opacity(0.05))
            .foregroundColor(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    LoginView(vm: LoginViewModel())
        .environmentObject(LocalizationManager.shared)
}
