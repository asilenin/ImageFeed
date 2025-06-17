import UIKit

final class ProfileViewController: UIViewController {
    
    private var avatarImage = UIImage()
    private var avatarImageView = UIImageView()
    private var logoutButton = UIButton()
    private var nameLabel = UILabel()
    private var loginNameLabel = UILabel()
    private var descriptionLabel = UILabel()
    
    private let mockName = "Екатерина Новикова"
    private let mockLoginName = "@ekaterina_novikova"
    private let mockDescriptionLabel = "Hello, world!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUIObjects()
        setupConstraints()
    }
    
    private func setupView() {
        view.contentMode = .scaleToFill
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
    }
    
    // SETUP UI OBJECTS:
    private func setupUIObjects() {
        setupAvatarImageView()
        setupLogoutButton()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
    }
    
    private func setupAvatarImageView() {
        avatarImage = UIImage(named: "Userpic") ?? UIImage(systemName: "person.crop.circle.fill")!
        avatarImageView = UIImageView(image: avatarImage)
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
    }
    
    private func setupLogoutButton() {
        let image = UIImage(named: "logout")?.withRenderingMode(.alwaysOriginal) ??
                    UIImage(systemName: "arrow.backward")!
        
        logoutButton = UIButton(type: .custom)
        logoutButton.setImage(image, for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        
        logoutButton.contentMode = .scaleToFill
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
    }
    
    private func setupNameLabel() {
        nameLabel.text = mockName
        nameLabel.textColor = UIColor(named: "YP White (iOS)")
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.contentMode = .left
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
    }
    
    private func setupLoginNameLabel() {
        loginNameLabel.text = mockLoginName
        loginNameLabel.textColor = UIColor(named: "YP Gray (iOS)")
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.contentMode = .left
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.text = mockDescriptionLabel
        descriptionLabel.textColor = UIColor(named: "YP White (iOS)")
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.contentMode = .left
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
    }
    
    
    
    // SETUP CONTRAINTS:
    private func setupConstraints(){
        setupConstraintsAvatarImage()
        setupConstraintsLogoutButton()
        setupConstraintsNameLabel()
        setupConstraintsLoginNameLabel()
        setupConstraintsDescriptionLabel()
        
    }
    
    private func setupConstraintsAvatarImage() {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
        ])
    }
    
    private func setupConstraintsLogoutButton() {
        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupConstraintsNameLabel() {
        NSLayoutConstraint.activate([
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
        ])
    }
    
    private func setupConstraintsLoginNameLabel() {
        NSLayoutConstraint.activate([
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
        ])
    }
    
    private func setupConstraintsDescriptionLabel() {
        NSLayoutConstraint.activate([
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
        ])
    }
    
    // TODO:
    @objc
    private func didTapLogoutButton(){}
}
