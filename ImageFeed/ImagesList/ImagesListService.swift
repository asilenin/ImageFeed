import Foundation

final class ImagesListService {
    
    static let shared = ImagesListService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var task: URLSessionTask?
    
    private var lastLoadedPage: Int?
    private(set) var photos: [Photo] = []
    
    var isLoading = false
    
    func fetchPhotosNextPage(token: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard !isLoading else {
            print("❌  [fetchPhotosNextPage]: photos already fitching. stop request")
            return
        }
        isLoading = true
        let nextPage = (lastLoadedPage ?? 0) + 1
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = makeListOfPhotosRequest(page: nextPage, numberOfPhotos: Constants.numberOfPhotosPerPage) else {
            isLoading = false
            print("❌ [fetchPhotosNextPage]: NetworkError - invalidURL")
            completion(.failure(NetworkError.invalidURL(message: "Неправильный URL")))
            return
        }
        
        task = URLSession.shared.data(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            self.isLoading = false
            self.task = nil
            switch result {
            case .success(let photoResults):
                var photos: [Photo] = []
                for photoResult in photoResults {
                    guard let imageURL = photoResult.urls.regular ?? photoResult.urls.full ?? photoResult.urls.raw ?? photoResult.urls.small ?? photoResult.urls.thumb else {
                        print("❌ [fetchPhotosNextPage]: unable to fetch image URL")
                        continue
                    }
                    let size = CGSize(width: photoResult.width, height: photoResult.height)
                    let photo = Photo(
                        id: photoResult.id,
                        size: size,
                        createdAt: photoResult.createdAt?.toDateFormat(),
                        welcomeDescription: photoResult.description,
                        thumbImageURL: imageURL,
                        largeImageURL: imageURL,
                        isLiked: photoResult.likedByUser
                    )
                    photos.append(photo)
                }
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: photos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    completion(.success(photos))
                }
                
            case .failure(let error):
                print("❌ [fetchPhotosNextPage]: Error - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
    private func makeListOfPhotosRequest(page: Int, numberOfPhotos: Int =  Constants.numberOfPhotosPerPage) -> URLRequest? {
        let urlComponents = URLComponents(string: WebViewConstants.unsplashListOfPhotosURLString)
        guard var urlComponents else {
            print("❌  [makeListOfPhotosRequest]: cannot create URL using WebViewConstants.unsplashListOfPhotosURLString")
            assertionFailure("Failed to create URL")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(numberOfPhotos))
        ]
        
        guard let url = urlComponents.url else {
            print("❌  [makeListOfPhotosRequest]: unable to create URL from URLComponents")
            assertionFailure("Failed to create URL with components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌  [makeListOfPhotosRequest]: token not found")
            return nil
        }
        print("URLRequest URL: \(request.url?.absoluteString ?? "nil")")
        print("URLRequest HTTP Method: \(request.httpMethod ?? "GET")")
        return request
    }
}
