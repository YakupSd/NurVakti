//
//  DashboardViewModel.swift
//  NurVakti
//
//  Created by Yakup Suda on 13.04.2026.
//

import SwiftUI
import Combine
import OSLog

class DashboardViewModel: ObservableObject {
    @Published var router = MainViewsRouter.shared
    @Published var userSession = UserSession.shared
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ttb", category: "DashboardViewModel")
    
    func goToSettings() {
        let settingsVM = SettingsViewModel()
        let settingsView = SettingsView(vm: settingsVM)
        let vc = MainNavigationView.builder.makeView(settingsView, withNavigationTitle: "Ayarlar",navigationBarHidden: false)
        router.pushTo(view: vc)
    }
    
    func goToAccount() {
        if userSession.isLoggedIn {
            let profileVM = ProfileViewModel()
            let profileView = ProfileView(vm: profileVM)
            let vc = MainNavigationView.builder.makeView(profileView, withNavigationTitle: "Profil",navigationBarHidden: false)
            router.pushTo(view: vc)
        } else {
            let loginVM = LoginViewModel()
            let loginView = LoginView(vm: loginVM)
            let vc = MainNavigationView.builder.makeView(loginView, withNavigationTitle: "Giriş Yap",navigationBarHidden: false)
            router.pushTo(view: vc)
        }
    }
}
