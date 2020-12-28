//
//  weatherCommandTests.swift
//  weatherTests
//
//  Created by Utreja, Sumit on 20/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import XCTest
@testable import Weather

class weatherCommandTests : XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCommandCreation() {
        let cmd = WeatherCityCommand<WeatherCity, WeatherCityRequest>()
        XCTAssertNotNil(cmd)
    }

    func testCommandRespondsToExecute() {
        let cmd = WeatherCityCommand<WeatherCity, WeatherCityRequest>()
        XCTAssertTrue(cmd.responds(to: #selector(WeatherCityCommand<WeatherCity, WeatherCityRequest>.main)))
    }

    func testCommandCallsResponseBlock() {
        let expct = expectation(description: "responseblock")
        let cmd = WeatherCityCommand<WeatherCity, WeatherCityRequest>()

        cmd.executeTask(request: WeatherCityRequest.init(), type: WeatherCity.self) { (response, error) in
            expct.fulfill()
        }
        waitForExpectations(timeout: 15.0) { (error) in
            XCTAssertNil(error)
        }
    }
}
