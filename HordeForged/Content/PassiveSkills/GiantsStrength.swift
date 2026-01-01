import Foundation

let GiantsStrength = AbilityDefinition(
    id: "giants_strength",
    name: "Giant's Strength",
    description: "Increases damage.",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .damage, value: 0.10, isMultiplier: false)
    ]
)
