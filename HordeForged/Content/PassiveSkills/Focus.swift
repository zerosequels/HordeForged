import Foundation

let Focus = AbilityDefinition(
    id: "focus",
    name: "Focus",
    description: "Increases critical hit chance.",
    iconName: "icon_focus",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .critChance, value: 0.05, isMultiplier: false)
    ]
)
