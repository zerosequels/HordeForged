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
            triggerRadialBlast(at: position, damage: baseDamage * damageMult, textureName: "projectile_thunderclap")
            
        case "smite":
            // Smite Logic: Lightning on nearest enemy
            // Damage: Base 15 + 8/lvl
            let baseDamage = 15.0 + (Double(ability.level) * 8.0)
            triggerSmite(from: source, damage: baseDamage * damageMult, textureName: ability.definition.projectileName)
            
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
            let textureName = ability.definition.projectileName // Should be projectile_tremor etc if set
            triggerRadialBlast(at: position, damage: baseDamage * damageMult, textureName: textureName)
            
        default:
            print("Unknown ability activated: \(ability.definition.name)")
        }
    }
    
    func triggerRadialBlast(at position: CGPoint, damage: Double, textureName: String? = nil) {
        
        let timePerFrame = 1.0 / 24.0
        // Load textures for animation
        var textures: [SKTexture] = []
        
        // Try to load animation frames first if textureName is provided
        if let name = textureName {
            // Check for frames 0..15? Or just use single texture if frames fail?
            // For now, let's assume if there are no frames, we use the single texture.
            // Loading 16 frames blindly might be slow/error prone if they don't exist.
            // Let's try to load frame 0. If it exists, assume animation.
            let frame0 = SKTexture(imageNamed: "\(name)_0")
             // SKTexture(imageNamed:) returns a placeholder if not found? No, it returns a texture that might be empty/dummy?
             // Actually SpriteKit behavior for missing image is tricky.
             // But simpler approach: Just use the single texture and scale it up.
             // Generating 16 frames of animation is hard for the user.
             // Scaling one sprite is easy.
             textures.append(SKTexture(imageNamed: name))
        } else {
             // Fallback
             for i in 0...15 {
                textures.append(SKTexture(imageNamed: "Projectiles/projectile_thunderclap_\(i)"))
             }
        }
        
        // If we only have 1 texture (the single asset), we don't animate frames, just scale.
        // If we have 16 (fallback), we animate.
        
        let totalDuration = 0.5 // Fixed duration for blast?
        
        // Create Entity
        let blastEntity = GKEntity()
        
        // 1. Visuals
        let blastNode = SKSpriteNode(texture: textures.first)
        blastNode.position = position
        blastNode.zPosition = 100
        blastNode.setScale(0.1) // Start small
        // blastNode.colorBlendFactor = 0 // Ensure original colors
        
        // Animation Actions
        var group: SKAction
        if textures.count > 1 {
             let animation = SKAction.animate(with: textures, timePerFrame: totalDuration / Double(textures.count))
             let scaleUp = SKAction.scale(to: 3.5, duration: totalDuration)
             group = SKAction.group([animation, scaleUp, SKAction.fadeOut(withDuration: totalDuration)])
             // Added fadeout to make single sprite look better?
        } else {
            // Single sprite expansion
            let scaleUp = SKAction.scale(to: 3.5, duration: totalDuration)
            let fadeOut = SKAction.fadeOut(withDuration: totalDuration)
            group = SKAction.group([scaleUp, fadeOut])
        }
        
        // We let BlastSystem handle removal, but adding this doesn't hurt visually
        blastNode.run(group)
        
        let spriteComp = SpriteComponent(texture: textures.first!)
        if let node = spriteComp.node as? SKSpriteNode {
            node.texture = textures.first
            node.position = position
            node.zPosition = 100
            node.setScale(0.1)
            node.run(group)
        }
        blastEntity.addComponent(spriteComp)
        
        // 2. Logic (BlastComponent)
        let maxRadius: CGFloat = 175.0
        
        let blastComp = BlastComponent(
            center: position,
            maxRadius: maxRadius,
            duration: totalDuration,
            baseDamage: damage, 
            maxKnockback: 400.0 
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
    
    func triggerSmite(from source: GKEntity, damage: Double, textureName: String? = nil) {
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
            
            if let textureName = textureName {
                 // Use Sprite Asset for Smite (Beam)
                 let beam = SKSpriteNode(imageNamed: textureName)
                 beam.position = targetPos
                 beam.anchorPoint = CGPoint(x: 0.5, y: 0.0) // Anchor at bottom
                 beam.size = CGSize(width: 100, height: 600) // Tall beam
                 beam.zPosition = 150
                 scene.addChild(beam)
                 
                 beam.run(SKAction.sequence([
                    SKAction.scaleX(to: 0.1, duration: 0.3), // Narrow out
                    SKAction.fadeOut(withDuration: 0.1),
                    SKAction.removeFromParent()
                 ]))
                 // Optional: Add a flash at the base?
            } else {
                // Fallback to Shape Node
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
            }
            
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
