import GameplayKit
import SpriteKit

class EnemyEntity: GKEntity {
    
    init(color: UIColor, size: CGSize, health: Int) {
        super.init()
        
        // Visuals
        let spriteComponent = SpriteComponent(color: color, size: size)
        addComponent(spriteComponent)
        
        // Position - will be set by spawner, but component is needed? 
        // Actually SpriteComponent handles position via its node.
        
        // Health
        let healthComponent = HealthComponent(maxHealth: health)
        addComponent(healthComponent)
        
        // Movement
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
