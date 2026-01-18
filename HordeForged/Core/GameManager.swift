import GameplayKit
import SpriteKit

public class GameManager {
    var entities = Set<GKEntity>()
    public var debugSkills: Bool = true // User requested logging
    
    
    // Component systems to update components in a deterministic order
    lazy var componentSystems: [GKComponentSystem] = {
        let movementSystem = GKComponentSystem(componentClass: MovementComponent.self)
        let animationSystem = GKComponentSystem(componentClass: AnimationComponent.self)
        // We added EnemyMovementSystem manually, but standard MovementComponents (like on player/projectile) need updates.
        // Wait, does MovementComponent need to be in componentSystems if EnemyMovementSystem is handling it?
        // MovementComponent.update() applies velocity.
        // EnemyMovementSystem.update() sets velocity.
        // So YES, MovementComponent MUST be updated.
        // Standard 'movementSystem' here does that.
        // EnemyEntity has MovementComponent, so it will be added to this if we check for it.
        return [movementSystem, self.dashSystem, animationSystem]
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
    var blastSystem: BlastSystem!

    
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
        self.blastSystem = BlastSystem(scene: scene)

        
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
        // BlastSystem
        blastSystem.addComponent(foundIn: entity)

    }
    
    func applyDamage(target: GKEntity, amount: Int, sourcePosition: CGPoint? = nil, knockbackPower: CGFloat = 0.0) {
        guard let healthComp = target.component(ofType: HealthComponent.self) else { return }
        
        // Apply Damage
        var damageRemaining = Double(amount)
        
        if healthComp.barrier > 0 {
            if healthComp.barrier >= damageRemaining {
                healthComp.barrier -= damageRemaining
                damageRemaining = 0
            } else {
                damageRemaining -= healthComp.barrier
                healthComp.barrier = 0
            }
        }
        
        if damageRemaining > 0 {
            healthComp.currentHealth -= Int(damageRemaining)
        }
        
        // Show Visual Feedback (TEXT)
        if let spriteComp = target.component(ofType: SpriteComponent.self),
           let gameScene = scene as? GameScene {
            gameScene.showDamage(amount: amount, position: spriteComp.node.position)
            
            // --- Hit Flash ---
            // Colorize to white and back fast
            let flashAction = SKAction.sequence([
                SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.05),
                SKAction.wait(forDuration: 0.05),
                SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.05) // Return to original
            ])
            spriteComp.node.run(flashAction, withKey: "HitFlash") // Unique key overwrites previous flash
            
            // --- Recoil / Knockback ---
            if let sourcePos = sourcePosition, knockbackPower > 0,
               let moveComp = target.component(ofType: MovementComponent.self) {
                
                let dx = spriteComp.node.position.x - sourcePos.x
                let dy = spriteComp.node.position.y - sourcePos.y
                
                // Normalize and Apply
                let dist = hypot(dx, dy)
                if dist > 0.001 {
                    let ndx = dx / dist
                    let ndy = dy / dist
                    
                    // Apply Resistance
                    let resistance = moveComp.knockbackResistance
                    let effectivePower = knockbackPower * (1.0 - resistance)
                    
                    let impulse = CGVector(dx: ndx * effectivePower, dy: ndy * effectivePower)
                    
                    // Add to existing knockback (allows stacking) or set?
                    // Setting feels cleaner for "last hit wins" impact.
                    moveComp.knockbackVelocity = impulse
                }
            }
        }
        
        // Check for Death
        if healthComp.currentHealth <= 0 {
            if target is EnemyEntity || target is DestructibleEntity {
                handleEnemyDeath(target)
            }
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
        blastSystem.removeComponent(foundIn: entity)

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
        
        // Blast Logic
        blastSystem.update(deltaTime: deltaTime)

        
        // Update Entities (for SurvivorEntity logic etc)
        for entity in entities {
            entity.update(deltaTime: deltaTime)
        }
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
        let stageIndex = LevelManager.shared.currentLevelIndex
        let boss = EnemyEntity(type: .boss, stage: stageIndex)
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
        
        // Find Player to persist
        let player = entities.first(where: { $0 is SurvivorEntity })
        
        // Remove All Entities except Player
        let allEntities = entities
        for entity in allEntities {
            if entity !== player {
                remove(entity)
            }
        }
        
        // Reset Player Position
        if let player = player,
           let sprite = player.component(ofType: SpriteComponent.self) {
            sprite.node.position = CGPoint(x: 0, y: 0)
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
        
        // Reset existing timer system instead of replacing it
        gameTimerSystem.reset(duration: timerDuration)
        
        activeBoss = nil
        
        // Prepare new level elements
        setupLevel()
        
        // Force update camera to player position immediately
        if let player = player,
           let sprite = player.component(ofType: SpriteComponent.self),
           let gameScene = scene as? GameScene {
             gameScene.camera?.position = sprite.node.position
        }
    }
}
