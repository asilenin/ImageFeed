import Foundation

final class ProfileService {
    static let shared = ProfileService()
    init() {}
    
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = makeProfileRequest() else {
            print("❌ [ProfileService][fetchProfile]: NetworkError - invalidURL")
            completion(.failure(NetworkError.invalidURL(message: "❌ fetchProfile: NetworkError - invalidURL")))
            return
        }
        task = URLSession.shared.data(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            self.task = nil
            switch result {
            case .success(let response):
                let profile = Profile(from: response)
                //let profile = Profile(username: response.username, name: "\(response.firstName) \(response.lastName ?? "")", loginName: "@\(response.username)", bio: response.bio ?? "")
                //completion(.success(profile))
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("❌ [ProfileService][fetchProfile]: Error \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
    private func makeProfileRequest() -> URLRequest? {
        guard let url = URL(string: WebViewConstants.unsplashProfileURLString2) else {
            print("❌ [makeProfileRequest]: Unable to create URL using WebViewConstants.unsplashProfileURLString")
            guard let newURL = URL(string: "https://api.unsplash.com/me") else {
                assertionFailure("❌ [makeProfileRequest]:Failed to create new URL")
                return URLRequest(url: URL(fileURLWithPath: ""))
            }
            return URLRequest(url: newURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        if let token = OAuth2TokenStorage.shared.token {
            print("token \(token)")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        print("URLRequest URL: \(request.url?.absoluteString ?? "nil")")
        print("URLRequest HTTP Method: \(request.httpMethod ?? "GET")")
        return request
    }
}
