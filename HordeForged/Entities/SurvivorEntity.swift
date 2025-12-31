import GameplayKit
import SpriteKit

class SurvivorEntity: GKEntity {
    
    // Exposed for easy access (and testing)
    public let spriteComponent: SpriteComponent
    public let movementComponent: MovementComponent
    public let healthComponent: HealthComponent
    public let experienceComponent: ExperienceComponent
    public let staminaComponent: StaminaComponent
    
    init(imageName: String) {
        // Init Components first
        let texture = SKTexture(imageNamed: imageName)
        self.spriteComponent = SpriteComponent(texture: texture)
        self.movementComponent = MovementComponent()
        self.healthComponent = HealthComponent(maxHealth: 50)
        self.experienceComponent = ExperienceComponent()
        self.staminaComponent = StaminaComponent()
        
        super.init()
        
        // Add to entity
        addComponent(spriteComponent)
        addComponent(movementComponent)
        addComponent(healthComponent)
        addComponent(experienceComponent)
        addComponent(staminaComponent)
    }
    
    // For shape-based placeholder (useful if assets are missing)
    init(color: SKColor, size: CGSize) {
        self.spriteComponent = SpriteComponent(color: color, size: size)
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
        // Default Ability: Auto Attack
        if let autoAttack = ProgressionManager.shared.allAbilities.first(where: { $0.id == "auto_attack" }) {
            inventory.addAbility(autoAttack)
        }
        addComponent(inventory)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
