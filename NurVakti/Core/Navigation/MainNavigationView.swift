import SwiftUI
import UIKit

// MARK: - NavigationViewBuilder Protocol
protocol NavigationViewBuilder {
    func makeView<T: View>(
        _ view: T,
        withNavigationTitle title: String,
        navigationBarHidden: Bool,
        isShowRightButton: Bool,
        rightImage: String,
        rightButtonAction: (() -> Void)?
    ) -> UIViewController
}

// MARK: - MainNavigationView Builder
final class MainNavigationView: NavigationViewBuilder {
    static let builder = MainNavigationView()
    private init() {}
    
    func makeView<T: View>(
        _ view: T,
        withNavigationTitle title: String,
        navigationBarHidden: Bool = false,
        isShowRightButton: Bool = false,
        rightImage: String = "",
        rightButtonAction: (() -> Void)? = nil
    ) -> UIViewController {
        CustomHostingController(
            rootView: view,
            navigationBarTitle: title,
            navigationBarHidden: navigationBarHidden,
            rightImage: isShowRightButton ? rightImage : nil,
            rightButtonAction: rightButtonAction
        )
    }
}
