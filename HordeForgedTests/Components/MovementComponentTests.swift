import XCTest
import SpriteKit
@testable import HordeForged

class MovementComponentTests: XCTestCase {
    
    var movementComponent: MovementComponent!
    var entity: SurvivorEntity!
    var spriteComponent: SpriteComponent!
    
    override func setUp() {
        super.setUp()
        // Use SurvivorEntity which is available via @testable import
        entity = SurvivorEntity(color: .red, size: CGSize(width: 10, height: 10))
        
        // Access via property to avoid GKEntity method calls requiring GameplayKit import in test
        movementComponent = entity.movementComponent
        spriteComponent = entity.spriteComponent
    }
    
    override func tearDown() {
        movementComponent = nil
        spriteComponent = nil
        entity = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertEqual(movementComponent.velocity, .zero)
        XCTAssertEqual(movementComponent.lastDirection, CGVector(dx: 1, dy: 0)) // Default Right
    }
    
    func testUpdatePositionWithVelocity() {
        movementComponent.velocity = CGVector(dx: 1, dy: 0) // Right
        movementComponent.movementSpeed = 100
        
        // Update for 1 second
        movementComponent.update(deltaTime: 1.0)
        
        XCTAssertEqual(spriteComponent.node.position.x, 100)
        XCTAssertEqual(spriteComponent.node.position.y, 0)
    }
    
    func testLastDirectionUpdatesWhenMoving() {
        movementComponent.velocity = CGVector(dx: 0, dy: 1) // Up
        movementComponent.update(deltaTime: 0.1)
        
        XCTAssertEqual(movementComponent.lastDirection, CGVector(dx: 0, dy: 1))
    }
    
    func testLastDirectionPersistsWhenStopped() {
        // First move up
        movementComponent.velocity = CGVector(dx: 0, dy: 1)
        movementComponent.update(deltaTime: 0.1)
        XCTAssertEqual(movementComponent.lastDirection, CGVector(dx: 0, dy: 1))
        
        // Then stop
        movementComponent.velocity = .zero
        movementComponent.update(deltaTime: 0.1)
        
        // Should still be Up
        XCTAssertEqual(movementComponent.lastDirection, CGVector(dx: 0, dy: 1))
    }
}
