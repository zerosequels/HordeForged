import Foundation

let Tailwind = AbilityDefinition(
    id: "tailwind",
    name: "Tailwind",
    description: "Increases movement usage and attack speed.",
    iconName: "icon_tailwind",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .movementSpeed, value: 0.05, isMultiplier: false),
        StatModifier(type: .attackSpeed, value: 0.05, isMultiplier: false)
    ]
)
