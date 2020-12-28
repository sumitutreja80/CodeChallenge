//
//  weatherTests.swift
//  weatherTests
//
//  Created by Utreja, Sumit on 18/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import XCTest
@testable import Weather

class SearchCityInteractorTests: XCTestCase {
    var expectation: XCTestExpectation!
    
    let interactor = SearchCityInteractor <WeatherCityCommand<WeatherCity, WeatherCityRequest>>()
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        interactor.stop()
    }
    
    func testLoadDataSuccess() {
        expectation = expectation(description: "interactor load data")
        let vm: WeatherOutput = WeatherOutput()
        vm.cityName = "Hyderabad"
        interactor.loadData(vm) {(response, error) in
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            self.expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15.0) { (error) in
            XCTAssertNil(error)
        }
    }
}
