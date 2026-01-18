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
    
    // Knockback
    var knockbackVelocity: CGVector = .zero
    let knockbackDecay: CGFloat = 5.0 // Damping factor (Drag)
    var knockbackResistance: CGFloat = 0.0 // 0.0 = full knockback, 1.0 = immune
    
    
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
        
        // Handle Knockback
        var knockbackMove: CGVector = .zero
        if knockbackVelocity != .zero {
            knockbackMove = knockbackVelocity * CGFloat(seconds)
            
            // Apply Drag/Decay
            // Simple exponential decay: v = v * e^(-decay * dt) or linear friction
            // Let's use linear friction-like reduction for stopping
            let drag = knockbackDecay * CGFloat(seconds)
            
            // Reduce X
            if knockbackVelocity.dx > 0 {
                knockbackVelocity.dx = max(0, knockbackVelocity.dx - knockbackVelocity.dx * drag)
            } else if knockbackVelocity.dx < 0 {
                knockbackVelocity.dx = min(0, knockbackVelocity.dx - knockbackVelocity.dx * drag)
            }
            // Reduce Y
            if knockbackVelocity.dy > 0 {
                knockbackVelocity.dy = max(0, knockbackVelocity.dy - knockbackVelocity.dy * drag)
            } else if knockbackVelocity.dy < 0 {
                knockbackVelocity.dy = min(0, knockbackVelocity.dy - knockbackVelocity.dy * drag)
            }
            
            // Snap to zero if very small
            if abs(knockbackVelocity.dx) < 10 && abs(knockbackVelocity.dy) < 10 {
                knockbackVelocity = .zero
            }
        }
        
        
        // Check for Inventory Modifiers
        var currentSpeedModifier = speedModifier
        if let inventory = entity.component(ofType: InventoryComponent.self) {
            currentSpeedModifier *= CGFloat(inventory.movementSpeedMultiplier)
        }
        
        let amountToMove = velocity * movementSpeed * currentSpeedModifier * CGFloat(seconds)
        let finalMove = CGVector(dx: amountToMove.dx + knockbackMove.dx, dy: amountToMove.dy + knockbackMove.dy)
        
        let newPosition = CGPoint(x: spriteComponent.node.position.x + finalMove.dx,
                                  y: spriteComponent.node.position.y + finalMove.dy)
        
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
