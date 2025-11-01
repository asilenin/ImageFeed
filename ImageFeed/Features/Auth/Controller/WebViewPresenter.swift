import UIKit
import WebKit

public protocol WebViewPresenterProtocol {
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
    var viewController: WebViewViewControllerProtocol? { get set }
}

final class WebViewPresenter: WebViewPresenterProtocol {
    // MARK: - Public Properties
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    weak var viewController: WebViewViewControllerProtocol?
    
    // MARK: - Private Properties

    
    // MARK: - Public Methods
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        viewController?.load(request: request)
        didUpdateProgressValue(0)
    }
}

extension WebViewPresenter{
    
    // MARK: - Public Methods
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        viewController?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        viewController?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }    
}
