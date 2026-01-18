import Foundation

let Cruelty = AbilityDefinition(
    id: "cruelty",
    name: "Cruelty",
    description: "Increases damage dealt.",
    iconName: "icon_cruelty",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .damage, value: 0.10, isMultiplier: false)
    ]
)
