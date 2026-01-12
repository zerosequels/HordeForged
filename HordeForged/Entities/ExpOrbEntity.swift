import GameplayKit
import SpriteKit

class ExpOrbEntity: GKEntity {
    
    init(value: Int, position: CGPoint) {
        super.init()
        
        // Visuals
        // Visuals
        let texture = SKTexture(imageNamed: "exp_orb")
        let spriteComponent = SpriteComponent(texture: texture)
        spriteComponent.node.size = CGSize(width: 15, height: 15) // Bumped for visibility
        spriteComponent.node.position = position
        addComponent(spriteComponent)
        
        // Value
        let expValueComponent = ExpValueComponent(value: value)
        addComponent(expValueComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
