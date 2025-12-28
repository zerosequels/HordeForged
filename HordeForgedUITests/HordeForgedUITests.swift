//
//  HordeForgedUITests.swift
//  HordeForgedUITests
//
//  Created by Nick Johnston on 12/27/25.
//

import XCTest

final class HordeForgedUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testSKViewIsPresentAndVisible() throws {
        let app = XCUIApplication()
        app.launch()

        // We expect an element with accessibility identifier "GameSKView" to be present
        // This test will fail until the SKView is implemented and given this identifier.
        let skViewElement = app.otherElements["GameSKView"]
        XCTAssertTrue(skViewElement.exists, "SKView with identifier 'GameSKView' should be present and visible.")
    }
}
