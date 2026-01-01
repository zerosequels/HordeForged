import GameplayKit
import SpriteKit

class FireProjectileSystem: GKComponentSystem<GKComponent> {
    
    let scene: SKScene
    // For now we need a reference to the player to know where to spawn bullets
    // In a pure ECS this might be handled by querying for the player entity component
    weak var playerEntity: GKEntity?
    
    var timeSinceLastFire: TimeInterval = 0
    let fireInterval: TimeInterval = 0.5
    
    init(scene: SKScene) {
        self.scene = scene
        super.init(componentClass: GKComponent.self) // We don't really manage a specific component update here, just the global logic
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // New System: Checks Inventory for Active Abilities
        guard let player = playerEntity,
              let inventory = player.component(ofType: InventoryComponent.self) else {
            // Fallback for non-inventory entities if needed, or just return
            return
        }
        
        // Update Inventory (updates cooldowns)
        // Apply Attack Speed to Cooldowns
        // Higher multiplier = faster time = shorter cooldown
        let cooldownSpeed = inventory.attackSpeedMultiplier
        inventory.update(deltaTime: seconds * cooldownSpeed)
        
        // Check for Activations
        for ability in inventory.activeAbilities {
            if ability.canActivate() {
                activateAbility(ability, source: player)
                ability.activate() // Resets cooldown
            }
        }
    }
    
    func activateAbility(_ ability: AbilityInstance, source: GKEntity) {
        // Logic Router based on ability ID
        // In a real engine, ability logic might be attached to the definition or a script.
        // Here we switch on ID.
        
        guard let spriteComponent = source.component(ofType: SpriteComponent.self) else { return }
        let position = spriteComponent.node.position
        
        var damageMult = 1.0
        if let inv = source.component(ofType: InventoryComponent.self) {
             damageMult = inv.damageMultiplier
        }
        
        switch ability.definition.id {
        case "arcane_bolt":
            fireProjectile(from: source, damage: 10 * damageMult)
            
        case "thunderclap":
            triggerRadialBlast(at: position, damage: 20 * damageMult)
            
        default:
            print("Unknown ability activated: \(ability.definition.name)")
        }
    }
    
    func triggerRadialBlast(at position: CGPoint, damage: Double) {
        // Visual
        let blast = SKShapeNode(circleOfRadius: 100)
        blast.position = position
        blast.strokeColor = .orange
        blast.lineWidth = 2
        scene.addChild(blast)
        
        blast.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        
        // Logic: Find enemies in range and damage
        // We need access to enemies. Currently stored in GameManager.
        if let gameScene = scene as? GameScene {
             let enemies = gameScene.gameManager.entities.filter { $0 is EnemyEntity }
             for enemy in enemies {
                 if let enemySprite = enemy.component(ofType: SpriteComponent.self),
                    let healthCheck = enemy.component(ofType: HealthComponent.self) {
                     let dist = hypot(enemySprite.node.position.x - position.x, enemySprite.node.position.y - position.y)
                     if dist < 150 { // Range
                         gameScene.gameManager.applyDamage(target: enemy, amount: Int(damage))
                         // Optional: Knockback?
                     }
                 }
             }
        }
        
    }
    
    func fireProjectile(from source: GKEntity? = nil, damage: Double = 10) { 
        // If source provided, use it, else fallback to cached playerEntity
        guard let sourceEntity = source ?? playerEntity,
              let spriteComponent = sourceEntity.component(ofType: SpriteComponent.self) else { return }
        
        let playerPosition = spriteComponent.node.position
        
        // Determine direction
        var direction = CGVector(dx: 1, dy: 0)
        
        if let movement = sourceEntity.component(ofType: MovementComponent.self) {
             direction = movement.lastDirection
        }
        
        // Create Projectile
        let projectile = ProjectileEntity(color: .yellow, 
                                        size: CGSize(width: 10, height: 10), 
                                        velocity: direction, 
                                        damage: Int(damage))
        
        if let projSprite = projectile.component(ofType: SpriteComponent.self) {
            projSprite.node.position = playerPosition
        }

        
        // Add to GameManager/Scene
        // Using NotificationCenter or direct reference is common.
        // Let's assume the scene has a way to add entities or we trigger an event.
        // A cleaner way is for the System to have a delegate or reference to the GameManager.
        // For simplicity let's assume we can cast scene to GameScene and use its manager.
        
        if let gameScene = scene as? GameScene {
            gameScene.gameManager.add(projectile)
        }
    }
}
