import Foundation

let ObsidianSkin = AbilityDefinition(
    id: "obsidian_skin",
    name: "Obsidian Skin",
    description: "Greatly increases max health.",
    iconName: "icon_obsidian_skin",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .health, value: 20.0, isMultiplier: false)
    ]
)
