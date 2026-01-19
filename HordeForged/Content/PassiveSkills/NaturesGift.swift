import Foundation

let NaturesGift = AbilityDefinition(
    id: "natures_gift",
    name: "Nature's Gift",
    description: "Increases max health.",
    iconName: "natures_gift",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .health, value: 15.0, isMultiplier: false)
    ]
)
