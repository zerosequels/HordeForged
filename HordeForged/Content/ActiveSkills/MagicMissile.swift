import Foundation

let MagicMissile = AbilityDefinition(
    id: "magic_missile",
    name: "Magic Missile",
    description: "Fires a bolt of arcane energy.",
    iconName: "magic_missile",
    projectileName: "projectile_arcane_bolt", // Reuse arcane bolt for now
    type: .active,
    rarity: .common,
    maxLevel: 10,
    baseCooldown: 0.6
)
