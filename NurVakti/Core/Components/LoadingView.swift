import UIKit

// MARK: - Overlay View

public class LoadingView: UIView {

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        addSubview(activityIndicator)
        activityIndicator.startAnimating()

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    /// Overlay'i ekrandan kaldırır
    public func dismiss() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.removeFromSuperview()
        }
    }
    
    /// En üstteki ViewController’ın view’ine overlay olarak eklenir
    public func dashboardLoadingTopMostView() {
        guard let topVC = UIApplication.topMostViewController() else {
            return
        }
        let className = NSStringFromClass((topVC.classForCoder))
        print(className)
        if className.contains("ServerErrorPopup") || className.contains("PresentationHostingController") {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        topVC.view.addSubview(self)
        
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: topVC.view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: topVC.view.trailingAnchor),
            self.topAnchor.constraint(equalTo: topVC.view.topAnchor),
            self.bottomAnchor.constraint(equalTo: topVC.view.bottomAnchor)
        ])
        
    }

    /// En üstteki ViewController’ın view’ine overlay olarak eklenir
    public static func showOverTopMostView() -> LoadingView? {
        guard let topVC = UIApplication.topMostViewController() else {
            return nil
        }
        
        if let subView = topVC.view.subviews.first(where: { $0 is LoadingView }) as? LoadingView {
            return subView
        } else {
            let className = NSStringFromClass((topVC.classForCoder))
            print(className)
            if className.contains("ServerErrorPopup") || className.contains("PresentationHostingController") {
                return nil
            }
            let sdkView = LoadingView(frame: topVC.view.bounds)
            DispatchQueue.main.async {
                sdkView.translatesAutoresizingMaskIntoConstraints = false
                topVC.view.addSubview(sdkView)
                
                NSLayoutConstraint.activate([
                    sdkView.leadingAnchor.constraint(equalTo: topVC.view.leadingAnchor),
                    sdkView.trailingAnchor.constraint(equalTo: topVC.view.trailingAnchor),
                    sdkView.topAnchor.constraint(equalTo: topVC.view.topAnchor),
                    sdkView.bottomAnchor.constraint(equalTo: topVC.view.bottomAnchor)
                ])
            }
            return sdkView
        }
    }
    
    /// Window'a direkt ekler (SwiftUI HostingController için)
    public static func showOverWindow() -> LoadingView? {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) ?? (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else { return nil }
        if let existing = window.subviews.first(where: { $0 is LoadingView }) as? LoadingView { return existing }
        let view = LoadingView(frame: window.bounds)
        DispatchQueue.main.async {
            view.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(view)
            NSLayoutConstraint.activate([view.leadingAnchor.constraint(equalTo: window.leadingAnchor), view.trailingAnchor.constraint(equalTo: window.trailingAnchor), view.topAnchor.constraint(equalTo: window.topAnchor), view.bottomAnchor.constraint(equalTo: window.bottomAnchor)])
        }
        return view
    }
}

// MARK: - En Üst ViewController Yakalama

public extension UIApplication {
    static func topMostViewController(
        base: UIViewController? = {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
            return scene.windows.first(where: { $0.isKeyWindow })?.rootViewController ?? scene.windows.first?.rootViewController
        }()
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topMostViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}
