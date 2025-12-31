import GameplayKit
import SpriteKit

class EnemySpawnSystem: GKComponentSystem<GKComponent> {
    
    let scene: SKScene
    let gameManager: GameManager
    
    var spawnTimer: TimeInterval = 0
    var spawnInterval: TimeInterval = 3.0 // Slower for Testing
    let maxEnemies: Int = 100
    
    var isSwarmActive: Bool = false
    var swarmSpawnInterval: TimeInterval = 0.1
    var originalSpawnInterval: TimeInterval = 1.0
    
    init(scene: SKScene, gameManager: GameManager) {
        self.scene = scene
        self.gameManager = gameManager
        super.init(componentClass: GKComponent.self) // We don't really manage components, just logic.
    }
    
    func triggerSwarm() {
        if !isSwarmActive {
            isSwarmActive = true
            originalSpawnInterval = spawnInterval
            spawnInterval = swarmSpawnInterval
            print("Swarm Triggered!")
        }
    }
    
    func endSwarm() {
        if isSwarmActive {
            isSwarmActive = false
            spawnInterval = originalSpawnInterval
             print("Swarm Ended!")
        }
    }
    
    var isHardMode: Bool = false
    
    override func update(deltaTime seconds: TimeInterval) {
        // Just logic
        spawnTimer -= seconds
        
        if spawnTimer <= 0 {
            // Cap Check
            let currentEnemyCount = gameManager.entities.filter { $0 is EnemyEntity }.count
            // Increase cap during swarm or hard mode?
            var currentMax = isSwarmActive ? maxEnemies * 2 : maxEnemies
            if isHardMode { currentMax *= 2 } // Double cap in hard mode
            
            guard currentEnemyCount < currentMax else {
                return // Skip spawn, try again next frame/interval
            }
            
            spawnTimer = spawnInterval
            spawnEnemy()
            
            // Ramp up difficulty? (Decrease interval slightly)
            if !isSwarmActive && !isHardMode && spawnInterval > 0.2 {
                spawnInterval -= 0.01
            }
        }
    }
    
    func activateHardMode() {
        print("HARD MODE ACTIVATED")
        isHardMode = true
        spawnInterval = 0.2 // Fast spawn
        // Provide visual Feedback?
    }
    
    private func spawnEnemy() {
        guard let scene = scene as? GameScene else { return }
        
        // Find a spawn position outside camera view
        // Camera position
        let cameraPos = scene.camera?.position ?? .zero
        
        let spawnRadius: CGFloat = max(scene.size.width, scene.size.height) / 2 + 100 // Just offscreen
        
        let randomAngle = CGFloat.random(in: 0...(2 * .pi))
        let spawnX = cameraPos.x + cos(randomAngle) * spawnRadius
        let spawnY = cameraPos.y + sin(randomAngle) * spawnRadius
        
        // Health Scaling
        let baseHealth = 30
        let health = isHardMode ? baseHealth * 5 : baseHealth
        let color: SKColor = isHardMode ? .black : .red // Visual indicator
        
        let enemy = EnemyEntity(color: color, size: CGSize(width: 30, height: 30), health: health)
        enemy.component(ofType: SpriteComponent.self)?.node.position = CGPoint(x: spawnX, y: spawnY)
        
        gameManager.add(enemy)
    }
}
