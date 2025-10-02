import Foundation

private struct UserResult: Codable {
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }

    var profileImage: ProfileImage

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.profileImage = try container.decode(ProfileImage.self, forKey: .profileImage)
    }
}


final class ProfileImageService{
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    private init() {}
    
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = makeProfileImageRequest(username: username) else {
            let message = "❌ [fetchProfileImageURL]: Invalid URL"
            print(message)
            completion(.failure(NetworkError.invalidURL(message: message)))
            return
        }
        task = URLSession.shared.data(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            self.task = nil
            switch result {
            case .success(let userResult):
                guard let avatarURL = userResult.profileImage.large ?? userResult.profileImage.medium ?? userResult.profileImage.small else { return }
                self.avatarURL = avatarURL
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
                completion(.success(avatarURL))
            case .failure(let error):
                print("❌ [fetchProfileImageURL]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let url = URL(string: "\(WebViewConstants.unsplashProfileImageURLString2)/\(username)") else {
            print("❌ [makeProfileImageRequest]: Unable to use WebViewConstants.unsplashProfileImageURLString to create URL")
            guard let newURL = URL(string: "https://api.unsplash.com/users/\(username)") else {
                assertionFailure("❌ [makeProfileImageRequest]: Failed to create new URL")
                return URLRequest(url: URL(fileURLWithPath: ""))
            }
            return URLRequest(url: newURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌ [makeProfileImageRequest]: Token not found")
            return nil
        }
        print("URLRequest URL: \(request.url?.absoluteString ?? "nil")")
        print("URLRequest HTTP Method: \(request.httpMethod ?? "GET")")
        return request
    }
}
