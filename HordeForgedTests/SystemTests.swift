import XCTest
internal import GameplayKit
import SpriteKit
@testable import HordeForged

final class SystemTests: XCTestCase {

    func testMovementComponentUpdatesPosition() {
        // Setup Entity
        let entity = GKEntity()
        
        // Setup Components
        let spriteComponent = SpriteComponent(color: .red, size: CGSize(width: 10, height: 10))
        spriteComponent.node.position = CGPoint(x: 0, y: 0)
        entity.addComponent(spriteComponent)
        
        let movementComponent = MovementComponent()
        movementComponent.velocity = CGVector(dx: 1.0, dy: 0.0)
        movementComponent.movementSpeed = 100.0
        entity.addComponent(movementComponent)
        
        // Perform Update
        // Delta time 1.0 -> Move 100 units right
        movementComponent.update(deltaTime: 1.0)
        
        XCTAssertEqual(Double(spriteComponent.node.position.x), 100.0, accuracy: 0.001)
        XCTAssertEqual(Double(spriteComponent.node.position.y), 0.0, accuracy: 0.001)
    }

    func testMovementComponentIgnoresMissingSpriteComponent() {
        // Setup Entity without SpriteComponent
        let entity = GKEntity()
        
        let movementComponent = MovementComponent()
        movementComponent.velocity = CGVector(dx: 1.0, dy: 0.0)
        entity.addComponent(movementComponent)
        
        // Perform Update - Should verify no crash
        movementComponent.update(deltaTime: 1.0)
        
        XCTAssertTrue(true, "Update called without crash despite missing SpriteComponent")
    }
}
