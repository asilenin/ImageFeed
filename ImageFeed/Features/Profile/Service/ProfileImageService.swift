import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage?
}

final class ProfileImageService{
    
    // MARK: - Properties
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    private init() {}
    
    // MARK: - Lifecycle
    func reset() {
        task?.cancel()
        task = nil
        avatarURL = nil
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: ProfileImageService.didChangeNotification,
                object: self,
                userInfo: ["URL": ""]
            )
        }
    }
}

extension ProfileImageService{
    
    // MARK: - Public Methods
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = makeProfileImageRequest(username: username) else {
            let message = "❌ [ProfileImageService][fetchProfileImageURL]: Invalid URL"
            print(message)
            completion(.failure(NetworkError.invalidURL(message: message)))
            return
        }
        task = URLSession.shared.data(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            self.task = nil
            switch result {
            case .success(let userResult):
                guard
                    let profileImage = userResult.profileImage,
                    let avatarURL = profileImage.large ?? profileImage.medium ?? profileImage.small
                else {
                    print("❌ [ProfileImageService][fetchProfileImageURL]: No valid profile image URL found")
                    return
                }

                self.avatarURL = avatarURL
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL]
                )
                completion(.success(avatarURL))

            case .failure(let error):
                print("❌ [ProfileImageService][fetchProfileImageURL]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
    // MARK: - Private Methods
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let url = URL(string: "\(WebViewConstants.unsplashProfileImageURLString2)/\(username)") else {
            print("❌ [ProfileImageService][makeProfileImageRequest]: Unable to use WebViewConstants.unsplashProfileImageURLString to create URL")
            guard let newURL = URL(string: "https://api.unsplash.com/users/\(username)") else {
                assertionFailure("❌ [ProfileImageService][makeProfileImageRequest]: Failed to create new URL")
                return URLRequest(url: URL(fileURLWithPath: ""))
            }
            return URLRequest(url: newURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌ [ProfileImageService][makeProfileImageRequest]: Token not found")
            return nil
        }
        print("URLRequest URL: \(request.url?.absoluteString ?? "nil")")
        print("URLRequest HTTP Method: \(request.httpMethod ?? "GET")")
        return request
    }
}
