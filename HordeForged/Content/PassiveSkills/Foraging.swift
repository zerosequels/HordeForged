import Foundation

let Foraging = AbilityDefinition(
    id: "foraging",
    name: "Foraging",
    description: "Increases movement speed.",
    iconName: "icon_foraging",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .movementSpeed, value: 0.10, isMultiplier: false)
    ]
)
