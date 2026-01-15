import GameplayKit
import SpriteKit
import UIKit

class ProjectileEntity: GKEntity {
    
    var hitboxSize: CGSize = .zero
    
    init(color: UIColor, size: CGSize, velocity: CGVector, damage: Int, textureName: String? = nil) {
        super.init()
        
        // Visuals
        // Visuals
        // Visuals
        let rawBaseName = textureName ?? "projectile_square"
        print("🔍 [ProjectileEntity] (v2) Attempting to load texture for: \(rawBaseName)")
        
        // 1. Determine Correct Namespace
        // The asset might be under "Projectiles/" namespace.
        // We check raw name first, then namespaced name.
        let candidates = [rawBaseName, "Projectiles/\(rawBaseName)"]
        var resolvedBaseName = rawBaseName
        var foundAny = false
        
        for candidate in candidates {
            // Check for animation frame 0 or static asset
            if let _ = UIImage(named: "\(candidate)_0") {
                resolvedBaseName = candidate
                foundAny = true
                print("✅ Found valid asset base: \(candidate) (animation)")
                break
            }
            if let _ = UIImage(named: candidate) {
                 resolvedBaseName = candidate
                 foundAny = true
                 print("✅ Found valid asset base: \(candidate) (static)")
                 break
            }
        }
        
        if !foundAny {
             print("❌ Could not find asset for '\(rawBaseName)' or 'Projectiles/\(rawBaseName)'")
        }
        
        // 2. Load Textures using resolved name
        var initialTexture: SKTexture
        var action: SKAction?
        var textures: [SKTexture] = []
        
        for i in 0...7 { // Support up to 8 frames
            let name = "\(resolvedBaseName)_\(i)"
            
            // Debug Check
            if let _ = UIImage(named: name) {
                // print("✅ Found frame: \(name)") // Reduce spam
                let texture = SKTexture(imageNamed: name)
                textures.append(texture)
            }
        }
        
        if textures.isEmpty {
            // Static fallback
            if let _ = UIImage(named: resolvedBaseName) {
                // print("✅ Found static asset: \(resolvedBaseName)")
            } else {
                 // Already logged failure above
            }
        }
        
        // 3. Set Initial Texture
        if let firstTex = textures.first {
             initialTexture = firstTex
        } else {
             // Fallback
             initialTexture = SKTexture(imageNamed: "\(resolvedBaseName)_0")
        }
        
        // Create Animation Action
        if !textures.isEmpty {
            action = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.1))
        }
        
        // Hitbox
        // User requested 25% of the visual size (previously 50%)
        self.hitboxSize = CGSize(width: size.width * 0.25, height: size.height * 0.25)
        
        let spriteComponent = SpriteComponent(texture: initialTexture)
        if let spriteNode = spriteComponent.node as? SKSpriteNode {
            spriteNode.size = size
            spriteNode.color = color 
            spriteNode.colorBlendFactor = 0.0 // Don't tint if texture is used
            
            if let anim = action {
                spriteNode.run(anim)
            }
            
            #if DEBUG
            // Debug Hitbox Visualization
            let hitboxNode = SKShapeNode(rectOf: self.hitboxSize)
            hitboxNode.strokeColor = .red
            hitboxNode.lineWidth = 1.0
            hitboxNode.fillColor = .clear
            hitboxNode.zPosition = 100 // High zPosition to ensure visibility
            spriteNode.addChild(hitboxNode)
            #endif
        } 
        // Actually, if we want the sprite to show, maybe 0.5?
        // Or if the sprite is white, we can tint it fully.
        // Let's assume sprite is white.
        addComponent(spriteComponent)
        
        // Movement
        let movementComponent = MovementComponent()
        movementComponent.velocity = velocity
        movementComponent.movementSpeed = 300.0 // Projectiles are fast
        addComponent(movementComponent)
        
        // Damage
        let damageComponent = DamageComponent(damage: damage)
        addComponent(damageComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
