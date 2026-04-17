import Foundation
import Combine

class UserSession: ObservableObject {
    static let shared = UserSession()
    
    @Published var isLoggedIn: Bool = false
    @Published var userName: String? = nil
    @Published var userEmail: String? = nil
    
    private init() {}
    
    func logout() {
        self.isLoggedIn = false
        self.userName = nil
        self.userEmail = nil
    }
    
    func login(name: String, email: String) {
        self.isLoggedIn = true
        self.userName = name
        self.userEmail = email
    }
}
