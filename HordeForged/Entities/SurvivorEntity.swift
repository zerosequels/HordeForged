import GameplayKit
import SpriteKit

class SurvivorEntity: GKEntity {
    
    init(imageName: String) {
        super.init()
        
        // Visual component
        let texture = SKTexture(imageNamed: imageName)
        let spriteComponent = SpriteComponent(texture: texture)
        addComponent(spriteComponent)
        
        // Logic component
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
    }
    
    // For shape-based placeholder (useful if assets are missing)
    init(color: SKColor, size: CGSize) {
        super.init()
        
        let spriteComponent = SpriteComponent(color: color, size: size)
        addComponent(spriteComponent)
        
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
