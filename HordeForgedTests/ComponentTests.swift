import XCTest
@testable import HordeForged

final class ComponentTests: XCTestCase {

    func testComponentProtocolCanBeAdopted() {
        // Test that a struct can conform to a hypothetical Component protocol
        struct TestComponent: Component {
            var id = UUID() // Required by the Component protocol
            let value: Int
        }
        let component = TestComponent(value: 10)
        XCTAssertEqual(component.value, 10)
    }

    func testPositionComponentDataEncapsulation() {
        // This test assumes a PositionComponent will be created
        struct PositionComponent: Component {
            var id = UUID()
            var x: Float
            var y: Float
        }

        let position = PositionComponent(x: 10.0, y: 20.0)
        XCTAssertEqual(position.x, 10.0)
        XCTAssertEqual(position.y, 20.0)

        // Ensure immutability or proper mutation if designed
        // For now, testing basic encapsulation
        var mutablePosition = position
        mutablePosition.x = 15.0
        XCTAssertEqual(mutablePosition.x, 15.0)
        XCTAssertEqual(position.x, 10.0) // Original should remain unchanged
    }
}

