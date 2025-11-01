import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    
    // MARK: - Test 1
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.configure(presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    // MARK: - Test 2
    func testUpdateProfileAndAvatar() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.configure(presenter)
        _ = viewController.view
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(presenter.updateProfileCalled)
        XCTAssertTrue(presenter.updateAvatarCalled)
    }
    
    // MARK: - Test 3
    func testUpdateProfileData() {
        //given
        let viewController = ProfileViewControllerSpy()
        let result = ProfileResult(username: "test", firstName: "Test", lastName: "Name", bio: "Test Bio")
        let profile = Profile(from: result)
        
        //when
        viewController.updateProfileDetails(profile: profile)
        
        //then
        XCTAssertEqual(viewController.nameLabel, "Test Name")
        XCTAssertEqual(viewController.loginNameLabel, "@test",)
        XCTAssertEqual(viewController.descriptionLabel, "Test Bio")
    }
    
    // MARK: - Test 4
    func testUpdateAvatarImageURL() {
        //given
        let viewController = ProfileViewControllerSpy()
        let testURL = URL(string: "https://test.com")
        
        //when
        viewController.updateAvatar(url: testURL)
        
        //then
        XCTAssertEqual(viewController.avatarURL, testURL)
    }
}
