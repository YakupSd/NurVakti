//
//  RootNavigationController.swift
//  SmartCampusApp
//
//  Created by Yakup Suda on 17.04.2024.
//

import SwiftUI

// Reusable Navigation Controller to be used as the root controller
struct RootNavigationController<RootView: View>: UIViewControllerRepresentable {

    let nav: UINavigationController
    let rootView: RootView
    let navigationBarTitle: String
    let navigationBarHidden: Bool
    let backgroundImage: String
    let isShowRightButton: Bool
    var rightImage: String
    var rightButtonAction: () -> Void
    
    init(nav: UINavigationController, rootView: RootView, navigationBarTitle: String, navigationBarHidden: Bool = false, backgroundImage: String, isShowRightButton: Bool = false, rightImage: String, rightButtonAction: @escaping () -> Void = {}) {
        self.nav = nav
        self.rootView = rootView
        self.navigationBarTitle = navigationBarTitle
        self.navigationBarHidden = navigationBarHidden
        self.backgroundImage = backgroundImage
        self.isShowRightButton = isShowRightButton
        self.rightImage = rightImage
        self.rightButtonAction = rightButtonAction
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = CustomHostingController(
            rootView: rootView,
            navigationBarTitle: navigationBarTitle,
            navigationBarHidden: navigationBarHidden,
            backgroundImage: backgroundImage,
            isShowRightButton: isShowRightButton,
            rightImage: rightImage,
            rightButtonAction: rightButtonAction
        )
        nav.setViewControllers([vc], animated: false)
        vc.navigationController?.delegate = context.coordinator
        let warmBg = UIColor(red: 248/255, green: 246/255, blue: 240/255, alpha: 1.0)
        vc.view.backgroundColor = warmBg
        nav.view.backgroundColor = warmBg
        
        // Clean navigation bar appearance
        vc.navigationController?.navigationBar.layer.shadowOpacity = 0.0
        
        return nav
    }

    func updateUIViewController(_ pageViewController: UINavigationController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate {
        var parent: RootNavigationController
        
        init(_ parent: RootNavigationController) {
            self.parent = parent
        }
        func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
            navigationController.view.frame = UIScreen.main.bounds
            navigationController.navigationBar.isTranslucent = true
            navigationController.view.backgroundColor = UIColor(red: 248/255, green: 246/255, blue: 240/255, alpha: 1.0)
            UIApplication.shared.statusBarUIView?.backgroundColor = UIColor.clear
            navigationController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor(red: 26/255, green: 26/255, blue: 46/255, alpha: 1.0),
                NSAttributedString.Key.font: UIFont.setCustomUIFont(name: .InterBold, size: 18)
            ]
            navigationController.navigationBar.tintColor = UIColor(red: 26/255, green: 26/255, blue: 46/255, alpha: 0.85)
        }
    }
}
