import XCTest
@testable import HordeForged

final class EntityTests: XCTestCase {

    func testEntityCanBeCreatedWithID() {
        let entity = Entity()
        XCTAssertNotNil(entity.id)
    }

    func testEntityCanAddComponent() {
        var entity = Entity()
        let position = PositionComponent(x: 1.0, y: 2.0)
        entity.addComponent(position)
        XCTAssertNotNil(entity.getComponent(ofType: PositionComponent.self))
    }

    func testEntityCanRetrieveComponent() {
        var entity = Entity()
        let health = HealthComponent(currentHealth: 10, maxHealth: 10)
        entity.addComponent(health)
        let retrievedHealth = entity.getComponent(ofType: HealthComponent.self)
        XCTAssertEqual(retrievedHealth?.currentHealth, 10)
    }

    func testEntityReturnsNilForMissingComponent() {
        let entity = Entity()
        let missingComponent: PositionComponent? = entity.getComponent(ofType: PositionComponent.self)
        XCTAssertNil(missingComponent)
    }

    func testEntityCanRemoveComponent() {
        var entity = Entity()
        let position = PositionComponent(x: 1.0, y: 2.0)
        entity.addComponent(position)
        XCTAssertNotNil(entity.getComponent(ofType: PositionComponent.self))

        entity.removeComponent(ofType: PositionComponent.self)
        XCTAssertNil(entity.getComponent(ofType: PositionComponent.self))
    }
}
