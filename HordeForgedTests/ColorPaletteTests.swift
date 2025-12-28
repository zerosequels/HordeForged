import XCTest
import SwiftUI
@testable import HordeForged

final class ColorPaletteTests: XCTestCase {
    func testCustomColorsExist() {
        // This will fail to compile until the color extension is created
        let gold = Color.hordeGold
        XCTAssertNotNil(gold)
    }

    func testShadowGrayColorExists() {
        // This test will fail until 'shadowGray' is defined in the Color extension
        let shadowGray = Color.shadowGray
        XCTAssertNotNil(shadowGray)
    }

}
