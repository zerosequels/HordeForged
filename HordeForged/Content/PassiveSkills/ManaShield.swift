import Foundation

let ManaShield = AbilityDefinition(
    id: "mana_shield",
    name: "Mana Shield",
    description: "Grants a temporary barrier when collecting experience.",
    iconName: "mana_shield", // Placeholder icon
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .barrierPerExp, value: 2.0, isMultiplier: false) // 2 Barrier per XP point/shard
    ]
)
