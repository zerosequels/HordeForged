import Foundation

let ArcaneBolt = AbilityDefinition(
    id: "arcane_bolt",
    name: "Arcane Bolt",
    description: "Fires a bolt of pure energy.",
    iconName: "arcane_bolt",
    projectileName: "projectile_arcane_bolt",
    projectileRotationOffset: .pi / 2 + (14.0 * .pi / 180.0), // 90 + 14 degrees CCW
    type: .active,
    rarity: .common,
    maxLevel: 10
)
