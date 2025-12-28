import XCTest
import SwiftUI
@testable import HordeForged

final class MainGameScreenTests: XCTestCase {
    func testMainGameViewInitialization() {
        // This will fail to compile until MainGameView is created
        let view = MainGameView()
        XCTAssertNotNil(view)
    }

    func testBackgroundPropertyIsSet() {
        let view = MainGameView()
        XCTAssertNotNil(view.background)
    }

    func testPlayerInfoViewIsIntegrated() {
        let view = MainGameView()
        XCTAssertNotNil(view.playerInfoView)
    }


}
