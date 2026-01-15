import SpriteKit
import GameplayKit

class DestructibleEntity: GKEntity {
    
    public var hitboxSize: CGSize = .zero
    
    init(position: CGPoint, lootTable: [LootItem]) {
        super.init()
        
        // Sprite
        let texture = SKTexture(imageNamed: "destructible_crate")
        let node = SKSpriteNode(texture: texture)
        let size = CGSize(width: 96, height: 96) // Captured size
        node.size = size
        node.position = position
        node.zPosition = 10 // Ensure above ground
        
        // Hitbox: 50% of visual size
        self.hitboxSize = CGSize(width: size.width * 0.5, height: size.height * 0.5)
        
        #if DEBUG
        let dBox = SKShapeNode(rectOf: self.hitboxSize)
        dBox.strokeColor = .green
        dBox.lineWidth = 2.0
        dBox.zPosition = 99
        node.addChild(dBox)
        #endif
        
        // Debug Label
        let label = SKLabelNode(text: "Destructible")
        label.fontSize = 12 // Slightly larger
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = 20 // Ensure above sprite
        node.addChild(label)
        let spriteComponent = SpriteComponent(node: node)
        addComponent(spriteComponent)
        
        // Health (1 hit point)
        let healthComponent = HealthComponent(maxHealth: 1)
        addComponent(healthComponent)
        
        // Loot
        let lootComponent = LootComponent(lootTable: lootTable)
        addComponent(lootComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
