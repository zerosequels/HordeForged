
import XCTest
import SpriteKit
internal import GameplayKit
@testable import HordeForged

class FireProjectileSystemTests: XCTestCase {
    
    var gameManager: GameManager!
    var scene: GameScene!
    var fireSystem: FireProjectileSystem!
    
    override func setUp() {
        super.setUp()
        scene = GameScene(size: CGSize(width: 500, height: 500))
        gameManager = GameManager(scene: scene)
        fireSystem = gameManager.fireProjectileSystem
    }
    
    func testRadialBlastDamagesDestructible() {
        // 1. Create Destructible Entity (Pot)
        // Assuming DestructibleEntity has HealthComponent and SpriteComponent
        let pot = DestructibleEntity(position: CGPoint(x: 100, y: 100))
        gameManager.add(pot)
        
        guard let health = pot.component(ofType: HealthComponent.self) else {
            XCTFail("Destructible should have health")
            return
        }
        
        let initialHealth = health.currentHealth
        
        // 2. Trigger Blast nearby
        // Range is 150. Position 100,100 is within range of 100,100 (dist 0)
        fireSystem.triggerRadialBlast(at: CGPoint(x: 100, y: 100), damage: 20)
        
        // 3. Verify Damage
        XCTAssertEqual(health.currentHealth, initialHealth - 20, "Destructible should take damage from radial blast")
    }
}
