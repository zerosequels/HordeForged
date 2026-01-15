import GameplayKit
import SpriteKit

class ExpOrbEntity: GKEntity {
    
    init(value: Int, position: CGPoint) {
        super.init()
        
        // Visuals
        // Visuals
        let texture = SKTexture(imageNamed: "exp_orb")
        let spriteComponent = SpriteComponent(texture: texture)
        if let spriteNode = spriteComponent.node as? SKSpriteNode {
            spriteNode.size = CGSize(width: 25, height: 25) // Bumped for visibility
        }
        spriteComponent.node.position = position
        
        #if DEBUG
        if let spriteNode = spriteComponent.node as? SKSpriteNode {
             let dCircle = SKShapeNode(circleOfRadius: spriteNode.size.width / 2) // Radius
             dCircle.strokeColor = .blue
             dCircle.lineWidth = 1.0
             dCircle.zPosition = 99
             spriteNode.addChild(dCircle)
        }
        #endif
        
        addComponent(spriteComponent)
        
        // Value
        let expValueComponent = ExpValueComponent(value: value)
        addComponent(expValueComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
