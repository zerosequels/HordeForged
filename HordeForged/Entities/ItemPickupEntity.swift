import GameplayKit
import SpriteKit

class ItemPickupEntity: GKEntity {
    
    let itemID: String
    let count: Int
    
    init(itemID: String, count: Int, position: CGPoint) {
        self.itemID = itemID
        self.count = count
        super.init()
        
        // Visuals - White Box with Green Stroke for now, or use ItemDefinition name?
        // Let's look up the definition for color/name if possible, but keeping it simple for now.
        // Visuals
        let texture = SKTexture(imageNamed: "pickup_box")
        let node = SKSpriteNode(texture: texture)
        node.size = CGSize(width: 75, height: 75)
        node.position = position
        node.zPosition = 0
        
        #if DEBUG
        let dBox = SKShapeNode(rectOf: node.size)
        dBox.strokeColor = .blue
        dBox.lineWidth = 2.0
        dBox.zPosition = 99
        node.addChild(dBox)
        #endif
        
        // Label
        if let def = ProgressionManager.shared.allItems.first(where: { $0.id == itemID }) {
             let label = SKLabelNode(text: def.name)
             label.fontSize = 8
             label.fontColor = .white
             label.position = CGPoint(x: 0, y: 40)
             node.addChild(label)
        }
        
        let spriteComponent = SpriteComponent(node: node)
        addComponent(spriteComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
