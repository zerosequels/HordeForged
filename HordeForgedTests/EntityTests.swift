import XCTest
internal import GameplayKit
import SpriteKit
@testable import HordeForged

final class EntityTests: XCTestCase {

    func testSurvivorEntityCreation() {
        let entity = SurvivorEntity(color: .blue, size: CGSize(width: 10, height: 10))
        
        // SurvivorEntity should have SpriteComponent and MovementComponent by default
        XCTAssertNotNil(entity.component(ofType: SpriteComponent.self))
        XCTAssertNotNil(entity.component(ofType: MovementComponent.self))
    }

    func testEntityCanAddGenericComponent() {
        let entity = GKEntity()
        let component = MovementComponent()
        entity.addComponent(component)
        
        XCTAssertNotNil(entity.component(ofType: MovementComponent.self))
    }

    func testEntityReturnsNilForMissingComponent() {
        let entity = GKEntity()
        XCTAssertNil(entity.component(ofType: SpriteComponent.self))
    }

    func testEntityCanRemoveComponent() {
        let entity = GKEntity()
        let component = MovementComponent()
        entity.addComponent(component)
        XCTAssertNotNil(entity.component(ofType: MovementComponent.self))
        
        entity.removeComponent(ofType: MovementComponent.self)
        XCTAssertNil(entity.component(ofType: MovementComponent.self))
    }
}
