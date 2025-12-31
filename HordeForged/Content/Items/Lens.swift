import Foundation

let Lens = ItemDefinition(
    id: "lens",
    name: "Lens",
    description: "+5% Damage",
    rarity: .common,
    modifiers: [
        StatModifier(type: .damage, value: 0.05, isMultiplier: false)
    ]
)
