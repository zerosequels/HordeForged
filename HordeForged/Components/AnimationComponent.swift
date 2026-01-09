import SpriteKit
import GameplayKit

enum AnimationDirection: String {
    case up, down, left, right
}

enum AnimationState: String {
    case idle, walk, dead
}

class AnimationComponent: GKComponent {
    
    // Config
    private let timePerFrame: TimeInterval = 0.15
    private let atlasName: String
    private let baseName: String
    
    // State
    var currentDirection: AnimationDirection = .down
    var currentState: AnimationState = .idle
    
    private var currentFrameIndex: Int = 0
    private var timeSinceLastFrame: TimeInterval = 0
    
    // Cache
    private var textureCache: [String: SKTexture] = [:]
    
    init(atlasName: String, baseName: String) {
        self.atlasName = atlasName
        self.baseName = baseName
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        // Update Timer
        timeSinceLastFrame += seconds
        
        if timeSinceLastFrame >= timePerFrame {
            timeSinceLastFrame = 0
            advanceFrame()
        }
        
        updateSprite()
    }
    
    private func advanceFrame() {
        // Simple logic: 4 frames for walking (0-3), 1 for idle (0)
        // If we had more complex metadata we could store frame counts per state.
        // For now, assume 4 walk frames.
        
        if currentState == .walk {
            currentFrameIndex = (currentFrameIndex + 1) % 4
        } else {
            currentFrameIndex = 0
        }
    }
    
    private func updateSprite() {
        guard let entity = entity,
              let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
            return
        }
        
        let textureName = resolveTextureName()
        let texture = getTexture(named: textureName)
        
        if let spriteNode = spriteComponent.node as? SKSpriteNode {
            spriteNode.texture = texture
        }
    }
    
    private func resolveTextureName() -> String {
        // Format: survivor_walk_down_0
        return "\(baseName)_\(currentState.rawValue)_\(currentDirection.rawValue)_\(currentFrameIndex)"
    }
    
    private func getTexture(named name: String) -> SKTexture {
        if let cached = textureCache[name] {
            return cached
        }
        
        // Try to load from Atlas first, then global
        let texture: SKTexture
        // Note: SKTextureAtlas(named:) can be expensive if called every frame, 
        // but typically SpriteKit caches atlases internally.
        // However, referencing the texture directly by name usually works if it's in an atlas.
        
        texture = SKTexture(imageNamed: name)
        
        // Simple Filtering for pixel art (avoid blur)
        texture.filteringMode = .nearest
        
        textureCache[name] = texture
        return texture
    }
    
    // Public API to change state
    func setAnimation(state: AnimationState, direction: AnimationDirection) {
        // Only reset frame if state actually changed (to prevent stuttering)
        if currentState != state || currentDirection != direction {
            currentState = state
            currentDirection = direction
            
            // If going to idle, reset to 0 immediately
            if state == .idle {
                currentFrameIndex = 0
                timeSinceLastFrame = 0
                updateSprite() // Update immediately to feel responsive
            }
        }
    }
}
