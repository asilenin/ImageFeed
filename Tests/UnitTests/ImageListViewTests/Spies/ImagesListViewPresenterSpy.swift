import Foundation
import UIKit
@testable import ImageFeed

final class ImagesListViewPresenterSpy: ImageListPresenterProtocol {
    
    var photos: [ImageFeed.Photo] = []
    var viewController: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var didTapLikeCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalled = true
    }
    
    func cellWasDisplayed(at indexPath: IndexPath) {
        
    }
    
    func initiateFetchPhotosNextPage() {
        
    }
    
    func cellDidEndDisplaying(at indexPath: IndexPath) {
    
    }
    
}
