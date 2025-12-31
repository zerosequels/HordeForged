import GameplayKit
import SpriteKit

public class GameManager {
    var entities = Set<GKEntity>()
    
    // Component systems to update components in a deterministic order
    lazy var componentSystems: [GKComponentSystem] = {
        let movementSystem = GKComponentSystem(componentClass: MovementComponent.self)
        // We added EnemyMovementSystem manually, but standard MovementComponents (like on player/projectile) need updates.
        // Wait, does MovementComponent need to be in componentSystems if EnemyMovementSystem is handling it?
        // MovementComponent.update() applies velocity.
        // EnemyMovementSystem.update() sets velocity.
        // So YES, MovementComponent MUST be updated.
        // Standard 'movementSystem' here does that.
        // EnemyEntity has MovementComponent, so it will be added to this if we check for it.
        return [movementSystem]
    }()
    
    var fireProjectileSystem: FireProjectileSystem!
    var collisionSystem: CollisionSystem!
    var playerExperienceSystem: PlayerExperienceSystem!
    var gameTimerSystem: GameTimerSystem!
    var enemyMovementSystem: EnemyMovementSystem!
    
    lazy var enemySpawnSystem: EnemySpawnSystem = {
        return EnemySpawnSystem(scene: self.scene!, gameManager: self)
    }()
    
    weak var scene: SKScene?
    
    init(scene: SKScene) {
        self.scene = scene
        self.fireProjectileSystem = FireProjectileSystem(scene: scene)
        self.collisionSystem = CollisionSystem(scene: scene)
        self.playerExperienceSystem = PlayerExperienceSystem(scene: scene)
        self.gameTimerSystem = GameTimerSystem()
        self.enemyMovementSystem = EnemyMovementSystem(scene: scene)
        
        self.gameTimerSystem = GameTimerSystem()
        self.enemyMovementSystem = EnemyMovementSystem(scene: scene)
    }
    
    func add(_ entity: GKEntity) {
        entities.insert(entity)
        
        if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
            scene?.addChild(spriteComponent.node)
        }
        
        for system in componentSystems {
            system.addComponent(foundIn: entity)
        }
        
        // Track Player for Fire System
        if entity is SurvivorEntity {
            fireProjectileSystem.playerEntity = entity
        }
        
        // Add to Experience System
        playerExperienceSystem.addComponent(foundIn: entity)
        
        // Track Player for Enemy Movement
        if entity is SurvivorEntity {
            enemyMovementSystem.playerEntity = entity
        }
        
        // Add Enemies to Movement System
        if entity is EnemyEntity {
            enemyMovementSystem.addComponent(foundIn: entity)
        }
    }
    
    func remove(_ entity: GKEntity) {
        if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
            spriteComponent.node.removeFromParent()
        }
        
        entities.remove(entity)
        
        for system in componentSystems {
            system.removeComponent(foundIn: entity)
        }
        
        enemyMovementSystem.removeComponent(foundIn: entity)
    }
    
    func update(_ deltaTime: TimeInterval) {
        for system in componentSystems {
            system.update(deltaTime: deltaTime)
        }
        
        fireProjectileSystem.update(deltaTime: deltaTime)
        collisionSystem.update(deltaTime: deltaTime)
        playerExperienceSystem.update(deltaTime: deltaTime)
        gameTimerSystem.update(deltaTime: deltaTime)
        
        // check for defeat
        checkDefeat()
        
        // Enemy Systems
        enemyMovementSystem.update(deltaTime: deltaTime)
        enemySpawnSystem.update(deltaTime: deltaTime)
    }
    
    func checkDefeat() {
        guard !gameTimerSystem.isGameOver else { return }
        
        // Find Player
        if let player = entities.first(where: { $0 is SurvivorEntity }),
           let healthComp = player.component(ofType: HealthComponent.self) {
            
            if healthComp.currentHealth <= 0 {
                gameTimerSystem.isGameOver = true
                gameTimerSystem.onGameEnd?(false) // Defeat
            }
        }
    }

    
    // MARK: - Boss Event
    var activeBoss: GKEntity?
    
    func spawnBoss(at position: CGPoint) {
        guard activeBoss == nil else { return }
        
        let boss = EnemyEntity(color: .purple, size: CGSize(width: 80, height: 80), health: 500) // Beefy
        boss.component(ofType: SpriteComponent.self)?.node.position = position
        
        // Slightly slower code reused? or just use same components
        if let move = boss.component(ofType: MovementComponent.self) {
            move.movementSpeed = 80 // Slower
        }
        
        // Add a tag or just use reference?
        // Let's add it normally. CollisionSystem logic for projectiles treats it as EnemyEntity.
        
        add(boss)
        activeBoss = boss
        print("Boss Spawned!")
    }
    
    func restartLevel() {
        print("Restarting Level...")
        
        // Simple restart: Remove all entities, re-setup.
        // Or tell Scene to restart.
        // Scene.setupGame handles "setup", but we need to clear first.
        
        // Remove All
        let allEntities = entities // snapshot
        for entity in allEntities {
             remove(entity)
        }
        
        // Reset Systems?
        gameTimerSystem = GameTimerSystem()
        
        // Call setup on scene
        if let gameScene = scene as? GameScene {
             gameScene.setupGame()
        }
    }
}
