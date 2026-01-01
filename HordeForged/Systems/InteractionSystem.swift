import GameplayKit
import SpriteKit

class InteractionSystem: GKComponentSystem<InteractionComponent> {
    
    weak var playerEntity: GKEntity?
    weak var scene: SKScene? // For button UI or touch checks
    
    // For now, let's use a proximity auto-interact or simple check
    // If we want a button, we need UI.
    // Let's implement Proximity -> Show Button -> Tap Button -> Interact.
    
    // Quick solution: If player is close, simple visual Feedback, and if they TAP the core, it triggers.
    
    override func update(deltaTime seconds: TimeInterval) {
        // Logic to enable/disable based on Game State (e.g. Boss Death) handled in GameManager usually.
        // Here we just check proximity for potential UI feedback.
    }
    
    func tryInteract(at point: CGPoint) {
        // Find entities at point?
        // Or check all components?
        for component in components {
            guard let entity = component.entity,
                  let spriteComp = entity.component(ofType: SpriteComponent.self) else { continue }
            
            // Check if point is inside node
            if spriteComp.node.contains(point) {
                // Check distance to player
                guard let player = playerEntity,
                      let playerSprite = player.component(ofType: SpriteComponent.self) else { return }
                
                let dist = hypot(spriteComp.node.position.x - playerSprite.node.position.x,
                                 spriteComp.node.position.y - playerSprite.node.position.y)
                
                if dist <= component.interactionRadius {
                    if component.isInteractable {
                        component.onInteract?()
                    } else {
                        print("Target is not interactable yet.")
                    }
                } else {
                    print("Too far to interact.")
                }
            }
        }
    }
}
