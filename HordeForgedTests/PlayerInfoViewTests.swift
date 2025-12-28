import XCTest
import SwiftUI
@testable import HordeForged

final class PlayerInfoViewTests: XCTestCase {
    func testPlayerInfoViewInitialization() {
        // This will fail to compile until PlayerInfoView is created
        let view = PlayerInfoView()
        XCTAssertNotNil(view)
    }
}
