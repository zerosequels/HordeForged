import Foundation

public enum ItemRarity {
    case common
    case rare
    case legendary
}

public enum StatType: Hashable {
    case attackSpeed
    case movementSpeed
    case damage
    case barrierPerExp
    case health
    case critChance
}

public struct StatModifier: Hashable {
    public let type: StatType
    public let value: Double // e.g. 0.1 for +10%
    public let isMultiplier: Bool // true for multiplier (base * (1+val)), false for additive flat? Usually stack items are additive %
    
    public init(type: StatType, value: Double, isMultiplier: Bool) {
        self.type = type
        self.value = value
        self.isMultiplier = isMultiplier
    }
}

public struct ItemDefinition: Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let rarity: ItemRarity
    public let iconName: String
    public let modifiers: [StatModifier]
    
    public init(id: String, name: String, description: String, rarity: ItemRarity, iconName: String, modifiers: [StatModifier]) {
        self.id = id
        self.name = name
        self.description = description
        self.rarity = rarity
        self.iconName = iconName
        self.modifiers = modifiers
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: ItemDefinition, rhs: ItemDefinition) -> Bool {
        return lhs.id == rhs.id
    }
}
