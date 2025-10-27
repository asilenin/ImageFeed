import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared    
    private var imageView = UIImageView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        print("[oauth2TokenStorage.token]: \(oauth2TokenStorage.token ?? "nil")")
        if oauth2TokenStorage.token != nil {
            fetchProfile()
        } else {
            presentAuthViewController()
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("❌ [SplashViewController][switchToTabBarController]: Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    // MARK: - Configuration
    private func setupImageView() {
        let image = UIImage(named: "LaunchLogo")
        imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(
            withIdentifier: "AuthViewController"
        ) as? AuthViewController else {
            assertionFailure("❌ [SplashViewController][presentAuthViewController]: unable find AuthViewController")
            return
        }

        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    // MARK: - Public Methods
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        oauth2TokenStorage.token = code
        switchToTabBarController()
        dismiss(animated: true)
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            self?.fetchProfile()
        }
    }
    
    // MARK: - Private Methods
    private func fetchProfile() {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile() { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else { return }

            switch result {
            case .success(let profile):
                print("✅ [SplashViewController][fetchProfile]: Profile loaded: \(profile.name)")
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()

            case .failure(let error):
                print("❌ [SplashViewController][fetchProfile]: profile load failure: \(error.localizedDescription)")
                break
            }
        }
    }
}

