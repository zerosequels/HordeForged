import GameplayKit
import SpriteKit

class MovementComponent: GKComponent {
    var velocity: CGVector = .zero
    var movementSpeed: CGFloat = 150.0
    var speedModifier: CGFloat = 1.0
    var lastDirection: CGVector = CGVector(dx: 1, dy: 0) // Default Right
    
    // Updates the entity's position based on velocity * dt
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard let entity = entity,
              let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
            return
        }
        
        
        // Check for Inventory Modifiers
        var currentSpeedModifier = speedModifier
        if let inventory = entity.component(ofType: InventoryComponent.self) {
            currentSpeedModifier *= CGFloat(inventory.movementSpeedMultiplier)
        }
        
        let amountToMove = velocity * movementSpeed * currentSpeedModifier * CGFloat(seconds)
        let newPosition = CGPoint(x: spriteComponent.node.position.x + amountToMove.dx,
                                  y: spriteComponent.node.position.y + amountToMove.dy)
        
        spriteComponent.node.position = newPosition
        
        // Update last direction logic
        if velocity != .zero {
            lastDirection = velocity.normalized()
        }
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
