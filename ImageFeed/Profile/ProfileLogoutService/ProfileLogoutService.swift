import Foundation
import WebKit
import Kingfisher

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanAuthToken()
        cleanCookies()
        cleanServices()
        switchToLogin()
    }
    
    private func cleanAuthToken() {
        OAuth2TokenStorage.shared.token = nil
        URLCache.shared.removeAllCachedResponses()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanServices(){
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
        
        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
        ImagesListService.shared.reset()
    }
    
    private func switchToLogin() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("❌ [ProfileLogoutService][switchToLogin]Invalid Configuration")
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}
