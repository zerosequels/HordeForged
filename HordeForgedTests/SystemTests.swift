import XCTest
@testable import HordeForged

final class SystemTests: XCTestCase {

    func testSystemProtocolCanBeAdopted() {
        // Test that a struct can conform to a hypothetical System protocol
        struct TestSystem: System {
            func update(entities: inout [Entity], deltaTime: TimeInterval) {
                // Do nothing for this test
            }
        }
        let system = TestSystem()
        XCTAssertNotNil(system)
    }

    func testUpdatePositionSystemUpdatesPositionComponent() {
        var entity = Entity()
        entity.setComponent(PositionComponent(x: 0.0, y: 0.0))
        entity.setComponent(VelocityComponent(dx: 1.0, dy: 1.0))

        var entities = [entity]
        let system = UpdatePositionSystem()
        system.update(entities: &entities, deltaTime: 1.0)

        let updatedPosition = entities[0].getComponent(ofType: PositionComponent.self)
        XCTAssertEqual(updatedPosition?.x, 1.0)
        XCTAssertEqual(updatedPosition?.y, 1.0)
    }

    func testUpdatePositionSystemIgnoresEntitiesWithoutRequiredComponents() {
        var entity = Entity()
        entity.setComponent(PositionComponent(x: 0.0, y: 0.0))

        var entities = [entity]
        let system = UpdatePositionSystem()
        system.update(entities: &entities, deltaTime: 1.0)

        let updatedPosition = entities[0].getComponent(ofType: PositionComponent.self)
        XCTAssertEqual(updatedPosition?.x, 0.0) // Should not change
        XCTAssertEqual(updatedPosition?.y, 0.0) // Should not change
    }
}
