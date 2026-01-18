import Foundation

let EnchantedArmor = AbilityDefinition(
    id: "enchanted_armor",
    name: "Enchanted Armor",
    description: "Increases max health.",
    iconName: "icon_enchanted_armor",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .health, value: 10.0, isMultiplier: false)
    ]
)
