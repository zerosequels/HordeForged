import Foundation

let Stability = AbilityDefinition(
    id: "stability",
    name: "Stability",
    description: "Increases max health.",
    iconName: "stability",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .health, value: 15.0, isMultiplier: false)
    ]
)
