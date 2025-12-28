import XCTest
import SwiftUI
@testable import HordeForged

final class TypographyTests: XCTestCase {
    func testCustomFontsExist() {
        // This will fail to compile until the font extension is created
        let titleFont = Font.hordeTitle
        XCTAssertNotNil(titleFont)
    }
}
