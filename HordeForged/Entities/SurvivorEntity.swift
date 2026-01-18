import GameplayKit
import SpriteKit

class SurvivorEntity: GKEntity {
    
    // Exposed for easy access (and testing)
    public let spriteComponent: SpriteComponent
    public let movementComponent: MovementComponent
    public let healthComponent: HealthComponent
    public let experienceComponent: ExperienceComponent
    public let animationComponent: AnimationComponent

    public let staminaComponent: StaminaComponent
    
    #if DEBUG
    public var debugDirectionLine: SKShapeNode?
    #endif
    
    // Default to paladin for now, but allow passing others
    init(definition: SurvivorDefinition) {
        // Init Components first
        // Construct initial frame name: survivor_paladin_walk_down_0
        let initialImage = "\(definition.characterName)_walk_down_0"
        let texture = SKTexture(imageNamed: initialImage)
        
        self.spriteComponent = SpriteComponent(texture: texture)
        // Atlas 'survivor_atlas', Base Name = characterName (e.g. 'survivor_paladin')
        self.animationComponent = AnimationComponent(atlasName: "survivor_atlas", baseName: definition.characterName)
        
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
        
        let inventory = InventoryComponent()
        // Add Starting Skills
        inventory.addAbility(definition.startingActiveSkill)
        inventory.addAbility(definition.startingPassiveSkill)
        addComponent(inventory)
    }
    
    // Convenience init for legacy string support (maps to Paladin default or basic lookup)
    convenience init(characterName: String = "survivor_paladin") {
        // Simple fallback map for now, or just default to Paladin
        // Ideally we check definitions
        let def = AllSurvivors.first(where: { $0.characterName == characterName }) ?? PaladinSurvivor
        self.init(definition: def)
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
