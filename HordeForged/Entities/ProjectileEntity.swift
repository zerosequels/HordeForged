import GameplayKit
import SpriteKit

class ProjectileEntity: GKEntity {
    
    init(color: UIColor, size: CGSize, velocity: CGVector, damage: Int) {
        super.init()
        
        // Visuals
        let texture = SKTexture(imageNamed: "projectile_square") // Placeholder or generated
        // Fallback to color if texture fails or just use simple generic sprite comp
        let spriteComponent = SpriteComponent(color: color, size: size)
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
