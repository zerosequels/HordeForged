import GameplayKit
import SpriteKit

class EnemyEntity: GKEntity {
    
    init(type: EnemyType, stage: Int = 0) {
        super.init()
        
        let stats = EnemyConfig.stats(for: type, stage: stage)
        
        // Visuals
        let spriteComponent: SpriteComponent
        if let textureName = stats.textureName {
             // Assuming texture exists, use SKTexture
             let texture = SKTexture(imageNamed: textureName)
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
