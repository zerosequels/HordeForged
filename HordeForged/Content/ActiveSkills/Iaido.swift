import Foundation

let Iaido = AbilityDefinition(
    id: "iaido",
    name: "Iaido",
    description: "A lightning-fast blade draw.",
    iconName: "iaido",
    projectileName: "projectile_slash", // Reusing or generic
    type: .active,
    rarity: .common,
    maxLevel: 10,
    baseCooldown: 0.5
)
