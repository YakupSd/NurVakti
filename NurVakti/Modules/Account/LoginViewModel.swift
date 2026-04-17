import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    
    @Published var router = MainViewsRouter.shared
    
    func login() {
        isLoading = true
        // Simulate login
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            UserSession.shared.login(name: "Yakup Suda", email: self.email.isEmpty ? "yakup@nurvakti.app" : self.email)
            self.isLoading = false
        }
    }
    
    func loginWithGoogle() {
        // Placeholder
    }
    
    func loginWithApple() {
        // Placeholder
    }
    
    func goToRegister() {
        // Placeholder
    }
}
