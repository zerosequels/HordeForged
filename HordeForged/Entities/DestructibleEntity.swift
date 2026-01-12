import SpriteKit
import GameplayKit

class DestructibleEntity: GKEntity {
    
    init(position: CGPoint, lootTable: [LootItem]) {
        super.init()
        
        // Sprite
        // Sprite
        let texture = SKTexture(imageNamed: "destructible_crate")
        let node = SKSpriteNode(texture: texture)
        node.size = CGSize(width: 30, height: 30)
        node.position = position
        
        // Debug Label
        let label = SKLabelNode(text: "Destructible")
        label.fontSize = 10
        label.fontColor = .white
        label.verticalAlignmentMode = .center
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
