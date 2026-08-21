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
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ttb", category: "DashboardViewModel")
    
    func goToSettings() {
        let settingsVM = SettingsViewModel()
        let settingsView = SettingsView(vm: settingsVM)
        let vc = MainNavigationView.builder.makeView(settingsView, withNavigationTitle: "Ayarlar",navigationBarHidden: false)
        router.pushTo(view: vc)
    }
}
