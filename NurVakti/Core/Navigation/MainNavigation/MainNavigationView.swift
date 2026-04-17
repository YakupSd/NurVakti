//
//  MainNavigationView.swift
//  SmartCampusApp
//
//  Created by Yakup Suda on 17.04.2024.
//
import UIKit
import SwiftUI
import Combine

final class MainNavigationView: CustomViewBuilder {
    
    static let builder = MainNavigationView()
    
    private init() {}
    
    func makeView<T: View>(
        _ view: T,
        withNavigationTitle title: String,
        navigationBarHidden: Bool = false,
        autoPopPrevious: Bool = false,
        isNavBarAlphaAnimationActive: Bool = false,
        backgroundImage: String = "",
        isShowRightButton: Bool = false,
        rightImage: String = "",
        rightImageSize: CGSize = CGSize(width: 24, height: 24),
        isBackAnimationActive: Bool = false,
        rightButtonAction: @escaping () -> Void = {}
    ) -> UIViewController {
        let injectedView = view
            .environmentObject(LocalizationManager.shared)
            .environmentObject(LocationService.shared)
            .environmentObject(PrayerTimeService.shared)
            .environmentObject(NotificationService.shared)
            .environmentObject(PersistenceService.shared)
            .environmentObject(BackgroundGradientService.shared)
            .environmentObject(MonthlyDuaService.shared)
            .environmentObject(DuaLibraryService.shared)
            .environmentObject(AudioManager.shared)
            .environmentObject(AppRouter.shared)
            
        return CustomHostingController(
            rootView: injectedView,
            navigationBarTitle: title,
            navigationBarHidden: navigationBarHidden,
            backgroundImage: backgroundImage,
            isShowRightButton: isShowRightButton,
            rightImage: rightImage,
            rightButtonAction: rightButtonAction
        )
    }
}

final class MainViewsRouter: Router {
    static let shared = MainViewsRouter()
    var nav: UINavigationController?

    func pushTo(view: UIViewController) {
        // Standard UIKit push animation guarantees the navigation bar state syncs correctly.
        // Bypassing it with CATransition causes the bar to randomly disappear.
        nav?.pushViewController(view, animated: true)
    }
}

