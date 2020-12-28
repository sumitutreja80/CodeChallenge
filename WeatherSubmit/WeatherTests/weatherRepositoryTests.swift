//
//  weatherRepositoryTests.swift
//  weatherTests
//
//  Created by Utreja, Sumit on 20/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import XCTest
@testable import Weather

class weatherRepositoryTests : XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRepositoryCreation() {
        let repo = WeatherCityRepository.init(with: WeatherCityRequest.init())
        XCTAssertNotNil(repo)
    }

    func testRepositoryCompletionBlockInvokedWithError() {
        let expct = expectation(description: "responseblock")
        let repo = WeatherCityRepository.init(with: WeatherCityRequest.init())
        repo.get { (response, error) in
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            expct.fulfill()
        }
        waitForExpectations(timeout: 15.0) { (error) in
            XCTAssertNil(error)
        }
    }
}
