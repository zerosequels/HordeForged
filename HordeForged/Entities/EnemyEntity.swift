import GameplayKit
import SpriteKit

class EnemyEntity: GKEntity {
    
    // Explicit hitbox size (50% of stats.size)
    var hitboxSize: CGSize = .zero
    
    init(type: EnemyType, stage: Int = 0) {
        super.init()
        
        let stats = EnemyConfig.stats(for: type, stage: stage)
        
        // Visuals
        let spriteComponent: SpriteComponent
        if let textureName = stats.textureName {
             // Construct initial frame name: enemy_boss_stage1_walk_down_0
             // Matches split.js output logic
             let initialImage = "\(textureName)_walk_down_0"
             let texture = SKTexture(imageNamed: initialImage)
             // Resize if needed? SpriteComponent(texture:) uses texture size.
             // If we want fixed size, maybe use color/size constructor and set texture?
             // Or update SpriteComponent.
             // But we want to enforce stats.size?
             // SKShapeNode vs SKSpriteNode: existing SpriteComponent uses SKSpriteNode.
             spriteComponent = SpriteComponent(texture: texture)
             spriteComponent.node.xScale = stats.size.width / texture.size().width
             spriteComponent.node.yScale = stats.size.height / texture.size().height
             
        } else {
             spriteComponent = SpriteComponent(color: stats.color, size: stats.size)
        }
        addComponent(spriteComponent)
        
        // Animations
        if let textureName = stats.textureName {
            // "enemy_walker_stage0" -> use atlas "enemy_atlas" or similar?
            // Actually, plan says use textureName as baseName.
            // Assumption: Atlas name "enemies" or "enemy_atlas" contains all? Or separate atlas per enemy?
            // AnimationComponent(atlasName: "enemy_atlas", baseName: textureName)
            // Let's assume a shared atlas "enemy_atlas" for now, or just use loose files if atlas unused.
            // AnimationComponent implementation currently takes atlasName but uses it?
            // Checking AnimationComponent... it takes atlasName but uses imageNamed for loose files if not in atlas?
            // The existing AnimationComponent.getTexture uses SKTexture(imageNamed: name), which works for both loose and atlas (if loaded).
            // Let's use "enemy_atlas" as a convention.
            
            let animationComponent = AnimationComponent(atlasName: "enemy_atlas", baseName: textureName)
            addComponent(animationComponent)
        } else {
            // Fallback dummy
            let animationComponent = AnimationComponent(atlasName: "none", baseName: "none")
            addComponent(animationComponent)
        }
        
        // Health
        let healthComponent = HealthComponent(maxHealth: stats.health)
        addComponent(healthComponent)
        
        // Movement
        let movementComponent = MovementComponent()
        movementComponent.movementSpeed = stats.speed // Set initial speed from stats
        
        // Knockback Resistance Settings
        switch type {
        case .boss:
            movementComponent.knockbackResistance = 1.0 // Immune
        case .brute:
            movementComponent.knockbackResistance = 0.8 // High resistance
        case .elite:
            movementComponent.knockbackResistance = 0.5 // Medium resistance
        default:
            movementComponent.knockbackResistance = 0.0 // Full knockback
        }
        
        addComponent(movementComponent)
        
        // Attack
        let attackComponent = AttackComponent(damage: stats.damage)
        addComponent(attackComponent)
        
        // XP Value (Optional: Add ExpValueComponent if not present, otherwise hardcoded in Orb?)
        // The plan didn't explicitly say to add ExpValue to Enemy, usually it drops Orbs.
        // We'll leave XP logic for Drop/Loot section or handle it in Death logic using stats if needed.
        // For now, let's store the stats or type if needed later? 
        // Or just let the LootComponent handle it? 
        // Existing code: LootLogic was in CollisionSystem/Destructible.
        // Enemies drop XP via... wait, let's check CollisionSystem again? 
        // CollisionSystem checks Health <= 0, but for Enemies it applies Damage. 
        // Where is Enemy Death handled? 
        // GameManager?
        
        // Let's stick to adding components.
        
        // Hitbox: 50% of visual size
        self.hitboxSize = CGSize(width: stats.size.width * 0.5, height: stats.size.height * 0.5)
        
        // --- Health Bar ---
        let barWidth: CGFloat = 40
        let barHeight: CGFloat = 5
        let barOffset = CGPoint(x: 0, y: stats.size.height/2 + 10)
        
        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 1)
        bg.fillColor = .black
        bg.strokeColor = .clear
        bg.position = barOffset
        bg.zPosition = 10
        bg.isHidden = true // Hidden initially
        
