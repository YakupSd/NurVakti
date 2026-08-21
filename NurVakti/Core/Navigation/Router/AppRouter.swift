import SwiftUI
import UIKit
import Combine

// MARK: - App Router
final class AppRouter: ObservableObject, Router {
    @Published var nav: UINavigationController?
    
    static let shared = AppRouter()
    init() {}
    
    func pushTo(view: UIViewController) {
        MainViewsRouter.shared.pushTo(view: view)
    }
    
    func pop() {
        MainViewsRouter.shared.nav?.popViewController(animated: true)
    }
    
    func popToRoot() {
        MainViewsRouter.shared.popToRoot()
    }
    
    func presentSheet<V: View>(view: V) {
        let vc = UIHostingController(rootView: view.environmentObject(self))
        vc.modalPresentationStyle = .pageSheet
        nav?.present(vc, animated: true)
    }
}
