import Foundation

let Syringe = ItemDefinition(
    id: "syringe",
    name: "Syringe",
    description: "+15% Attack Speed",
    rarity: .common,
    modifiers: [
        StatModifier(type: .attackSpeed, value: 0.15, isMultiplier: false)
    ]
)
