import GameplayKit
import SpriteKit

class ExpOrbEntity: GKEntity {
    
    init(value: Int, position: CGPoint) {
        super.init()
        
        // Visuals
        let spriteComponent = SpriteComponent(color: .green, size: CGSize(width: 10, height: 10))
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
