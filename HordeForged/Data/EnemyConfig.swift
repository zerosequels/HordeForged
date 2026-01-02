import SpriteKit

enum EnemyType: String, CaseIterable {
    case walker
    case runner
    case brute
    case elite
    case swarmer
    case boss
}

struct EnemyStats {
    let health: Int
    let speed: CGFloat
    let damage: Int
    let size: CGSize
    let color: SKColor
    let xpValue: Int
    let textureName: String?
}

struct EnemyConfig {
    static func stats(for type: EnemyType, stage: Int) -> EnemyStats {
        // Base Stats
        var stats: EnemyStats
        
        switch type {
        case .walker:
            stats = EnemyStats(health: 30, speed: 40.0, damage: 10, size: CGSize(width: 30, height: 30), color: .red, xpValue: 10, textureName: nil)
        case .runner:
            stats = EnemyStats(health: 15, speed: 90.0, damage: 5, size: CGSize(width: 25, height: 25), color: .yellow, xpValue: 15, textureName: nil)
        case .brute:
            stats = EnemyStats(health: 100, speed: 25.0, damage: 20, size: CGSize(width: 45, height: 45), color: .blue, xpValue: 50, textureName: nil)
        case .elite:
            stats = EnemyStats(health: 200, speed: 45.0, damage: 15, size: CGSize(width: 35, height: 35), color: .cyan, xpValue: 100, textureName: nil)
        case .swarmer:
            stats = EnemyStats(health: 5, speed: 55.0, damage: 2, size: CGSize(width: 15, height: 15), color: .green, xpValue: 5, textureName: nil)
        case .boss:
            stats = EnemyStats(health: 1000, speed: 20.0, damage: 30, size: CGSize(width: 80, height: 80), color: .purple, xpValue: 500, textureName: nil)
        }
        
        // Stage Modifications
        // Example: Stage 2 (Index 1) is "Frost" theme -> Blue enemies
        if stage == 1 {
            // Can override specific properties
            // stats.color = .cyan 
            // Or return a modified copy if struct was mutable or we recreate it.
            // Since it's immutable let's recreate just the changing parts or use a helper.
            return EnemyStats(
                health: stats.health + 10, // Slightly stronger
                speed: stats.speed,
                damage: stats.damage,
                size: stats.size,
                color: .cyan, // Frost color
                xpValue: stats.xpValue,
                textureName: stats.textureName // Could be "walker_frost"
            )
        }
        
        // Example: Stage 3 (Index 2) is "Fire" -> Orange
        if stage == 2 {
             return EnemyStats(
                health: stats.health + 20,
                speed: stats.speed * 1.1,
                damage: stats.damage + 5,
                size: stats.size,
                color: .orange,
                xpValue: stats.xpValue + 5,
                textureName: nil
            )
        }
        
        return stats
    }
}
