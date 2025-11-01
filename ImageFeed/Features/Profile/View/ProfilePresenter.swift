import UIKit

protocol ProfilePresenterProtocol {
    var viewController: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateAvatar()
    func updateProfileDetails()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    // MARK: - Public Properties
    weak var viewController: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    // MARK: - Lifecycle
    func viewDidLoad(){
        updateProfileDetails()
        updateAvatar()
    }
    
    // MARK: - Public Methods
    func updateAvatar() {
        guard let viewController else {
            print("❌[ProfilePresenter][updateAvatar]: View is nil")
            return
        }
        
        viewController.updateAvatar(url: URL(string: ProfileImageService.shared.avatarURL ?? ""))
    }
    
    func updateProfileDetails() {
        guard let profile = profileService.profile else {
            print("❌[ProfilePresenter][updateAvatar]: Profile not loaded")
            return
        }
        guard let viewController else {
            print("❌[ProfilePresenter][updateAvatar]: View is nil")
            return
        }
        viewController.updateProfileDetails(profile: profile)
    }
}
