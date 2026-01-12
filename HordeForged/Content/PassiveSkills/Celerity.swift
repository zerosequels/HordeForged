import Foundation

let Celerity = AbilityDefinition(
    id: "celerity",
    name: "Celerity",
    description: "Increases movement speed.",
    iconName: "celerity",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .movementSpeed, value: 0.10, isMultiplier: false)
    ]
)
