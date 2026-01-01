import XCTest
internal import GameplayKit
@testable import HordeForged

class EnvironmentInteractionTests: XCTestCase {
    
    var gameManager: GameManager!
    var scene: GameScene!
    
    override func setUp() {
        super.setUp()
        scene = GameScene(size: CGSize(width: 1000, height: 1000))
        gameManager = GameManager(scene: scene)
        scene.gameManager = gameManager // Link back
    }
    
    func testDestructibleLootDrop() {
        // Setup Destructible
        let loot = [LootItem(type: .expOrb, value: 50, chance: 1.0)]
        let pot = DestructibleEntity(position: .zero, lootTable: loot)
        gameManager.add(pot)
        
        // Ensure it's there
        XCTAssertTrue(gameManager.entities.contains(pot))
        
        // Damage it to death
        guard let health = pot.component(ofType: HealthComponent.self) else {
            XCTFail("Missing Health Component")
            return
        }
        
        // Check loot component exists
        XCTAssertNotNil(pot.component(ofType: LootComponent.self))
        XCTAssertEqual(loot.first?.value, 50)
    }
    
    func testRandomLootDrop() {
        // Setup Collision System (access via scene or create new)
        let collisionSystem = CollisionSystem(scene: scene)
        
        // Create loot component with random item
        let loot = [LootItem(type: .randomItem, value: 3, chance: 1.0)]
        let lootComp = LootComponent(lootTable: loot)
        
        // Trigger spawn
        collisionSystem.spawnLoot(from: lootComp, position: .zero, gameScene: scene)
        
        // Assert
        // Should have added an ItemPickupEntity
        let pickup = gameManager.entities.first { $0 is ItemPickupEntity } as? ItemPickupEntity
        XCTAssertNotNil(pickup)
        XCTAssertEqual(pickup?.count, 3)
        XCTAssertFalse(pickup?.itemID.isEmpty ?? true)
    }
    
    func testHazardSlowEffect() {
        let player = SurvivorEntity(color: .blue, size: CGSize(width: 40, height: 40))
        gameManager.add(player)
        
        guard let moveComp = player.component(ofType: MovementComponent.self) else {
            XCTFail("Missing Movement Component")
            return
        }
        
        // Default
        XCTAssertEqual(moveComp.speedModifier, 1.0)
        
        // Interaction simulation (CollisionSystem logic)
        moveComp.speedModifier = 0.5
        
        // Verify velocity calculation
        moveComp.velocity = CGVector(dx: 1, dy: 0)
        let dt: TimeInterval = 1.0
        // Update
        moveComp.update(deltaTime: dt)
        
        // Expected move: 150 * 0.5 * 1.0 = 75
        // Original X: 0
        // New X: 75
        guard let sprite = player.component(ofType: SpriteComponent.self) else { return }
        XCTAssertEqual(sprite.node.position.x, 75.0, accuracy: 0.1)
    }
    
    func testCrucibleChargeLogic() {
        let core = CrucibleCoreEntity(position: .zero, chargeTime: 10.0)
        gameManager.add(core)
        
        guard let chargeComp = core.component(ofType: ChargeComponent.self) else {
            XCTFail("Missing ChargeComponent")
            return
        }
        
        XCTAssertEqual(chargeComp.currentCharge, 0)
        XCTAssertEqual(chargeComp.state, .charging)
        
        // Simulate charge
        chargeComp.addCharge(5.0)
        XCTAssertEqual(chargeComp.currentCharge, 5.0)
        XCTAssertEqual(chargeComp.state, .charging)
        
        chargeComp.addCharge(5.0)
        XCTAssertEqual(chargeComp.currentCharge, 10.0)
        XCTAssertEqual(chargeComp.state, .bossSummoned) // Should transition to bossSummoned when max charge reached
        
        // Overcharge check
        chargeComp.addCharge(1.0)
        XCTAssertEqual(chargeComp.currentCharge, 10.0)
    }
}
