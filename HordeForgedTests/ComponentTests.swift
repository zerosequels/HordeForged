import XCTest
internal import GameplayKit
import SpriteKit
@testable import HordeForged

final class ComponentTests: XCTestCase {

    func testSpriteComponentInitialization() {
        let texture = SKTexture()
        let component = SpriteComponent(texture: texture)
        
        XCTAssertNotNil(component.node)
        XCTAssertTrue(component.node is SKSpriteNode)
    }

    func testMovementComponentInitialization() {
        let component = MovementComponent()
        XCTAssertEqual(component.velocity, .zero)
        XCTAssertEqual(component.movementSpeed, 150.0)
    }
    
    func testMovementComponentValuesModifiable() {
        let component = MovementComponent()
        component.velocity = CGVector(dx: 1, dy: 1)
        component.movementSpeed = 200.0
        
        XCTAssertEqual(component.velocity, CGVector(dx: 1, dy: 1))
        XCTAssertEqual(component.movementSpeed, 200.0)
    }
}

