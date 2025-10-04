import UIKit

private enum UIConstants {
    static let loginButtonFont = UIFont.systemFont(ofSize: 17, weight: .bold)
    static let loginButtonCornerRadius: CGFloat = 16
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    
    private var logoImage = UIImage()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .authIclon))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = UIConstants.loginButtonFont
        button.setTitleColor(UIColor(resource: .ypBlackIOS), for: .normal)
        button.backgroundColor = UIColor(resource: .ypWhiteIOS)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = UIConstants.loginButtonCornerRadius
        button.contentMode = .scaleToFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return button
    }()
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    private var isFetchingToken = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUIObjects()
        setupConstraints()
        configureBackButton()
    }
    
    private func setupView() {
        view.contentMode = .scaleToFill
        view.backgroundColor = UIColor(resource: .ypBlackIOS)
    }
    
    // SETUP UI OBJECTS:
    private func setupUIObjects(){
        view.addSubview(imageView)
        view.addSubview(loginButton)
    }
    
    // SETUP CONTRAINTS:
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlackIOS
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showWebViewSegueIdentifier,
              let webViewViewController = segue.destination as? WebViewViewController
        else {
            return super.prepare(for: segue, sender: sender)
        }
        webViewViewController.delegate = self
    }
    
    @objc private func didTapLoginButton() {
        guard !isFetchingToken else { return }
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: webViewViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            
            UIBlockingProgressHUD.show()
            isFetchingToken = true
            
            fetchOAuthToken(code: code){ [weak self] result in
                guard let self else { return }
                
                UIBlockingProgressHUD.dismiss()
                isFetchingToken = false
                
                switch result {
                case .success(let code):
                    delegate?.authViewController(self, didAuthenticateWithCode: code)
                case .failure(let error):
                    print("❌ [fetchOAuthToken]: Unable to get token: \(error)")
                    let alert = UIAlertController(
                        title: "Что-то пошло не так(",
                        message: "Не удалось войти в систему",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            }
            
        }
    }
        
    private func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self else { return }
                self.isFetchingToken = false
                switch result {
                case .success(let code):
                    completion(.success(code))
                case .failure(let error):
                    completion(.failure(error))
                    print("❌ [fetchOAuthToken]: Authorization error: \(error)")
                }
            }
        }
    }
}
