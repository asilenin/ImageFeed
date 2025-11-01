import UIKit
import WebKit

public protocol ImageListPresenterProtocol {
    var viewController: ImagesListViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didTapLike(at indexPath: IndexPath)
    func cellDidEndDisplaying(at indexPath: IndexPath)
    func initiateFetchPhotosNextPage()
}

final class ImageListPresenter: ImageListPresenterProtocol {
    // MARK: - Public Properties
    weak var viewController: ImagesListViewControllerProtocol?
    // MARK: - Private Properties
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] {
        return imagesListService.photos
    }
    
    // MARK: - Lifecycle
    func viewDidLoad(){
        
    }
    
    // MARK: - Public Methods
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.viewController?.reloadRows(at: [indexPath])
            case .failure(let error):
                print("Ошибка: \(error)")
                let alert = UIAlertController(
                    title: "Что-то пошло не так(",
                    message: "Не удалось изменить статус лайка",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                self.viewController?.present(alert, animated: true, completion: nil)
            }
            
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    func cellDidEndDisplaying(at indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            initiateFetchPhotosNextPage()
        }
    }
    
    func initiateFetchPhotosNextPage() {
        if !imagesListService.isLoading {
            if let token = OAuth2TokenStorage.shared.token {
                imagesListService.fetchPhotosNextPage(token: token) { _ in
                }
            } else {
                print("❌ [ImagesListViewController][tableView forRowAt]: No OAuth token found — cannot load photos.")
            }
        }
    }
}
