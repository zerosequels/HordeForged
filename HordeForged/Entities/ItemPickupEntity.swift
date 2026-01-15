import GameplayKit
import SpriteKit

class ItemPickupEntity: GKEntity {
    
    let itemID: String
    let count: Int
    
    public var hitboxSize: CGSize = .zero
    
    init(itemID: String, count: Int, position: CGPoint) {
        self.itemID = itemID
        self.count = count
        super.init()
        
        // Visuals
        let texture = SKTexture(imageNamed: "pickup_box")
        let node = SKSpriteNode(texture: texture)
        let size = CGSize(width: 75, height: 75) // Captured size
        node.size = size
        node.position = position
        node.zPosition = 0
        
        // Hitbox: 50% of visual size
        self.hitboxSize = CGSize(width: size.width * 0.5, height: size.height * 0.5)
        
        #if DEBUG
        let dBox = SKShapeNode(rectOf: self.hitboxSize)
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
