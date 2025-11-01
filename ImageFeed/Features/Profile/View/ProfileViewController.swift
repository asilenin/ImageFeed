import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(profile: Profile)
    func updateAvatar(url: URL?)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol{
    
    // MARK: - Properties
    var presenter: ProfilePresenterProtocol?
    
    // MARK: - Properties
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var avatarImage = UIImage()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.accessibilityIdentifier = "Logout"
        let image = UIImage(named: "logout")?.withRenderingMode(.alwaysOriginal)
            ?? UIImage(systemName: "arrow.backward")
            ?? UIImage()
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        button.contentMode = .scaleToFill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhiteIOS
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.contentMode = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGrayIOS
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.contentMode = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhiteIOS
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.contentMode = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        setupView()
        setupUIObjects()
        setupConstraints()
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                presenter?.updateAvatar()
            }
        presenter?.updateAvatar()
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Configuration
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter?.viewController = self
    }
    
    private func setupView() {
        view.contentMode = .scaleToFill
        view.backgroundColor = UIColor(resource: .ypBlackIOS)
    }
    
    // SETUP UI OBJECTS:
    private func setupUIObjects() {
        [avatarImageView, logoutButton, nameLabel, loginNameLabel, descriptionLabel].forEach {
            view.addSubview($0)
        }
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
    
    // MARK: - Public Methods
    func updateProfileDetails(profile: Profile) {
        DispatchQueue.main.async {
            self.nameLabel.text = profile.name
            self.loginNameLabel.text = profile.loginName
            self.descriptionLabel.text = profile.bio
        }
    }
    
    func updateAvatar(url: URL?) {
        DispatchQueue.main.async {
            guard let url else {
                self.avatarImageView.image = UIImage(named: "Userpic")
                return
            }
            let placeholder = UIImage(named: "Userpic")
            let processor = RoundCornerImageProcessor(cornerRadius: 35)
            
            self.avatarImageView.kf.indicatorType = .activity
            self.avatarImageView.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ]
            )
        }
    }
    
    // MARK: - Private Methods
    @objc private func didTapLogoutButton(){
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { _ in
            ProfileLogoutService.shared.logout()
        })
        present(alert, animated: true)}
}
