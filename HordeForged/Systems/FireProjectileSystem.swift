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
        
        if let gameScene = scene as? GameScene, gameScene.gameManager.debugSkills {
            print("[Skill] Activated \(ability.definition.name) (Lv \(ability.level))")
        }
        
        guard let spriteComponent = source.component(ofType: SpriteComponent.self) else { return }
        let position = spriteComponent.node.position
        
        var damageMult = 1.0
        if let inv = source.component(ofType: InventoryComponent.self) {
             damageMult = inv.damageMultiplier
        }
        
        switch ability.definition.id {
        case "arcane_bolt":
            // Base 10 + 5 per level
            // Level 1 = 15, Level 10 = 60
            let baseDamage = 10.0 + (Double(ability.level) * 5.0)
            fireProjectile(from: source, damage: baseDamage * damageMult, textureName: ability.definition.projectileName, rotationOffset: ability.definition.projectileRotationOffset)
            
        case "thunderclap":
            // Base 20 + 10 per level
            // Level 1 = 30, Level 10 = 120
            let baseDamage = 20.0 + (Double(ability.level) * 10.0)
            triggerRadialBlast(at: position, damage: baseDamage * damageMult)
            
        case "smite":
            // Smite Logic: Lightning on nearest enemy
            // Damage: Base 15 + 8/lvl
            let baseDamage = 15.0 + (Double(ability.level) * 8.0)
            triggerSmite(from: source, damage: baseDamage * damageMult)
            
        case "wind_slash", "dark_sever", "sanguine_bolt", "vine_lash", "stone_throw", "tidal_wave", "fireball", "iaido", "magic_missile", "boulder":
             // Standard Projectile Skills
             // Calculate damage (Generic formula for now: 10 + 5/lvl)
             // Some might be stronger/weaker, but this is a first pass.
             // Iaido is fast/low dmg, Boulder is slow/high dmg?
             // Helper to get base damage per ID? Or just switch:
            var baseDamage = 10.0 + (Double(ability.level) * 5.0)
            
            if ability.definition.id == "boulder" || ability.definition.id == "fireball" {
                baseDamage = 20.0 + (Double(ability.level) * 10.0)
            } else if ability.definition.id == "iaido" || ability.definition.id == "stone_throw" {
                 baseDamage = 8.0 + (Double(ability.level) * 4.0)
            }
            
            fireProjectile(from: source, damage: baseDamage * damageMult, textureName: ability.definition.projectileName, rotationOffset: ability.definition.projectileRotationOffset)

        case "tremor", "divine_decree", "arcane_strike":
            // Blast/Area Skills
            var baseDamage = 20.0 + (Double(ability.level) * 10.0)
            if ability.definition.id == "arcane_strike" {
                baseDamage = 15.0 + (Double(ability.level) * 5.0) // Lower dmg, faster cooldown usually
            }
             
            // Calls triggerRadialBlast - might need param for texture/color later
            triggerRadialBlast(at: position, damage: baseDamage * damageMult)
            
        default:
            print("Unknown ability activated: \(ability.definition.name)")
        }
    }
    
    func triggerRadialBlast(at position: CGPoint, damage: Double) {
        
        let timePerFrame = 1.0 / 24.0
        // Load textures for animation
        var textures: [SKTexture] = []
        for i in 0...15 {
            textures.append(SKTexture(imageNamed: "Projectiles/projectile_thunderclap_\(i)"))
        }
        let totalDuration = Double(textures.count) * timePerFrame
        
        // Create Entity
        let blastEntity = GKEntity()
        
        // 1. Visuals
        let blastNode = SKSpriteNode(texture: textures.first)
        blastNode.position = position
        blastNode.zPosition = 100
        blastNode.setScale(0.1) // Start small
        // blastNode.colorBlendFactor = 0 // Ensure original colors
        
        // Animation Actions
        let animation = SKAction.animate(with: textures, timePerFrame: timePerFrame)
        let scaleUp = SKAction.scale(to: 3.5, duration: totalDuration)
        let group = SKAction.group([animation, scaleUp])
        // We let BlastSystem handle removal, but adding this doesn't hurt visually
        blastNode.run(group)
        
        let spriteComp = SpriteComponent(texture: textures.first!)
        // Swap the node created by component with our configured one? 
        // Or just configure the component's node. 
        // SpriteComponent often creates a node. Let's use the component's node logic if we can, or just force ours.
        // Assuming SpriteComponent takes a texture and makes a node.
        if let node = spriteComp.node as? SKSpriteNode {
            node.texture = textures.first
            node.position = position
            node.zPosition = 100
            node.setScale(0.1)
            node.run(group)
        }
        blastEntity.addComponent(spriteComp)
        
        // 2. Logic (BlastComponent)
        // Max Radius? Visual scale 3.5. 
        // Base size of texture? 
        // Assuming 96x96 (standard projectile) or similar. 
        // If 100x100, scale 3.5 = 350 size -> 175 radius.
        // Let's estimate 150-180.
        let maxRadius: CGFloat = 175.0
        
        let blastComp = BlastComponent(
            center: position,
            maxRadius: maxRadius,
            duration: totalDuration,
            baseDamage: damage, // Use passed damage
            maxKnockback: 400.0 // User requested variable knockback, component handles it relative to max.
        )
        blastEntity.addComponent(blastComp)
        
        // 3. Add to Manager
        if let gameScene = scene as? GameScene {
            gameScene.gameManager.add(blastEntity)
        }
    }
    
    func fireProjectile(from source: GKEntity? = nil, damage: Double = 10, textureName: String? = nil, rotationOffset: CGFloat = 0) { 
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
                                        size: CGSize(width: 96, height: 96), 
                                        velocity: direction, 
                                        damage: Int(damage),
                                        textureName: textureName)
        
        if let projSprite = projectile.component(ofType: SpriteComponent.self) {
            projSprite.node.position = playerPosition
            // Calculate base rotation (facing direction)
            let angle = atan2(direction.dy, direction.dx)
            projSprite.node.zRotation = angle + rotationOffset
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
    
    func triggerSmite(from source: GKEntity, damage: Double) {
        guard let gameScene = scene as? GameScene,
              let sourceSprite = source.component(ofType: SpriteComponent.self) else { return }
        
        let sourcePos = sourceSprite.node.position
        
        // Find nearest target (Enemy OR Destructible)
        let potentialTargets = gameScene.gameManager.entities.filter { $0 is EnemyEntity || $0 is DestructibleEntity }
        var nearest: GKEntity?
        var minDist: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for target in potentialTargets {
            if let sprite = target.component(ofType: SpriteComponent.self) {
                let dist = hypot(sprite.node.position.x - sourcePos.x, sprite.node.position.y - sourcePos.y)
                // Range limit: 200 (Reduced from 400 as per request)
                if dist < 200 && dist < minDist {
                    minDist = dist
                    nearest = target
                }
            }
        }
        
        if let target = nearest,
           let targetSprite = target.component(ofType: SpriteComponent.self) {
            
            let targetPos = targetSprite.node.position
            
            // Visual: Lightning Bolt (Simple Line + Flash)
            if gameScene.gameManager.debugSkills {
                 print("[Skill] Smite: Striking target at \(targetPos) with \(damage) damage")
            }
            
            let bolt = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: targetPos.x, y: targetPos.y + 300)) // Start from sky
            path.addLine(to: targetPos)
            bolt.path = path
            bolt.strokeColor = .cyan
            bolt.lineWidth = 5
            bolt.glowWidth = 5
            scene.addChild(bolt)
            
            bolt.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.1),
                SKAction.fadeOut(withDuration: 0.1),
                SKAction.removeFromParent()
            ]))
            
            // Damage + AOE
            // AOE Radius 50
            let aoeTargets = potentialTargets.filter {
                if let s = $0.component(ofType: SpriteComponent.self) {
                   return hypot(s.node.position.x - targetPos.x, s.node.position.y - targetPos.y) < 50
                }
                return false
            }
            
            for hit in aoeTargets {
                gameScene.gameManager.applyDamage(target: hit, amount: Int(damage), sourcePosition: targetPos, knockbackPower: 0) // No knockback on Smite? Or minimal?
            }
        }
    }
}
