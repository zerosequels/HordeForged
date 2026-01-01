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
        return [movementSystem, self.dashSystem]
    }()
    
    var fireProjectileSystem: FireProjectileSystem!
    var dashSystem: DashSystem!
    var collisionSystem: CollisionSystem!
    var playerExperienceSystem: PlayerExperienceSystem!
    var gameTimerSystem: GameTimerSystem!
    var enemyMovementSystem: EnemyMovementSystem!
    var mapSystem: MapSystem!
    var indicatorSystem: IndicatorSystem!
    var interactionSystem: InteractionSystem!
    var interactableSpawnSystem: InteractableSpawnSystem!
    
    lazy var enemySpawnSystem: EnemySpawnSystem = {
        return EnemySpawnSystem(scene: self.scene!, gameManager: self)
    }()
    
    weak var scene: SKScene?
    
    init(scene: SKScene) {
        self.scene = scene
        self.fireProjectileSystem = FireProjectileSystem(scene: scene)
        self.dashSystem = DashSystem()
        self.collisionSystem = CollisionSystem(scene: scene)
        self.playerExperienceSystem = PlayerExperienceSystem(scene: scene)
        self.playerExperienceSystem = PlayerExperienceSystem(scene: scene)
        
        // Check for timer override
        var timerDuration: TimeInterval?
        if let override = UserDefaults.standard.object(forKey: "overrideGameDuration") {
            if let doubleVal = override as? Double {
                timerDuration = doubleVal
            } else if let stringVal = override as? String, let doubleVal = Double(stringVal) {
                timerDuration = doubleVal
            }
        }
        self.gameTimerSystem = GameTimerSystem(duration: timerDuration)
        
        self.enemyMovementSystem = EnemyMovementSystem(scene: scene)
        self.enemyMovementSystem = EnemyMovementSystem(scene: scene)
        self.mapSystem = MapSystem(scene: scene)
        self.indicatorSystem = IndicatorSystem(scene: scene)
        self.interactionSystem = InteractionSystem()
        self.interactionSystem.scene = scene
        self.interactableSpawnSystem = InteractableSpawnSystem(scene: scene, gameManager: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onStageChanged), name: NSNotification.Name("StageChanged"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onStageChanged() {
        restartLevel()
    }
    // ... (add method remains mostly same, need to add to system via update)
    
    func add(_ entity: GKEntity) {
        entities.insert(entity)
        
        if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
            scene?.addChild(spriteComponent.node)
        }
        
        for system in componentSystems {
            system.addComponent(foundIn: entity)
        }
        
        // Track Player for Fire System & Other Systems
        if entity is SurvivorEntity {
            fireProjectileSystem.playerEntity = entity
            indicatorSystem.playerEntity = entity
            interactionSystem.playerEntity = entity
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
        
        // Add to new systems
        indicatorSystem.addComponent(foundIn: entity)
        interactionSystem.addComponent(foundIn: entity)
        // InteractableSpawnSystem doesn't need component tracking, it just spawns.
    }
    
    func applyDamage(target: GKEntity, amount: Int) {
        guard let healthComp = target.component(ofType: HealthComponent.self) else { return }
        
        // Apply Damage
        healthComp.currentHealth -= amount
        
        // Show Visual Feedback
        if let spriteComp = target.component(ofType: SpriteComponent.self),
           let gameScene = scene as? GameScene {
            gameScene.showDamage(amount: amount, position: spriteComp.node.position)
        }
        
        // Check for Death
        if healthComp.currentHealth <= 0 {
            handleEnemyDeath(target)
        }
    }

    func handleEnemyDeath(_ enemy: GKEntity) {
        // Ensure entity is still valid to prevent double-death logic
        guard entities.contains(enemy) else { return }
        
        // Spawn XP Orb
        if let spriteComponent = enemy.component(ofType: SpriteComponent.self) {
            let orb = ExpOrbEntity(value: 5, position: spriteComponent.node.position)
            add(orb)
        }
        
        // Remove from Game
        remove(enemy)
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
        indicatorSystem.removeComponent(foundIn: entity)
        interactionSystem.removeComponent(foundIn: entity)
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
        checkBossStatus()
        
        // Enemy Systems
        enemyMovementSystem.update(deltaTime: deltaTime)
        enemySpawnSystem.update(deltaTime: deltaTime)
        
        // Map System
        mapSystem.update(deltaTime: deltaTime)
        
        // Indicator System
        indicatorSystem.update(deltaTime: deltaTime)
        
        // Interaction System
        interactionSystem.update(deltaTime: deltaTime)
        
        // Interactables
        interactableSpawnSystem.update(deltaTime: deltaTime)
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
    
    func checkBossStatus() {
        // If boss was active but is now gone/dead
        if let boss = activeBoss {
            // Check if removed or dead
            if !entities.contains(boss) || (boss.component(ofType: HealthComponent.self)?.currentHealth ?? 0) <= 0 {
                print("Boss Defeated! Enabling Crucible Core...")
                activeBoss = nil
                
                // Find Core and Enable Interaction
                if let core = entities.first(where: { $0 is CrucibleCoreEntity }),
                   let interact = core.component(ofType: InteractionComponent.self) {
                    interact.isInteractable = true
                    // Visual feedback?
                }
            }
        }
    }

    
    // MARK: - Boss & Level Event
    var activeBoss: GKEntity?
    
    func spawnBoss(at position: CGPoint) {
        guard activeBoss == nil else { return }
        
        // Use Stage Config for boss type?
        let boss = EnemyEntity(color: .purple, size: CGSize(width: 80, height: 80), health: 500) // Beefy
        boss.component(ofType: SpriteComponent.self)?.node.position = position
        
        if let move = boss.component(ofType: MovementComponent.self) {
            move.movementSpeed = 80
        }
        
        add(boss)
        activeBoss = boss
        print("Boss Spawned!")
    }
    
    func spawnCrucibleCore() {
        // Spawn far away from player
        // Player is usually at 0,0 locally, but world position moves?
        // Actually Camera moves. Player uses Joystick logic.
        // Assuming Player starts at 0,0 or keeps updating position.
        
        var startPos: CGPoint = .zero
        if let player = entities.first(where: { $0 is SurvivorEntity }),
           let sprite = player.component(ofType: SpriteComponent.self) {
            startPos = sprite.node.position
        }
        
        // Fixed distance 3000
        let type = LevelManager.shared.currentLevelIndex
        // Maybe vary angle by level?
        let angle = Double(type) * 0.5 // Randomish direction change
        let dist: CGFloat = 3000
        
        let x = startPos.x + cos(angle) * dist
        let y = startPos.y + sin(angle) * dist
        
        let core = CrucibleCoreEntity(position: CGPoint(x: x, y: y), chargeTime: 5.0)
        add(core)
        print("Crucible Core Spawned at \(x), \(y)")
    }
    
    func setupLevel() {
         // Called after reset or init
         spawnCrucibleCore()
         
         // Setup Stage Config specific things?
         // MapSystem handles tiles automatically via Notification.
    }
    
    func restartLevel() {
        print("Restarting Level...")
        
        // Remove All Entities except Player? Or respawn player?
        // Usually full reset.
        let allEntities = entities
        for entity in allEntities {
             remove(entity)
        }
        
        // Reset Systems
        // Check for timer override again
        var timerDuration: TimeInterval?
        if let override = UserDefaults.standard.object(forKey: "overrideGameDuration") {
            if let doubleVal = override as? Double {
                timerDuration = doubleVal
            } else if let stringVal = override as? String, let doubleVal = Double(stringVal) {
                timerDuration = doubleVal
            }
        }
        gameTimerSystem = GameTimerSystem(duration: timerDuration)
        
        activeBoss = nil
        
        // Ask Scene to respawn Player
        if let gameScene = scene as? GameScene {
             gameScene.setupGame() // This respawns player and test entities
        }
        
        // Prepare new level elements
        setupLevel()
    }
}
