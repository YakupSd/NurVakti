import SwiftUI
import UIKit

// MARK: - Mushaf Page Controller (Interactive 604-Page Controller with Fluid Page Curl)
struct MushafPageController: UIViewControllerRepresentable {
    @Binding var currentPage: Int
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pvc = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: [UIPageViewController.OptionsKey.spineLocation: UIPageViewController.SpineLocation.min.rawValue]
        )
        
        pvc.dataSource = context.coordinator
        pvc.delegate = context.coordinator
        
        // Initial page (1...604)
        if let initialVC = context.coordinator.viewController(for: currentPage) {
            pvc.setViewControllers([initialVC], direction: .forward, animated: false)
        }
        
        return pvc
    }
    
    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        context.coordinator.parent = self
        
        guard let currentVC = uiViewController.viewControllers?.first as? MushafHostingController else { return }
        let currentShowingPage = currentVC.pageNumber
        
        if currentShowingPage != currentPage {
            if let targetVC = context.coordinator.viewController(for: currentPage) {
                // In Arabic Mushaf (RTL): Moving to higher page number (e.g. 1 -> 2) is forward
                let direction: UIPageViewController.NavigationDirection = currentPage > currentShowingPage ? .forward : .reverse
                uiViewController.setViewControllers([targetVC], direction: direction, animated: true)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: MushafPageController
        
        init(_ parent: MushafPageController) {
            self.parent = parent
        }
        
        func viewController(for page: Int) -> UIViewController? {
            guard page >= 1 && page <= 604 else { return nil }
            let view = MushafPageView(pageNumber: page)
            return MushafHostingController(rootView: AnyView(view), pageNumber: page)
        }
        
        // MARK: - Data Source (RTL Page Curl for Quran)
        // In Arabic reading: Next page is to the left, previous page is to the right
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let vc = viewController as? MushafHostingController else { return nil }
            let page = vc.pageNumber
            // Swiping Left to Right -> Previous page (e.g. 5 -> 4)
            return self.viewController(for: page - 1)
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let vc = viewController as? MushafHostingController else { return nil }
            let page = vc.pageNumber
            // Swiping Right to Left -> Next page (e.g. 5 -> 6)
            return self.viewController(for: page + 1)
        }
        
        // MARK: - Delegate
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed, let currentVC = pageViewController.viewControllers?.first as? MushafHostingController {
                let newPage = currentVC.pageNumber
                DispatchQueue.main.async {
                    self.parent.currentPage = newPage
                }
            }
        }
    }
}

// Custom UIHostingController to track pageNumber
final class MushafHostingController: UIHostingController<AnyView> {
    let pageNumber: Int
    
    init(rootView: AnyView, pageNumber: Int) {
        self.pageNumber = pageNumber
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
