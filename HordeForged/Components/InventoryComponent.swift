import GameplayKit

class InventoryComponent: GKComponent {
    
    // Limits
    let maxActiveSlots = 4
    let maxPassiveSlots = 4
    
    // Storage
    var activeAbilities: [AbilityInstance] = []
    var passiveAbilities: [AbilityInstance] = []
    var items: [ItemDefinition: Int] = [:] // Item -> Count
    
    // Cached Stats (recompute when inventory changes)
    var attackSpeedMultiplier: Double = 1.0
    var movementSpeedMultiplier: Double = 1.0
    var damageMultiplier: Double = 1.0
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Abilities
    
    func displayAbilities() {
        print("Active Abilities:")
        for ability in activeAbilities {
            print("- \(ability.definition.name) (Lv \(ability.level))")
        }
    }

    func canAddAbility(_ definition: AbilityDefinition) -> Bool {
        // specific logic: checks checks if slot available
         if definition.type == .active {
            return activeAbilities.count < maxActiveSlots
        } else {
            return passiveAbilities.count < maxPassiveSlots
        }
    }
    
    func hasAbility(_ definition: AbilityDefinition) -> AbilityInstance? {
        let list = definition.type == .active ? activeAbilities : passiveAbilities
        return list.first { $0.definition.id == definition.id }
    }
    
    func addAbility(_ definition: AbilityDefinition) {
        if let existing = hasAbility(definition) {
            existing.upgrade()
            print("Upgraded \(definition.name) to Level \(existing.level)")
        } else {
            if canAddAbility(definition) {
                let newInstance = AbilityInstance(definition: definition)
                if definition.type == .active {
                    activeAbilities.append(newInstance)
                } else {
                    passiveAbilities.append(newInstance)
                }
                print("Added Ability: \(definition.name)")
            } else {
                print("Inventory Full! Cannot add \(definition.name)")
            }
        }
    }
    
    // MARK: - Items
    
    func addItem(_ item: ItemDefinition, count: Int = 1) {
        items[item, default: 0] += count
        print("Added Item: \(item.name) x\(count) (Total: \(items[item]!))")
        recalculateStats()
    }
    
    private func recalculateStats() {
        // Reset
        attackSpeedMultiplier = 1.0
        movementSpeedMultiplier = 1.0
        damageMultiplier = 1.0
        
        for (item, count) in items {
            let stackCount = Double(count)
            applyModifiers(item.modifiers, stackCount: stackCount)
        }
        
        // Add Passive Abilities
        for ability in passiveAbilities {
            // Stack count = level? Or just 1 set of modifiers?
            // Usually leveling up increases the modifier value in the definition, or we scale it.
            // For MVP, definitions are static per level instance, but here definitions are shared.
            // If ability scales with level, the Definition should handle it or we use a formula.
            // Current assumption: Definition has base modifier. Level scaling isn't implemented in modifiers yet.
            // Let's assume 1 stack per level.
            let stackCount = Double(ability.level)
            applyModifiers(ability.definition.modifiers, stackCount: stackCount)
        }
        
        print("Stats Updated: AtkSpd \(attackSpeedMultiplier), MoveSpd \(movementSpeedMultiplier), Dmg \(damageMultiplier)")
    }
    
    private func applyModifiers(_ modifiers: [StatModifier], stackCount: Double) {
        for mod in modifiers {
            switch mod.type {
            case .attackSpeed:
                attackSpeedMultiplier += mod.value * stackCount
            case .movementSpeed:
                movementSpeedMultiplier += mod.value * stackCount
            case .damage:
                damageMultiplier += mod.value * stackCount
            default:
                break
            }
        }
    }
    
    // MARK: - Update
    override func update(deltaTime seconds: TimeInterval) {
        for ability in activeAbilities {
            ability.update(deltaTime: seconds)
        }
    }
}
