import Foundation

let Conviction = AbilityDefinition(
    id: "conviction",
    name: "Conviction",
    description: "Increases max health.",
    iconName: "icon_conviction",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .health, value: 15.0, isMultiplier: false)
    ]
)
