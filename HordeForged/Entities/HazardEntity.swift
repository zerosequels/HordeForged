import SpriteKit
import GameplayKit

class HazardEntity: GKEntity {
    
    init(position: CGPoint, type: HazardType, value: CGFloat, radius: CGFloat) {
        super.init()
        
        // Visuals
        let node = SKShapeNode(circleOfRadius: radius)
        node.fillColor = type == .slow ? .green : .purple
        node.strokeColor = .clear
        node.alpha = 0.5
        node.position = position
        // Ensure hazards are below players/enemies
        node.zPosition = -1
        
        let label = SKLabelNode(text: "Hazard")
        label.fontSize = 12
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        node.addChild(label)
        
        let spriteComponent = SpriteComponent(node: node)
        addComponent(spriteComponent)
        
        // Hazard Logic
        let hazardComponent = HazardComponent(type: type, value: value)
        addComponent(hazardComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
