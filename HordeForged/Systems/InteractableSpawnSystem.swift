import GameplayKit
import SpriteKit

class InteractableSpawnSystem: GKComponentSystem<GKComponent> {
    
    let scene: SKScene
    let gameManager: GameManager
    
    var spawnTimer: TimeInterval = 0
    var spawnInterval: TimeInterval = 5.0 // Every 5 seconds
    let maxInteractables: Int = 20
    
    // Loot is now determined dynamically

    
    init(scene: SKScene, gameManager: GameManager) {
        self.scene = scene
        self.gameManager = gameManager
        super.init(componentClass: GKComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        spawnTimer -= seconds
        
        if spawnTimer <= 0 {
            // Check Cap
            let count = gameManager.entities.filter { $0 is DestructibleEntity }.count
            if count < maxInteractables {
                spawnRandomInteractable()
            }
            spawnTimer = spawnInterval + Double.random(in: -1.0...2.0)
        }
    }
    
    private func spawnRandomInteractable() {
        guard let scene = scene as? GameScene,
              let camera = scene.camera else { return }
        
        // Spawn off-screen
        let zoom = camera.xScale
        let spawnRadius: CGFloat = (max(scene.size.width, scene.size.height) / 2 + 100) * zoom
        let angle = CGFloat.random(in: 0...(2 * .pi))
        
        let spawnX = camera.position.x + cos(angle) * spawnRadius
        let spawnY = camera.position.y + sin(angle) * spawnRadius
        
        // Create Loot Table
        // Use randomItem type
        let loot = [LootItem(type: .randomItem, value: 1, chance: 1.0)]
        
        let pot = DestructibleEntity(position: CGPoint(x: spawnX, y: spawnY), lootTable: loot)
        gameManager.add(pot)
    }
}
