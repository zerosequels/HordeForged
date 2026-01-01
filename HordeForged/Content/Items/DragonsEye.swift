import Foundation

let DragonsEye = ItemDefinition(
    id: "dragons_eye",
    name: "Dragon's Eye",
    description: "+5% Damage",
    rarity: .common,
    modifiers: [
        StatModifier(type: .damage, value: 0.05, isMultiplier: false)
    ]
)
