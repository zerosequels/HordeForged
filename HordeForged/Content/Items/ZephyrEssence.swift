import Foundation

let ZephyrEssence = ItemDefinition(
    id: "zephyr_essence",
    name: "Zephyr Essence",
    description: "+10% Move Speed",
    rarity: .common,
    iconName: "zephyr_essence",
    modifiers: [
        StatModifier(type: .movementSpeed, value: 0.10, isMultiplier: false)
    ]
)
