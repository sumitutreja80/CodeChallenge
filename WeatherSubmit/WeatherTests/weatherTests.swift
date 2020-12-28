//
//  weatherTests.swift
//  weatherTests
//
//  Created by Utreja, Sumit on 18/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import XCTest
@testable import Weather

class BaseTestCase: XCTestCase {
    override func setUp() {
        UserSession(with: "unitTests")
        super.setUp()
    }
}

class weatherPresenterTests: XCTestCase {

    class MockInteractor: SearchCityInteracting {
        func loadData(_ vmO: WeatherOutput, completion: @escaping (Decodable?, Error?) -> ()) {
            testPresenter?.expectation.fulfill()
        }
        
        func loadFromDB() -> [WeatherCity] {
            return []
        }
        
        var testPresenter: weatherPresenterTests!
        
        required init(tester: weatherPresenterTests) {
            testPresenter = tester
        }

        func willReload<T>(withData: [T], completion: @escaping ([T]) -> ()) where T : Decodable {
            
        }
        
        func stop() {
            
        }
    }

    class MockInterface: SearchCityInterface {
        func load(_ vm: WeatherResult) {
            
        }
        
        func display(_ error: Error) {
            
        }
        

        var testPresenter: weatherPresenterTests!
        var presenter: SearchCityPresenting?
        
        required init(tester: weatherPresenterTests) {
            testPresenter = tester
        }
    }

    class MockRouter: SearchCityRouting {
        var presenter: SearchCityPresenting?
        var testPresenter: weatherPresenterTests!
        
        required init(tester: weatherPresenterTests) {
            testPresenter = tester
        }
        
        func navigate(to option: SearchCityNavigationOption) {
        }
    }

    var expectation: XCTestExpectation!
    var presenter: SearchCityPresenter!
    var mockInteractor: MockInteractor!
    var mockRouter: MockRouter!
    var mockInterface: MockInterface!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockInteractor = MockInteractor(tester : self)
        mockRouter = MockRouter(tester: self)
        mockInterface = MockInterface(tester: self)
        
        let viewController: SearchCityViewController =
            SearchCityModule.buildDefault() as! SearchCityViewController
        presenter = viewController.presenter as? SearchCityPresenter
        presenter.view = mockInterface
        presenter.router = mockRouter
        presenter.interactor = mockInteractor
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadViewWithData() {
        // TODO : has been broken by the location manager implementaiton. Needs to implement
        // using protocol.
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        expectation = expectation(description: "load view and data")
        self.presenter?.viewDidLoad()
        waitForExpectations(timeout: 15.0) { (error) in
            XCTAssertNil(error)
        }
    }

}
