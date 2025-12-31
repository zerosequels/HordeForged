import GameplayKit
import SpriteKit

class EnemyMovementSystem: GKComponentSystem<GKComponent> {
    
    let scene: SKScene
    weak var playerEntity: GKEntity?
    
    // Config
    let enemySpeed: CGFloat = 40.0
    
    init(scene: SKScene) {
        self.scene = scene
        super.init(componentClass: MovementComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let player = playerEntity,
              let playerSprite = player.component(ofType: SpriteComponent.self) else { return }
        
        // We iterate components, but we need the entity to get the sprite for position comparisons
        for component in components {
            guard let enemyMovement = component as? MovementComponent,
                  let enemyEntity = enemyMovement.entity,
                  let enemySprite = enemyEntity.component(ofType: SpriteComponent.self) else { continue }
            
            // Validate it's an enemy (though we only added enemies to this system hopefully, checking type is safer if mixed)
            // But usually we just ensure we only add EnemyEntities to this system in GameManager.
            // Let's assume for now any MovementComponent in this system belongs to something that should chase.
            
            let dx = playerSprite.node.position.x - enemySprite.node.position.x
            let dy = playerSprite.node.position.y - enemySprite.node.position.y
            
            // Normalize
            let distance = sqrt(dx*dx + dy*dy)
            if distance > 1.0 { // Avoid jitter
                let ndx = dx / distance
                let ndy = dy / distance
                
                // Set Velocity
                // Note: MovementComponent expects a normalized velocity vector (mostly) and multiplies by speed.
                // Our EnemyMovementSystem dictates the direction.
                
                // Actually, let's look at MovementComponent. It multiplies velocity * movementSpeed * dt.
                // So we set velocity to normalized vector.
                enemyMovement.velocity = CGVector(dx: ndx, dy: ndy)
                
                // Override speed if needed, or rely on component's set speed. 
                // Let's rely on component default, update it here if variable.
                enemyMovement.movementSpeed = enemySpeed
            } else {
                enemyMovement.velocity = .zero
            }
        }
    }
}
