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
        // 1. Basic Auto Attack (Active)
        let autoAttack = AbilityDefinition(id: "auto_attack", name: "Auto Attack", description: "Fires basic projectiles.", type: .active, rarity: .common, maxLevel: 10)
        
        // 2. Radial Blast (Active)
        let radialBlast = AbilityDefinition(id: "radial_blast", name: "Radial Blast", description: "Explosion around player.", type: .active, rarity: .rare, maxLevel: 10)
        
        // 3. Haste (Passive)
        let haste = AbilityDefinition(id: "haste", name: "Haste", description: "Increases movement speed.", type: .passive, rarity: .common, maxLevel: 10)
        
        // 4. Might (Passive)
        let might = AbilityDefinition(id: "might", name: "Might", description: "Increases damage.", type: .passive, rarity: .common, maxLevel: 10)
        
        allAbilities = [autoAttack, radialBlast, haste, might]
        
        // --- Items ---
        let syringe = ItemDefinition(id: "syringe", name: "Syringe", description: "+15% Attack Speed", rarity: .common, modifiers: [StatModifier(type: .attackSpeed, value: 0.15, isMultiplier: false)])
        
        let goatHoof = ItemDefinition(id: "goat_hoof", name: "Goat Hoof", description: "+10% Move Speed", rarity: .common, modifiers: [StatModifier(type: .movementSpeed, value: 0.10, isMultiplier: false)])
        
        let lens = ItemDefinition(id: "lens", name: "Lens", description: "+5% Damage", rarity: .common, modifiers: [StatModifier(type: .damage, value: 0.05, isMultiplier: false)])
        
        allItems = [syringe, goatHoof, lens]
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
