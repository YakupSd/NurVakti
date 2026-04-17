import UIKit

class ServerErrorPopup: UIViewController {
    
    private let backgroundView = UIView()
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let okButton = UIButton(type: .system)
    
    private let message: String
    private let buttonText: String
    
    init(message: String, buttonText: String) {
        self.message = message
        self.buttonText = buttonText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // iconImageView.image = UIImage(named: "iconPopupError")
        iconImageView.tintColor = .systemRed
        iconImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconImageView)
        
        titleLabel.text = message
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = UIColor(red: 41.0/255.0, green: 36.0/255.0, blue: 36.0/255.0, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        okButton.setTitle(buttonText, for: .normal)
        okButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        okButton.backgroundColor = UIColor(red: 196/255, green: 4/255, blue: 24/255, alpha: 1.0)

        okButton.setTitleColor(.white, for: .normal)
        okButton.layer.cornerRadius = 5
        okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        okButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(okButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 64),
            iconImageView.heightAnchor.constraint(equalToConstant: 64),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            
            okButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            okButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            okButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            okButton.heightAnchor.constraint(equalToConstant: 45),
            okButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -32)
        ])
    }
    
    @objc private func okButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
