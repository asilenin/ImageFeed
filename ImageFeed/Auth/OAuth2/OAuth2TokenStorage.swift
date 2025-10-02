import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    //private let userDefaults = UserDefaults.standard
    private let keychainWrapper = KeychainWrapper.standard
    private let tokenKey = "OAuth2Token"
    
    var token: String? {
        get {
            keychainWrapper.string(forKey: Constants.bearerToken)
        }
        set {
            guard let newValue = newValue else {
                return
            }
            keychainWrapper.set(newValue, forKey: Constants.bearerToken)
        }
    }
}
