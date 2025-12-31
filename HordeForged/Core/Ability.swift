import Foundation

enum AbilityType {
    case active
    case passive
}

enum AbilityRarity {
    case common
    case rare
    case legendary
}

struct AbilityDefinition: Hashable {
    let id: String
    let name: String
    let description: String
    let type: AbilityType
    let rarity: AbilityRarity
    let maxLevel: Int
    
    // Base stats or logic identifier could go here
    // For MVP, we might hardcode logic based on ID
}

class AbilityInstance {
    let definition: AbilityDefinition
    var level: Int = 1
    var cooldownTimer: TimeInterval = 0
    var baseCooldown: TimeInterval = 1.0 // Default
    
    init(definition: AbilityDefinition) {
        self.definition = definition
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
