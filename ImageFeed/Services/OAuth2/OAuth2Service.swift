import UIKit
import WebKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private init() {}
    private var task: URLSessionTask?
    
    private let decoder: JSONDecoder = {        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
    
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        let request = makeOAuth2TokenRequest(code: code)
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let data = data else {
                    print("❌ Empty data")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.noData))
                    }
                    return
                }
                
                do {
                    let tokenResponse = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let token = tokenResponse.accessToken
                    self.tokenStorage.token = token
                    DispatchQueue.main.async {
                        completion(.success(token))
                    }
                } catch {
                    completion(.failure(NetworkError.decodingError(message: "❌ Encode/Decode error in JSON: \(error.localizedDescription)")))
                }
            }
        }
        task?.resume()
    }
    
    func makeOAuth2TokenRequest(code: String) -> URLRequest {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashTokenURLString) else {
            preconditionFailure("❌ Invalid WebViewConstants.unsplashTokenURLString")
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            preconditionFailure("❌ Invalid urlComponents.url")
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}
