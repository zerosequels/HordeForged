import GameplayKit
import SpriteKit

class ProjectileEntity: GKEntity {
    
    init(color: UIColor, size: CGSize, velocity: CGVector, damage: Int) {
        super.init()
        
        // Visuals
        // Visuals
        let texture = SKTexture(imageNamed: "projectile_square")
        let spriteComponent = SpriteComponent(texture: texture)
        spriteComponent.node.size = CGSize(width: 16, height: 16)
        spriteComponent.node.color = color // Tint with the passed color
        spriteComponent.node.colorBlendFactor = 1.0 // Fully tint or partial? 
        // Actually, if we want the sprite to show, maybe 0.5?
        // Or if the sprite is white, we can tint it fully.
        // Let's assume sprite is white.
        addComponent(spriteComponent)
        
        // Movement
        let movementComponent = MovementComponent()
        movementComponent.velocity = velocity
        movementComponent.movementSpeed = 300.0 // Projectiles are fast
        addComponent(movementComponent)
        
        // Damage
        let damageComponent = DamageComponent(damage: damage)
        addComponent(damageComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
