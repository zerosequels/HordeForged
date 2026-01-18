import Foundation

let ArcaneStrike = AbilityDefinition(
    id: "arcane_strike",
    name: "Arcane Strike",
    description: "Strikes enemies with a magic-infused blade.",
    iconName: "icon_arcane_strike",
    projectileName: nil, // Blast type, short range
    type: .active,
    rarity: .common,
    maxLevel: 10,
    baseCooldown: 1.0
)
