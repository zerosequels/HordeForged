import GameplayKit
import SpriteKit

class BlastSystem: GKComponentSystem<GKComponent> {
    
    let scene: SKScene
    
    init(scene: SKScene) {
        self.scene = scene
        super.init(componentClass: BlastComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let gameScene = scene as? GameScene else { return }
        
        // Iterate all Blast Components
        for case let blastComp as BlastComponent in components {
            
            // 1. Update Lifecycle
            blastComp.elapsed += seconds
            
            // Calculate Current Radius
            // Linear expansion
            // t = elapsed / duration
            // radius = maxRadius * t
            // Using a slightly eased expansion might look better, but linear matches the user request "starts out small and expands"
            // Let's stick to linear for now or match the animation curve.
            // SKShapeNode animation was scaleTo(3.5) over duration.
            // If maxRadius matches the visual max, linear is fine.
            let t = CGFloat(min(1.0, blastComp.elapsed / blastComp.duration))
            blastComp.currentRadius = blastComp.maxRadius * t
            
            // 2. Checks Collisions
            // Optimally we'd use a quadtree, but O(N*M) is fine for small N (blasts) and M (enemies)
            let targets = gameScene.gameManager.entities.filter { $0 is EnemyEntity || $0 is DestructibleEntity }
            
            for target in targets {
                // Skip if already hit by this blast
                if blastComp.hitTargets.contains(target) { continue }
                
                guard let targetSprite = target.component(ofType: SpriteComponent.self) else { continue }
                
                // Distance Check
                let dx = targetSprite.node.position.x - blastComp.center.x
                let dy = targetSprite.node.position.y - blastComp.center.y
                let dist = hypot(dx, dy)
                
                // If within CURRENT Expanding Ring
                // effectively: dist < currentRadius
                // But also maybe dist > currentRadius - thickness? 
                // User said "as the circle hits enemies".
                // Simplest interpretation: If it's inside the current radius, it gets hit.
                // Since we track 'hitTargets', once it's inside, it's hit once and done.
                if dist < blastComp.currentRadius {
                    
                    // Mark as hit
                    blastComp.hitTargets.insert(target)
                    
                    // Calculate Falloff
                    // "more knockback the closer to the begining of of the animation"
                    // "damage fall off by the end of the expansion"
                    
                    // Factor inversely related to time/radius
                    // Near center (start): factor = 1.0
                    // Near max radius (end): factor = 0.0 (or small min)
                    
                    // Falloff based on DISTANCE from center vs MAX Radius? 
                    // Or based on TIME?
                    // User said "damage fall off by the end of the expansion".
                    // If an enemy is at the very edge, they get hit at the end of expansion.
                    // If an enemy is close, they get hit early.
                    // So (1 - t) is a good approximation for both time and distance since they remain correlated in an expanding wave.
                    
                    let powerFactor = Double(1.0 - t)
                    
                    // Damage: Base * (0.5 + 0.5 * factor) -> Min 50% damage at edge? Or 0%?
                    // Let's go with min 20% to feel fair.
                    let damageFactor = 0.2 + (0.8 * powerFactor)
                    let finalDamage = Int(blastComp.baseDamage * damageFactor)
                    
                    // Knockback: Max * factor
                    let knockback = blastComp.maxKnockback * CGFloat(powerFactor)
                    
                    // Apply
                    gameScene.gameManager.applyDamage(target: target, amount: finalDamage, sourcePosition: blastComp.center, knockbackPower: knockback)
                    
                    // Debug
                    if gameScene.gameManager.debugSkills {
                        print("[Blast] Hit target at dist \(Int(dist)) (t=\(String(format: "%.2f", t))). Dmg: \(finalDamage), KB: \(Int(knockback))")
                    }
                }
            }
            
            // 3. Cleanup
            if blastComp.elapsed >= blastComp.duration {
                // Identify the entity this component belongs to and remove it
                if let entity = blastComp.entity {
                    gameScene.gameManager.remove(entity)
                }
            }
        }
    }
}
