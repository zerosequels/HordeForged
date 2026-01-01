import Foundation

class ProgressionManager {
    static let shared = ProgressionManager()
    
    // Database of all possible content
    var allAbilities: [AbilityDefinition] = []
    var allItems: [ItemDefinition] = []
    
    init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        // --- Abilities ---
        allAbilities = [ArcaneBolt, Thunderclap, Celerity, GiantsStrength]
        
        // --- Items ---
        allItems = [ElixirOfAlacrity, ZephyrEssence, DragonsEye]
    }
    
    func getUpgradeOptions(for inventory: InventoryComponent) -> [AbilityDefinition] {
        // Logic: Return 3 or 4 random options.
        // Rule 1: Can offer new abilities IF slots not full.
        // Rule 2: Can offer upgrades for existing abilities IF level < max.
        // Rule 3: Don't offer duplicate options in same roll.
        
        var validOptions: [AbilityDefinition] = []
        
        // Check Existing for Upgrades
        for instance in inventory.activeAbilities + inventory.passiveAbilities {
            if instance.level < instance.definition.maxLevel {
                validOptions.append(instance.definition)
            }
        }
        
        // Check New for Adds
        // Filter out abilities already owned
        let ownedIDs = Set((inventory.activeAbilities + inventory.passiveAbilities).map { $0.definition.id })
        let potentialNew = allAbilities.filter { !ownedIDs.contains($0.id) }
        
        // Specific slot check
        let canAddActive = inventory.activeAbilities.count < inventory.maxActiveSlots
        let canAddPassive = inventory.passiveAbilities.count < inventory.maxPassiveSlots
        
        for ability in potentialNew {
            if ability.type == .active && canAddActive {
                validOptions.append(ability)
            } else if ability.type == .passive && canAddPassive {
                validOptions.append(ability)
            }
        }
        
        // Shuffle and Pick 4
        let shuffled = validOptions.shuffled()
        return Array(shuffled.prefix(4))
    }
    
    func getRandomItem() -> ItemDefinition {
        return allItems.randomElement()!
    }
}
