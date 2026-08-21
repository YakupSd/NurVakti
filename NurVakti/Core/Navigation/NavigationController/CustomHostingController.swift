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
            .foregroundColor: UIColor(red: 26/255, green: 26/255, blue: 46/255, alpha: 1.0),
            .font: UIFont.setCustomUIFont(name: .InterBold, size: 18)
        ]
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        
        // Custom Back Button - Ensure it replaces and doesn't supplement
        navigationItem.hidesBackButton = true
        navigationItem.leftItemsSupplementBackButton = false
        
        let backButton = createBackButton()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    private func createBackButton() -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(red: 26/255, green: 26/255, blue: 46/255, alpha: 0.85)
        
        button.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 19
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(red: 26/255, green: 26/255, blue: 46/255, alpha: 0.08).cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.04
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Sayfadan çıkıldığında (pop) ses çalmayı durdur.
        // isMovingFromParent → bu VC navigation stack'ten kaldırılıyor demek.
        // isBeingDismissed → modal olarak dismiss ediliyor.
        if isMovingFromParent || isBeingDismissed {
            AudioManager.shared.stop()
        }
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
