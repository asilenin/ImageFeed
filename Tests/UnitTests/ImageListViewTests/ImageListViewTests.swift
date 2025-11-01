<<<<<<< HEAD
@testable import ImageFeed
import XCTest

final class ImagesListViewTests: XCTestCase {
    
    // MARK: - Test 1
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListViewPresenterSpy()
        viewController.configure(presenter: presenter)
        presenter.viewController = viewController
        
        //when
        viewController.loadViewIfNeeded()
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    // MARK: - Test 2
    func testUpdateTableViewAnimatedCalled() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenterSpy()
        viewController.configure(presenter: presenter)
        presenter.viewController = viewController
        
        //when
        viewController.updateTableViewAnimated()
        
        //then
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
    }
    
    // MARK: - Test 3
    func testReloadRowsCalled() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenterSpy()
        viewController.configure(presenter: presenter)
        presenter.viewController = viewController
        
        let testIndexPaths = [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)]
        
        //when
        viewController.reloadRows(at: testIndexPaths)
        
        //then
        XCTAssertTrue(viewController.reloadRowsCalled)
        XCTAssertEqual(viewController.reloadRowsIndexPaths, testIndexPaths)
    }
    
    // MARK: - Test 4
    func testDidTapLikeCalled() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenterSpy()
        viewController.configure(presenter: presenter)
        presenter.viewController = viewController
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        //when
        presenter.didTapLike(at: indexPath)
        
        //then
        XCTAssertTrue(presenter.didTapLikeCalled)
    }
=======
//
//  ImageListViewTests.swift
//  ImageListViewTests
//
//  Created by Anton Silenin on 29.10.2025.
//

import Testing

struct ImageListViewTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

>>>>>>> 4b3032bbb48d5da78c55589d9f3e4782f707e8c7
}
