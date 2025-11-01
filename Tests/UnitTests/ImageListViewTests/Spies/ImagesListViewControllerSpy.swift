import UIKit
import XCTest
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImageListPresenterProtocol?
    var updateTableViewAnimatedCalled: Bool = false
    var reloadRowsCalled: Bool = false
    var reloadRowsIndexPaths: [IndexPath]?
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
    
    func reloadRows(at indexPaths: [IndexPath]) {
        reloadRowsCalled = true
        reloadRowsIndexPaths = indexPaths
    }
    
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {

    }
    
    func configure(presenter: ImageListPresenterProtocol) {
        self.presenter = presenter
    }
}