        // Fill
        let fillOrigin = CGPoint(x: -barWidth/2, y: -barHeight/2)
        let fill = SKShapeNode(rect: CGRect(origin: fillOrigin, size: CGSize(width: barWidth, height: barHeight)), cornerRadius: 1)
        fill.fillColor = .green
        fill.strokeColor = .clear
        fill.zPosition = 11
        
        bg.addChild(fill)
        spriteComponent.node.addChild(bg)
        
        // Debug Hitbox
        #if DEBUG
        // Note: Adding to spriteComponent.node means it inherits scale.
        // If sprite is scaled, we must adjust.
        // However, stats.size is the target world size.
        // spriteComponent logic: node.xScale = stats.size.width / texture.size().width
        // So the node is scaled to match stats.size.
        // If we add a 100x100 rect to a node scaled to 0.5, the rect draws as 50x50.
        // We want the final drawn size to be hitboxSize (0.5 * stats.size).
        // Since the node is already scaled to stats.size, we want the child rect to be 0.5 * (unscaled texture size)?
        // No, simplest way: The node's coordinate system is 0..1 relative to texture if normalized? No.
        // The node's coordinate system is in pixels of the texture.
        // If we want the result to be 0.5 of final size, we can just make the debug rect 0.5 of the texture size.
        // Because (0.5 * TexSize) * Scale = 0.5 * (TexSize * Scale) = 0.5 * StatsSize.
        
        let textureSize = spriteComponent.node.frame.size // This is the scaled size in parent? No, .frame is in parent coords.
        // We can't easily access texture size here without casting or assumption.
        // But we know we want the debug box to visually align with hitboxSize.
        // If we attach to spriteNode, we work in texture coordinates. 
        // rectOf: hitboxSize will be Scaled by spriteNode.scale.
        // hitboxSize = 0.5 * stats.size.
        // spriteNode.scale = stats.size / texture.size.
        // If we use rectOf: hitboxSize, actual size = (0.5 * stats.size) * (stats.size / texture.size). This is wrong.
        // We want ActualSize = 0.5 * stats.size.
        // So rectOf * Scale = 0.5 * stats.size
        // rectOf * (stats.size / texture.size) = 0.5 * stats.size
        // rectOf = 0.5 * texture.size.
        // So we should use the texture's size for the rect passed to the child.
        
        let debugSize: CGSize
        if let spriteNode = spriteComponent.node as? SKSpriteNode, let tex = spriteNode.texture {
             debugSize = CGSize(width: tex.size().width * 0.5, height: tex.size().height * 0.5)
        } else {
             debugSize = hitboxSize // Fallback for color sprites (scale 1.0)
        }
        
        let dBox = SKShapeNode(rectOf: debugSize)
        dBox.strokeColor = .green
        dBox.lineWidth = 2.0 // This will also be scaled!
        dBox.zPosition = 99
        spriteComponent.node.addChild(dBox)
        #endif
        
        // Health Callback
        healthComponent.onHealthChanged = { [weak bg, weak fill] current, maxHP in
            guard let bg = bg, let fill = fill else { return }
            
            if bg.isHidden {
                bg.isHidden = false
            }
            
            let pct = CGFloat(current) / CGFloat(maxHP)
            let clamped = max(0.0, min(1.0, pct))
            
            fill.xScale = clamped
            
            if clamped < 0.2 {
                fill.fillColor = .red
            } else if clamped < 0.5 {
                fill.fillColor = .yellow
            } else {
                fill.fillColor = .green
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        // Sync Animation with Movement
        guard let movementComponent = component(ofType: MovementComponent.self),
              let animationComponent = component(ofType: AnimationComponent.self) else {
            return
        }
        
        let velocity = movementComponent.velocity
        
        // Determine State
        if velocity.dx == 0 && velocity.dy == 0 {
            // Idle
            animationComponent.setAnimation(state: .idle, direction: animationComponent.currentDirection)
        } else {
            // Moving
            var direction: AnimationDirection = animationComponent.currentDirection
            
            // Simple 4-way logic
            if abs(velocity.dx) > abs(velocity.dy) {
                // Horizontal Dominant
                direction = velocity.dx > 0 ? .right : .left
            } else {
                // Vertical Dominant
                direction = velocity.dy > 0 ? .up : .down
            }
            
            animationComponent.setAnimation(state: .walk, direction: direction)
        }
    }
}
