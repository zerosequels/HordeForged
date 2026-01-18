import Foundation

let Vampirism = AbilityDefinition(
    id: "vampirism",
    name: "Vampirism",
    description: "Increases max health.",
    iconName: "icon_vampirism",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .health, value: 10.0, isMultiplier: false)
    ]
)
