import GameplayKit
import SpriteKit

class MovementComponent: GKComponent {
    var velocity: CGVector = .zero
    var movementSpeed: CGFloat = 150.0
    var speedModifier: CGFloat = 1.0
    var lastDirection: CGVector = CGVector(dx: 1, dy: 0) // Default Right
    
    // Dash Properties
    var isDashing: Bool = false
    var dashSpeed: CGFloat = 800.0 // Fast burst
    var dashTimeRemaining: TimeInterval = 0
    var dashDirection: CGVector = .zero
    
    func startDash(direction: CGVector, duration: TimeInterval) {
        isDashing = true
        dashTimeRemaining = duration
        dashDirection = direction.normalized()
    }
    
    // Updates the entity's position based on velocity * dt
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard let entity = entity,
              let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
            return
        }
        
        // Handle Dash
        if isDashing {
            dashTimeRemaining -= seconds
            if dashTimeRemaining <= 0 {
                isDashing = false
            } else {
                // Dash Movement
                let amountToMove = dashDirection * dashSpeed * CGFloat(seconds)
                let newPosition = CGPoint(x: spriteComponent.node.position.x + amountToMove.dx,
                                          y: spriteComponent.node.position.y + amountToMove.dy)
                spriteComponent.node.position = newPosition
                return // Skip normal movement
            }
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
