import UIKit
import WebKit

final class OAuth2Service {
    
    // MARK: - Properties
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
}

extension OAuth2Service {
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print("❌ [fetchOAuthToken]: AuthServiceError error - invalidRequest, code: \(code)")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        if task != nil {
            print("❌ [fetchOAuthToken]: Cancel previous task with code: \(lastCode ?? "nil")")
            task?.cancel()
        }
        
        lastCode = code
        
        guard let request = auth2TokenRequest(code: code)
        else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task = urlSession.data(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in defer {
            self?.task = nil
            self?.lastCode = nil
        }
            switch result {
            case .success(let response):
                completion(.success(response.accessToken))
                
            case .failure(let error):
                print("❌ [fetchOAuthToken]: Network error - \(error.localizedDescription) with code: \(code)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
    func auth2TokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashTokenURLString) else {
            preconditionFailure("❌ [OAuth2Service]: Invalid WebViewConstants.unsplashTokenURLString")
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            preconditionFailure("❌ [OAuth2Service]: Invalid urlComponents.url")
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.post.rawValue
        print("request: \(request)")
        return request
    }
}
