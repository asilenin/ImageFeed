import UIKit
import WebKit

public protocol WebViewPresenterProtocol {
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
    var view: WebViewViewControllerProtocol? { get set }
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
}

extension WebViewPresenter{
    
    // MARK: - Public Methods
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
    
    /*
     func code(from url: URL) -> String? {
     if let urlComponents = URLComponents(string: url.absoluteString),
     urlComponents.path == "/oauth/authorize/native",
     let items = urlComponents.queryItems,
     let codeItem = items.first(where: { $0.name == "code" })
     {
     return codeItem.value
     } else {
     return nil
     }
     }
     */
    
    /*
     
     private func code(from navigationAction: WKNavigationAction) -> String? {
     if
     let url = navigationAction.request.url,
     let urlComponents = URLComponents(string: url.absoluteString),
     urlComponents.path == "/oauth/authorize/native",
     let items = urlComponents.queryItems,
     let codeItem = items.first(where: { $0.name == "code" })
     {
     return codeItem.value
     } else {
     return nil
     }
     }
     */
    
}
