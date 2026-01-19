import Foundation

let Combustion = AbilityDefinition(
    id: "combustion",
    name: "Combustion",
    description: "Increases damage.",
    iconName: "combustion",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .damage, value: 0.10, isMultiplier: false)
    ]
)
