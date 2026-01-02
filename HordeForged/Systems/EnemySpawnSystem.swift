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
        
        // Timer Progress
        let total = gameManager.gameTimerSystem.totalDuration
        let remaining = gameManager.gameTimerSystem.timeRemaining
        
        // Progress 0.0 to 1.0 (Start to Finish)
        let progress = total > 0 ? (1.0 - (remaining / total)) : 0.0
        
        // Find Active Wave
        // Last wave where progress >= startPct
        let currentWave = WaveConfig.waves.last(where: { progress >= $0.startPct }) ?? WaveConfig.waves.first!
        
        // Update Difficulty Params
        spawnInterval = currentWave.spawnInterval
        if isSwarmActive { spawnInterval = swarmSpawnInterval } // Override for specific events if needed
        
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
            spawnEnemy(using: currentWave.spawnTable)
        }
    }
    
    func activateHardMode() {
        print("HARD MODE ACTIVATED")
        isHardMode = true
        // spawnInterval override? Or just let waves handle it?
        // With waves, hard mode might be implicit in late waves.
        // But if this is triggered by external event (Timer End), we can keep it as an override.
    }
    
    private func spawnEnemy(using table: [EnemyType: Double]) {
        guard let scene = scene as? GameScene else { return }
        
        // Find a spawn position outside camera view
        // Camera position
        let cameraPos = scene.camera?.position ?? .zero
        
        // Adjust for zoom
        let zoom = scene.camera?.xScale ?? 1.0
        let spawnRadius: CGFloat = (max(scene.size.width, scene.size.height) / 2 + 100) * zoom // Just offscreen
        
        let randomAngle = CGFloat.random(in: 0...(2 * .pi))
        let spawnX = cameraPos.x + cos(randomAngle) * spawnRadius
        let spawnY = cameraPos.y + sin(randomAngle) * spawnRadius
        
        // Select Enemy Type from Table
        let type = pickEnemy(from: table)
        
        // Get Stage Index
        let stageIndex = LevelManager.shared.currentLevelIndex
        
        let enemy = EnemyEntity(type: type, stage: stageIndex)
        enemy.component(ofType: SpriteComponent.self)?.node.position = CGPoint(x: spawnX, y: spawnY)
        
        gameManager.add(enemy)
    }
    
    private func pickEnemy(from table: [EnemyType: Double]) -> EnemyType {
        let totalWeight = table.values.reduce(0, +)
        let randomVal = Double.random(in: 0..<totalWeight)
        
        var currentWeight = 0.0
        for (type, weight) in table {
            currentWeight += weight
            if randomVal < currentWeight {
                return type
            }
        }
        return .walker // Fallback
    }
}
