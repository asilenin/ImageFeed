import XCTest
import UIKit
import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    // MARK: - Public Properties
    var presenter: ProfilePresenterProtocol?
    var nameLabel: String?
    var loginNameLabel: String?
    var descriptionLabel: String?
    var avatarURL: URL?
    
    // MARK: - Private Properties
    private(set) var viewDidLoadCalled = false
    
    
    // MARK: - Public Methods
    
    func updateProfileDetails(profile: Profile) {
        nameLabel = profile.name
        loginNameLabel = profile.loginName
        descriptionLabel = profile.bio
    }
    
    func updateAvatar(url: URL?) {
        avatarURL = url
    }
    
    func didTapLogoutButton(){
        
    }
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter?.viewController = self
    }
}
