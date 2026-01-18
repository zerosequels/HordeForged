import Foundation

public enum AbilityType {
    case active
    case passive
}

public enum AbilityRarity {
    case common
    case rare
    case legendary
}

public struct AbilityDefinition: Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let iconName: String
    public let projectileName: String?
    public let projectileRotationOffset: CGFloat // Radians
    public let type: AbilityType
    public let rarity: AbilityRarity
    public let maxLevel: Int
    public let modifiers: [StatModifier]
    public let baseCooldown: TimeInterval // Added
    
    // Base stats or logic identifier could go here
    // For MVP, we might hardcode logic based on ID
    
    public init(id: String, name: String, description: String, iconName: String, projectileName: String? = nil, projectileRotationOffset: CGFloat = 0, type: AbilityType, rarity: AbilityRarity, maxLevel: Int, modifiers: [StatModifier] = [], baseCooldown: TimeInterval = 1.0) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.projectileName = projectileName
        self.projectileRotationOffset = projectileRotationOffset
        self.type = type
        self.rarity = rarity
        self.maxLevel = maxLevel
        self.modifiers = modifiers
        self.baseCooldown = baseCooldown
    }
}

class AbilityInstance {
    let definition: AbilityDefinition
    var level: Int = 1
    var cooldownTimer: TimeInterval = 0
    var baseCooldown: TimeInterval
    
    init(definition: AbilityDefinition) {
        self.definition = definition
        self.baseCooldown = definition.baseCooldown
    }
    
    func upgrade() {
        guard level < definition.maxLevel else { return }
        level += 1
    }
    
    func update(deltaTime: TimeInterval) {
        if cooldownTimer > 0 {
            cooldownTimer -= deltaTime
        }
    }
    
    func canActivate() -> Bool {
        return cooldownTimer <= 0
    }
    
    func activate() {
        cooldownTimer = baseCooldown // Should be modified by stats
        // Actual logic triggering handled by System
    }
}
