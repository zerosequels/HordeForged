import SpriteKit
import GameplayKit

class MiniMapNode: SKShapeNode {
    
    weak var gameScene: GameScene?
    var playerIndicator: SKShapeNode!
    var entitiesNode: SKNode!
    
    // Config
    let mapSize: CGFloat = 100.0
    let mapScale: CGFloat = 0.1 // 10% scale
    
    init(scene: GameScene, size: CGFloat = 100.0) {
        super.init()
        self.gameScene = scene
        
        // Background
        let rect = CGRect(x: -size/2, y: -size/2, width: size, height: size)
        self.path = CGPath(rect: rect, transform: nil)
        self.fillColor = SKColor.black.withAlphaComponent(0.5)
        self.strokeColor = .white
        self.lineWidth = 1.0
        
        self.entitiesNode = SKNode()
        addChild(entitiesNode)
        
        // Player Indicator (Center)
        playerIndicator = SKShapeNode(circleOfRadius: 3)
        playerIndicator.fillColor = .cyan
        playerIndicator.strokeColor = .white
        addChild(playerIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        guard let scene = gameScene,
              let player = scene.player,
              let playerSprite = player.component(ofType: SpriteComponent.self) else { return }
        
        entitiesNode.removeAllChildren()
        
        let playerPos = playerSprite.node.position
        
        // Scan entities
        for entity in scene.gameManager.entities {
            // Skip player
            if entity === player { continue }
            
            guard let sprite = entity.component(ofType: SpriteComponent.self) else { continue }
            
            let pos = sprite.node.position
            let relativePos = pos - playerPos
            
            // Check if within Radar Range (Optional, or clamp to edge)
            // Let's scale it down
            let scaledPos = relativePos * mapScale
            
            // Clamp to map bounds
            let halfSize = mapSize / 2
            
            // Simple Dot
            let dot = SKShapeNode(circleOfRadius: 2)
            dot.lineWidth = 0
            
            // Determine Color/Type
            if entity is EnemyEntity {
                dot.fillColor = .red
            } else if entity is CrucibleCoreEntity {
                dot.fillColor = .green
                dot.setScale(2.0) // Bigger
            } else if entity is ItemPickupEntity { // Check for real item entity
                dot.fillColor = .yellow
            } else if entity is DestructibleEntity {
                dot.fillColor = .white // Pot
            } else {
                continue // Skip others
            }
            
            // Bounds Check for Clamping (Radar Style)
            var finalPos = scaledPos
            if abs(finalPos.x) > halfSize || abs(finalPos.y) > halfSize {
                // Determine angle
                let angle = atan2(finalPos.y, finalPos.x)
                // Clamp to edge (circle or square?) Square is better for map frame
                // But circle calculation:
                // finalPos.x = width/2 * cos(angle)
                // finalPos.y = height/2 * sin(angle) 
                
                // Let's strict clamp to square
                if finalPos.x > halfSize { finalPos.x = halfSize }
                if finalPos.x < -halfSize { finalPos.x = -halfSize }
                if finalPos.y > halfSize { finalPos.y = halfSize }
                if finalPos.y < -halfSize { finalPos.y = -halfSize }
            }
             
             dot.position = finalPos
             entitiesNode.addChild(dot)
        }
    }
}

extension CGPoint {
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}
