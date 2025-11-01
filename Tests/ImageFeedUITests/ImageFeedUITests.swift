import XCTest

final class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    //key to skip auth test to keep limits of 
    var ifRunAuthTest = false
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        let app = XCUIApplication()
        if ifRunAuthTest {
            app.launchArguments = ["-reset"]
        }
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        
        if !ifRunAuthTest {
            return
        }
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        
        loginTextField.tap()
        loginTextField.typeText(ImageFeedUITestsConstants.loginTextData)
        
        let startPoint = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
        let endPoint = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.0))
        startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        let keyboard = app.keyboards.element
        XCTAssertTrue(keyboard.waitForExistence(timeout: 5), "Keyboard did not appear after tapping password field")

        // Ensure password field is visible and focused
        if !passwordTextField.isHittable {
            // center-tap helps when element is partially covered
            let center = passwordTextField.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            center.tap()
            XCTAssertTrue(passwordTextField.waitForExistence(timeout: 1))
            
        } else {
            passwordTextField.tap()
            XCTAssertTrue(passwordTextField.waitForExistence(timeout: 1))
        }

        if app.keyboards.count == 0 {
            webView.tap()
            XCTAssertTrue(webView.waitForExistence(timeout: 1))
        }

        passwordTextField.typeText(ImageFeedUITestsConstants.passwordTextData)
        
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        sleep(10)
        firstCell.swipeUp()
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)

        let likeButtonOff = cellToLike.buttons["like button off"]
        let likeButtonOn = cellToLike.buttons["like button on"]

        // Wait for one of the buttons to appear
        let buttonToTap = likeButtonOff.exists ? likeButtonOff : likeButtonOn
        sleep(5)
        buttonToTap.tap()

        // Wait for the alternate button to appear after state change
        let alternateButton = (buttonToTap == likeButtonOff ? likeButtonOn : likeButtonOff)
        sleep(5)
        alternateButton.tap()
        
        cellToLike.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["singleImageViewBackButton"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()
       
        XCTAssertTrue(app.staticTexts[ImageFeedUITestsConstants.userNameTextData].exists)
        
        app.buttons["Logout"].tap()
        
        let yesButton = app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 5))
        XCTAssertTrue(yesButton.isHittable)
        yesButton.tap()
    }
}
