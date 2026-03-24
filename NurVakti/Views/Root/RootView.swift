import SwiftUI

struct RootView: View {
    @StateObject private var router = AppRouter.shared
    private let navigationController = UINavigationController()
    
    var body: some View {
        RootNavigationController(
            nav: navigationController,
            rootView: ContentView(),
            navigationBarTitle: "",
            navigationBarHidden: true
        )
        .onAppear {
            router.nav = navigationController
            setupAppearance()
        }
        .environmentObject(router)
        .ignoresSafeArea()
    }
    
    private func setupAppearance() {
        // Global Navigation Bar Appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .nurGold
    }
}
