import Foundation
@testable import ImageFeed

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var viewController: ProfileViewControllerProtocol?
    var updateProfileCalled = false
    var updateAvatarCalled = false
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
        updateProfileCalled = true
        updateAvatarCalled = true
        
    }
    
    func updateAvatar() {
        
    }
    
    func updateProfileDetails() {
        
    }
    
}
