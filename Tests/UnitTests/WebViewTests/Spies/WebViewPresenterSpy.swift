import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?
    
    var viewDidLoadCalled: Bool = false
    
    var loadRequestCalled = false
    
    var viewController: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
    
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
    
    func load(request: URLRequest) {
        viewDidLoadCalled = true
    }

    func setProgressValue(_ newValue: Float) {
        // не используется в этом тесте
    }

    func setProgressHidden(_ isHidden: Bool) {
        // не используется в этом тесте
    }
}
