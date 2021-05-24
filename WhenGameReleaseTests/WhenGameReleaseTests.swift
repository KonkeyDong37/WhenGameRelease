//
//  WhenGameReleaseTests.swift
//  WhenGameReleaseTests
//
//  Created by Андрей on 29.03.2021.
//

import XCTest
@testable import WhenGameRelease

class APIClientTests: XCTestCase {

    var sut: TwithAuthServices!
        
    override func setUpWithError() throws {
        sut = TwithAuthServices()
        super.setUp()
    }

    override func tearDownWithError() throws {
        sut = nil
        super.tearDown()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
