import Foundation

enum ItemRarity {
    case common
    case rare
    case legendary
}

enum StatType {
    case attackSpeed
    case movementSpeed
    case damage
    case health
    case critChance
}

struct StatModifier {
    let type: StatType
    let value: Double // e.g. 0.1 for +10%
    let isMultiplier: Bool // true for multiplier (base * (1+val)), false for additive flat? Usually stack items are additive %
}

struct ItemDefinition: Hashable {
    let id: String
    let name: String
    let description: String
    let rarity: ItemRarity
    let modifiers: [StatModifier]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ItemDefinition, rhs: ItemDefinition) -> Bool {
        return lhs.id == rhs.id
    }
}
