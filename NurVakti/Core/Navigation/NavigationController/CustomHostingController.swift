//
//  CustomHostingController.swift
//  SmartCampusApp
//
//  Created by Yakup Suda on 17.04.2024.
//
import SwiftUI


class CustomHostingController<Content>: UIHostingController<AnyView> where Content: View {
    
    var isNavBarHidden: Bool = false
    var isShowRightButton: Bool = false
    var backgroundImage = ""
    var rightImage = ""
    var rightButtonAction: (() -> Void)?
    
    @ObservedObject var router = MainViewsRouter.shared
    
    public init(
        rootView: Content,
        navigationBarTitle: String,
        navigationBarHidden: Bool,
        backgroundImage: String,
        isShowRightButton: Bool,
        rightImage: String,
        rightButtonAction: @escaping () -> Void = {}
    ) {
        // Pass the actual hidden state and title to SwiftUI so UIHostingController natively syncs them to UIKit
        let wrappedView = rootView
            .navigationBarHidden(navigationBarHidden)
            .navigationTitle(Text(navigationBarTitle))
            .navigationBarBackButtonHidden(true)
        
        super.init(rootView: AnyView(wrappedView))
        self.title = navigationBarTitle
        self.isNavBarHidden = navigationBarHidden
        self.backgroundImage = backgroundImage
        self.isShowRightButton = isShowRightButton
        self.rightImage = rightImage
        self.rightButtonAction = rightButtonAction
        
        // Hide standard back button so we can use our custom one
        self.navigationItem.hidesBackButton = true
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Force the navigation controller to respect our hidden state
        navigationController?.setNavigationBarHidden(isNavBarHidden, animated: animated)
        
        if !isNavBarHidden {
            setupAppearance()
            if isShowRightButton {
                let rightButton = UIBarButtonItem(customView: createRightButton(image: self.rightImage))
                navigationItem.rightBarButtonItem = rightButton
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isNavBarHidden && !backgroundImage.isEmpty {
            setImage()
        }
    }
    
    private func setupAppearance() {
        // Navigation Title Font & Color
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.setCustomUIFont(name: .InterBold, size: 18)
        ]
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        // Custom Back Button - Ensure it replaces and doesn't supplement
        navigationItem.hidesBackButton = true
        navigationItem.leftItemsSupplementBackButton = false
        
        let backButtonImage = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .white
        
        // Set it as the ONLY left item
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    func setImage() {
        let backgroundImage = UIImage(named: self.backgroundImage)
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleToFill
        
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor), // Yukarı kenara bağlanır
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor) // Alt kenara bağlanır
        ])

    }

    func createRightButton(image: String) -> UIButton {
        let button = UIButton(type: .custom)
        let buttonImage = UIImage(named: image)
        
        let imageSize = CGSize(width: 22, height: 18) // İstediğiniz boyutu burada belirleyin
        
        button.setImage(buttonImage?.resize(targetSize: imageSize), for: .normal) // Resmi yeniden boyutlandırıp kullanın
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        
        button.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        
        return button
    }
    
    
    @objc func rightButtonTapped() {
        if let action = rightButtonAction {
            action()
        } else {
            switch rightImage {
            case "house.fill":
                break
            case "houseHomeView":
                break
            case "gear":
                print("ayarlara tıklandı")
            default:
                ()
            }
        }
    }
}

extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
