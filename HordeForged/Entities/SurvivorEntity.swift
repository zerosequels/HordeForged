import GameplayKit
import SpriteKit

class SurvivorEntity: GKEntity {
    
    // Exposed for easy access (and testing)
    public let spriteComponent: SpriteComponent
    public let movementComponent: MovementComponent
    public let healthComponent: HealthComponent
    public let experienceComponent: ExperienceComponent
    public let animationComponent: AnimationComponent
    
    init(imageName: String) {
        // Init Components first
        let texture = SKTexture(imageNamed: imageName)
        self.spriteComponent = SpriteComponent(texture: texture)
        // Hardcoded for now based on Guide: Atlas 'survivor_atlas', Base 'survivor'
        self.animationComponent = AnimationComponent(atlasName: "survivor_atlas", baseName: "survivor")
        
        self.movementComponent = MovementComponent()
        self.healthComponent = HealthComponent(maxHealth: 50)
        self.experienceComponent = ExperienceComponent()
        self.staminaComponent = StaminaComponent()
        
        super.init()
        
        // Add to entity
        addComponent(spriteComponent)
        // Add animation before movement? Order usually doesn't matter for update, but good for rendering.
        addComponent(animationComponent)
        addComponent(movementComponent)
        addComponent(healthComponent)
        addComponent(experienceComponent)
        addComponent(staminaComponent)
    }
    
    // For shape-based placeholder (useful if assets are missing)
    init(color: SKColor, size: CGSize) {
        self.spriteComponent = SpriteComponent(color: color, size: size)
        // No animations for shape placeholder
        self.animationComponent = AnimationComponent(atlasName: "none", baseName: "none") // Dummy
        
        self.movementComponent = MovementComponent()
        self.healthComponent = HealthComponent(maxHealth: 50)
        self.experienceComponent = ExperienceComponent()
        self.staminaComponent = StaminaComponent()
        
        super.init()
        
        addComponent(spriteComponent)
        addComponent(movementComponent)
        addComponent(healthComponent)
        addComponent(experienceComponent)
        addComponent(staminaComponent)
        
        let inventory = InventoryComponent()
        // Default Ability: Arcane Bolt
        inventory.addAbility(ArcaneBolt)
        addComponent(inventory)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        // Sync Animation with Movement
        let velocity = movementComponent.velocity
        
        // Determine State
        if velocity.dx == 0 && velocity.dy == 0 {
            // Idle - Keep looking in last direction? 
            // For now, let's just keep the current direction but switch state to idle.
            animationComponent.setAnimation(state: .idle, direction: animationComponent.currentDirection)
        } else {
            // Moving
            var direction: AnimationDirection = animationComponent.currentDirection
            
            // Simple 4-way logic
            if abs(velocity.dx) > abs(velocity.dy) {
                // Horizontal Dominant
                direction = velocity.dx > 0 ? .right : .left
            } else {
                // Vertical Dominant
                direction = velocity.dy > 0 ? .up : .down
            }
            
            animationComponent.setAnimation(state: .walk, direction: direction)
        }
    }
}
