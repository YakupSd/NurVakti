import SwiftUI
import UIKit

final class CustomHostingController<Content: View>: UIHostingController<Content> {
    private let navigationBarTitle: String
    private let navigationBarHidden: Bool
    private let rightImage: String?
    private let rightButtonAction: (() -> Void)?
    
    init(rootView: Content, 
         navigationBarTitle: String, 
         navigationBarHidden: Bool, 
         rightImage: String? = nil, 
         rightButtonAction: (() -> Void)? = nil) {
        self.navigationBarTitle = navigationBarTitle
        self.navigationBarHidden = navigationBarHidden
        self.rightImage = rightImage
        self.rightButtonAction = rightButtonAction
        super.init(rootView: rootView)
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(navigationBarHidden, animated: animated)
        navigationItem.title = navigationBarTitle
    }
    
    private func setupUI() {
        // Transparent Navigation Bar Style to match the premium dark theme
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 18, weight: .bold)]
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        
        // Back Button styling
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController?.navigationBar.tintColor = .nurGold
        
        if let rightImage = rightImage, !rightImage.isEmpty {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: rightImage),
                style: .plain,
                target: self,
                action: #selector(rightButtonActionTapped)
            )
        } else if rightButtonAction != nil {
            // Default icon if action is provided but no image
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "questionmark.circle"),
                style: .plain,
                target: self,
                action: #selector(rightButtonActionTapped)
            )
        }
    }
    
    @objc private func rightButtonActionTapped() {
        rightButtonAction?()
    }
}
