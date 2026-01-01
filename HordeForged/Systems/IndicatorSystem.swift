import GameplayKit
import SpriteKit

class IndicatorSystem: GKComponentSystem<IndicatorComponent> {
    
    weak var scene: SKScene?
    weak var playerEntity: GKEntity?
    
    private var arrows: [GKEntity: SKShapeNode] = [:]
    
    init(scene: SKScene) {
        self.scene = scene
        super.init(componentClass: IndicatorComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // clean up arrows for removed entities
        var arrowsToRemove: [GKEntity] = []
        for (entity, arrow) in arrows {
            if !components.contains(where: { $0.entity == entity }) {
                arrow.removeFromParent()
                arrowsToRemove.append(entity)
            }
        }
        
        for entity in arrowsToRemove {
            arrows.removeValue(forKey: entity)
        }
        
        guard let player = playerEntity,
              let playerSprite = player.component(ofType: SpriteComponent.self),
              let scene = scene,
              let camera = scene.camera else { return }
        
        for component in components {
            guard let targetEntity = component.entity,
                  let targetSprite = targetEntity.component(ofType: SpriteComponent.self) else { continue }
            
            // Should verify if target is active/enabled?
            // Assuming if it has the component, it's a target.
            
            let targetPos = targetSprite.node.position
            let playerPos = playerSprite.node.position
            
            // Check if on screen
            if scene.intersects(targetSprite.node) {
                // Hide arrow
                arrows[targetEntity]?.isHidden = true
                continue
            }
            
            // Show/Create arrow
            let arrowNode: SKShapeNode
            if let existing = arrows[targetEntity] {
                arrowNode = existing
                arrowNode.isHidden = false
            } else {
                arrowNode = createArrow()
                camera.addChild(arrowNode)
                arrows[targetEntity] = arrowNode
            }
            
            // Calculate Angle
            let dx = targetPos.x - playerPos.x
            let dy = targetPos.y - playerPos.y
            let angle = atan2(dy, dx)
            
            // Position arrow at edge of screen
            let viewportSize = camera.frame.size // Scaled size?
            // Wait, camera.frame is in scene coordinates? camera.overlay?
            // We want it local to camera node (which is 0,0 center).
            // Screen dimensions:
            let width = scene.size.width
            let height = scene.size.height
            
            // Radius from center
            let radius = min(width, height) / 2 - 50 // Padding
            
            let arrowX = cos(angle) * radius
            let arrowY = sin(angle) * radius
            
            arrowNode.position = CGPoint(x: arrowX, y: arrowY)
            arrowNode.zRotation = angle
        }
    }
    
    private func createArrow() -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -10, y: -10))
        path.addLine(to: CGPoint(x: 20, y: 0))
        path.addLine(to: CGPoint(x: -10, y: 10))
        path.closeSubpath()
        
        let arrow = SKShapeNode(path: path)
        arrow.fillColor = .yellow
        arrow.strokeColor = .black
        arrow.zPosition = 500 // Top UI
        return arrow
    }
}
