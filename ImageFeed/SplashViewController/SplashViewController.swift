import UIKit

final class SplashViewController: UIViewController {
    //private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    //private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    //private let profileService = ProfileService()
    private let profileService = ProfileService.shared
    //private let storage = OAuth2TokenStorage()
    
    
    private var imageView: UIImageView!
    
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
            //performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
            presentAuthViewController()
        }
    }
    
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
            assertionFailure("❌ [presentAuthViewController]: unable find AuthViewController")
            return
        }

        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("❌ [switchToTabBarController]: Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
/*
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("❌ [SplashViewController] prepare: Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
 */

extension SplashViewController: AuthViewControllerDelegate {
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

    private func fetchProfile() {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile() { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success(let profile):
                print("✅ [fetchProfile]: Profile loaded: \(profile.name)")
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()

            case .failure(let error):
                print("❌ [fetchProfile]: profile load failure: \(error.localizedDescription)")
                break
            }
        }
    }
}

