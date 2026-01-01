
import XCTest
internal import GameplayKit
import SpriteKit
@testable import HordeForged

class DashSystemLifecycleTests: XCTestCase {
    
    var gameManager: GameManager!
    var scene: GameScene!
    
    override func setUp() {
        super.setUp()
        // Minimal Scene setup
        scene = GameScene(size: CGSize(width: 500, height: 500))
        gameManager = GameManager(scene: scene)
    }
    
    func testDashSystemCorrectlyRemovesComponent() {
        // 1. Create Player with MovementComponent
        let player = SurvivorEntity(color: .blue, size: CGSize(width: 40, height: 40))
        let movement = player.component(ofType: MovementComponent.self)
        XCTAssertNotNil(movement, "Player must have movement component")
        
        // 2. Add player to GameManager
        gameManager.add(player)
        
        // 3. Verify DashSystem has the component
        // DashSystem initializes with componentClass: MovementComponent.self, so it should pick this up.
        XCTAssertTrue(gameManager.dashSystem.components.contains(movement!), "DashSystem should contain player movement component")
        
        // 4. Remove player (simulating stage transition or death)
        gameManager.remove(player)
        
        // 5. Verify DashSystem no longer has the component
        XCTAssertFalse(gameManager.dashSystem.components.contains(movement!), "DashSystem should NOT contain player movement component after removal")
    }
}
