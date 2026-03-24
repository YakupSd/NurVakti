import SwiftUI
import UIKit

struct RootNavigationController<RootView: View>: UIViewControllerRepresentable {
    let nav: UINavigationController
    let rootView: RootView
    let navigationBarTitle: String
    let navigationBarHidden: Bool
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = CustomHostingController(rootView: rootView, 
                                        navigationBarTitle: navigationBarTitle, 
                                        navigationBarHidden: navigationBarHidden)
        nav.viewControllers = [vc]
        return nav
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Update logic if needed
    }
}
