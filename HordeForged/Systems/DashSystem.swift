import GameplayKit
import SpriteKit

class DashSystem: GKComponentSystem<GKComponent> {
    
    // Config
    let dashDuration: TimeInterval = 0.2
    let dashCost: CGFloat = 30.0
    let postDashInvulnerabilityDuration: TimeInterval = 0.5
    
    // Tracking for extended invulnerability
    private var postDashTimers: [GKEntity: TimeInterval] = [:]
    
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
            
            // Reset post-dash timer if it exists (though unexpected while not dashing)
            postDashTimers[entity] = nil
            
            // Visuals (Optional: Fade out)
            if let sprite = entity.component(ofType: SpriteComponent.self) {
                let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.05)
                sprite.node.run(fadeOut)
            }
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // We iterate manually over known dashers to reset state if needed
        
        for component in components {
            guard let movement = component as? MovementComponent,
                  let entity = movement.entity else { continue }
            
            if movement.isDashing {
                // Ensure invulnerability is ON during dash
                 if let health = entity.component(ofType: HealthComponent.self) {
                     health.isInvulnerable = true
                 }
                
                // Set the timer for when dash ends
                postDashTimers[entity] = postDashInvulnerabilityDuration
                
            } else {
                // Dash is NOT active. Check for post-dash timer.
                if var timeRemaining = postDashTimers[entity] {
                    timeRemaining -= seconds
                    
                    if timeRemaining <= 0 {
                        // Timer Expired: Remove Invulnerability
                        postDashTimers.removeValue(forKey: entity)
                        
                        // Restoration check
                        if let health = entity.component(ofType: HealthComponent.self) {
                            // Only turn off if we were the ones keeping it on?
                            // For simplicity, we assume DashSystem owns this flag when active/post-active.
                            health.isInvulnerable = false
                            
                            // Restore Visuals
                            if let sprite = entity.component(ofType: SpriteComponent.self) {
                                 let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                                 sprite.node.run(fadeIn)
                            }
                        }
                    } else {
                        // Timer Still Running: Keep updating
                        postDashTimers[entity] = timeRemaining
                        
                        // Ensure invulnerability stays ON
                        if let health = entity.component(ofType: HealthComponent.self) {
                            health.isInvulnerable = true
                        }
                    }
                } else {
                     // No dash, no timer. Ensure we didn't leave it on by accident?
                     // Rely on the timer expiry to turn it off.
                }
            }
        }
    }
}
