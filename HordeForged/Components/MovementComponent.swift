import GameplayKit
import SpriteKit

class MovementComponent: GKComponent {
    var velocity: CGVector = .zero
    var movementSpeed: CGFloat = 150.0
    
    // Updates the entity's position based on velocity * dt
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard let entity = entity,
              let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
            return
        }
        
        let amountToMove = velocity.normalized() * movementSpeed * CGFloat(seconds)
        let newPosition = CGPoint(x: spriteComponent.node.position.x + amountToMove.dx,
                                  y: spriteComponent.node.position.y + amountToMove.dy)
        
        spriteComponent.node.position = newPosition
    }
}

extension CGVector {
    func normalized() -> CGVector {
        let length = sqrt(dx*dx + dy*dy)
        return length > 0 ? CGVector(dx: dx/length, dy: dy/length) : .zero
    }
    
    static func * (vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }
}
