import Foundation

let GoatHoof = ItemDefinition(
    id: "goat_hoof",
    name: "Goat Hoof",
    description: "+10% Move Speed",
    rarity: .common,
    modifiers: [
        StatModifier(type: .movementSpeed, value: 0.10, isMultiplier: false)
    ]
)
