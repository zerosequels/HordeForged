import Foundation

let StoneThrow = AbilityDefinition(
    id: "stone_throw",
    name: "Stone Throw",
    description: "Hurls a heavy stone at the nearest enemy.",
    iconName: "icon_stone_throw",
    projectileName: "projectile_stone_throw", // Needs generic projectile
    type: .active,
    rarity: .common,
    maxLevel: 10,
    baseCooldown: 0.8
)
