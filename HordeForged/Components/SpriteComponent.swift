import GameplayKit
import SpriteKit

class SpriteComponent: GKComponent {
    let node: SKNode
    
    init(node: SKNode) {
        self.node = node
        super.init()
    }

    init(texture: SKTexture) {
        self.node = SKSpriteNode(texture: texture)
        super.init()
    }
    
    init(color: SKColor, size: CGSize) {
        self.node = SKSpriteNode(color: color, size: size)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
