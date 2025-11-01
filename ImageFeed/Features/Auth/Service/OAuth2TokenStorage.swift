import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    // MARK: - Properties
    static let shared = OAuth2TokenStorage()
    private let keychainWrapper = KeychainWrapper.standard
    private let tokenKey = "OAuth2Token"
    var token: String? {
        get {
            keychainWrapper.string(forKey: AuthConfiguration.standard.bearerToken)
        }
        set {
            guard let newValue = newValue else {
                keychainWrapper.removeObject(forKey: AuthConfiguration.standard.bearerToken)
                return
            }
            keychainWrapper.set(newValue, forKey: AuthConfiguration.standard.bearerToken)
        }
    }
}
