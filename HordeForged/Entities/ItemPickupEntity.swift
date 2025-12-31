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
        let node = SKShapeNode(rectOf: CGSize(width: 20, height: 20), cornerRadius: 4)
        node.fillColor = .black
        node.strokeColor = .yellow // Legendary-ish
        node.lineWidth = 2
        node.position = position
        node.zPosition = 0
        
        // Label
        if let def = ProgressionManager.shared.allItems.first(where: { $0.id == itemID }) {
             let label = SKLabelNode(text: def.name)
             label.fontSize = 8
             label.fontColor = .white
             label.position = CGPoint(x: 0, y: 15)
             node.addChild(label)
        }
        
        let spriteComponent = SpriteComponent(node: node)
        addComponent(spriteComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
