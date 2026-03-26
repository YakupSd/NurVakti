import SwiftUI
import UIKit

// MARK: - Mushaf Page Controller (UIKit Bridge for Curl Animation)
struct MushafPageController: UIViewControllerRepresentable {
    @Binding var currentPageIndex: Int
    let pages: [MushafPageModel]
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pvc = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        pvc.dataSource = context.coordinator
        pvc.delegate = context.coordinator
        
        // Initial Page
        if let firstVC = context.coordinator.viewController(at: currentPageIndex) {
            // Arabic is RTL, so we might need to reverse initial direction if needed
            pvc.setViewControllers([firstVC], direction: .forward, animated: false)
        }
        
        return pvc
    }
    
    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        // Dışarıdan (butonlarla) gelen sayfa değişimlerini UIKit tarafına yansıt
        guard let currentVC = uiViewController.viewControllers?.first else { return }
        let currentIndex = currentVC.view.tag
        
        if currentIndex != currentPageIndex {
            if let targetVC = context.coordinator.viewController(at: currentPageIndex) {
                // Arapça RTL olduğu için yönlendirme mantığına dikkat (RTL'de index artışı .reverse olabilir)
                let direction: UIPageViewController.NavigationDirection = currentPageIndex > currentIndex ? .reverse : .forward
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
        
        // MARK: - Data Source
        func viewController(at index: Int) -> UIViewController? {
            guard index >= 0 && index < parent.pages.count else { return nil }
            
            let page = parent.pages[index]
            let mushafView = MushafPageView(page: page)
            let vc = UIHostingController(rootView: mushafView)
            vc.view.tag = index
            return vc
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            let index = viewController.view.tag
            // RTL: Swiping LEFT-TO-RIGHT (Before) should show the PREVIOUS page (index - 1)
            return self.viewController(at: index - 1)
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            let index = viewController.view.tag
            // RTL: Swiping RIGHT-TO-LEFT (After) should show the NEXT page (index + 1)
            return self.viewController(at: index + 1)
        }
        
        // MARK: - Delegate
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed, let currentVC = pageViewController.viewControllers?.first {
                parent.currentPageIndex = currentVC.view.tag
            }
        }
    }
}
