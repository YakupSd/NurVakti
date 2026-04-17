import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var router = MainViewsRouter.shared
    @Published var userSession = UserSession.shared
    
    func logout() {
        userSession.logout()
    }
}
