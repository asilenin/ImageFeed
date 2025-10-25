import Foundation

final class ImagesListService {
    
    static let shared = ImagesListService()
    
    private(set) var photos: [Photo] = []
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    
    var isLoading = false
    
    func fetchPhotosNextPage(token: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard !isLoading else {
            print("❌  [ImageListService][fetchPhotosNextPage]: photos already fitching. stop request")
            return
        }
        isLoading = true
        let nextPage = (lastLoadedPage ?? 0) + 1
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = makeListOfPhotosRequest(page: nextPage, numberOfPhotos: Constants.numberOfPhotosPerPage) else {
            isLoading = false
            print("❌ [ImageListService][fetchPhotosNextPage]: NetworkError - invalidURL")
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
                        print("❌ [ImageListService][fetchPhotosNextPage]: unable to fetch image URL")
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
                        fullImageURL: imageURL,
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
                print("❌ [ImageListService][fetchPhotosNextPage]: Error - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
    private func makeListOfPhotosRequest(page: Int, numberOfPhotos: Int =  Constants.numberOfPhotosPerPage) -> URLRequest? {
        let urlComponents = URLComponents(string: WebViewConstants.unsplashListOfPhotosURLString)
        guard var urlComponents else {
            print("❌  [ImageListService][makeListOfPhotosRequest]: cannot create URL using WebViewConstants.unsplashListOfPhotosURLString")
            assertionFailure("Failed to create URL")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(numberOfPhotos))
        ]
        
        guard let url = urlComponents.url else {
            print("❌  [ImageListService][makeListOfPhotosRequest]: unable to create URL from URLComponents")
            assertionFailure("Failed to create URL with components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌ [ImageListService][makeListOfPhotosRequest]: token not found")
            return nil
        }
        print("URLRequest URL: \(request.url?.absoluteString ?? "nil")")
        print("URLRequest HTTP Method: \(request.httpMethod ?? "GET")")
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            print("❌ [ImageListService][changeLike]: NetworkError - invalidURL")
            completion(.failure(NetworkError.invalidURL(message: "❌ changeLike: NetworkError - invalidURL")))
            return
        }
        task = URLSession.shared.data(for: request) { [weak self] (result: Result<LikePhotoResult, Error>) in
            guard let self else { return }
            self.task = nil
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            fullImageURL: photo.fullImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    }
                    completion(.success(()))
                }
            case .failure(let error):
                print("❌ [ImageListService][changeLike]: Error - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let url = URL(string: "\(WebViewConstants.unsplashListOfPhotosURLString)/\(photoId)/like") else {
            print("Ошибка: Не удалось создать URL из WebViewConstants.unsplashListOfPhotosURLString")
            guard let newURL = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
                assertionFailure("Failed to create new URL")
                return URLRequest(url: URL(fileURLWithPath: ""))
            }
            return URLRequest(url: newURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Токен не найден")
            return nil
        }
        print("URLRequest URL: \(request.url?.absoluteString ?? "nil")")
        print("URLRequest HTTP Method: \(String(describing: request.httpMethod))")
        return request
    }
    
    func reset() {
        task?.cancel()
        task = nil
        photos.removeAll()
        lastLoadedPage = nil
        isLoading = false
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
    }
}
