import GameplayKit
import SpriteKit

class DashSystem: GKComponentSystem<GKComponent> {
    
    // Config
    let dashDuration: TimeInterval = 0.2
    let dashCost: CGFloat = 30.0
    
    override init() {
        super.init(componentClass: MovementComponent.self)
    }
    
    func attemptDash(for entity: GKEntity, direction: CGVector) {
        guard let stamina = entity.component(ofType: StaminaComponent.self),
              let movement = entity.component(ofType: MovementComponent.self) else {
            return
        }
        
        // Cooldown/State Check
        if movement.isDashing { return }
        
        // Stamina Check
        if stamina.consume(amount: dashCost) {
            // Trigger Dash
            movement.startDash(direction: direction, duration: dashDuration)
            
            // Invulnerability
            if let health = entity.component(ofType: HealthComponent.self) {
                health.isInvulnerable = true
            }
            
            // Visuals (Optional: Fade out)
            if let sprite = entity.component(ofType: SpriteComponent.self) {
                let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.05)
                sprite.node.run(fadeOut)
            }
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // We iterate manually over known dashers to reset state if needed
        // Or actually, since MovementComponent handles the movement update, 
        // we just need to check if dash ended to reset invulnerability/visuals.
        
        for component in components {
            guard let movement = component as? MovementComponent,
                  let entity = movement.entity else { continue }
            
            // If dash just ended (we need to detect edge case or just check matching state)
            // MovementComponent sets isDashing to false when done.
            // But we need to reset invulnerability.
            
            if !movement.isDashing {
                // Restoration check
                if let health = entity.component(ofType: HealthComponent.self), health.isInvulnerable {
                    // Turn off invulnerability
                    health.isInvulnerable = false
                    
                    // Restore Visuals
                    if let sprite = entity.component(ofType: SpriteComponent.self) {
                         let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                         sprite.node.run(fadeIn)
                    }
                }
            }
        }
    }
}
