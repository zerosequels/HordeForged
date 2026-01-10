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
            stats = EnemyStats(health: 30, speed: 40.0, damage: 10, size: CGSize(width: 48, height: 48), color: .red, xpValue: 10, textureName: nil)
        case .runner:
            stats = EnemyStats(health: 15, speed: 90.0, damage: 5, size: CGSize(width: 48, height: 48), color: .yellow, xpValue: 15, textureName: nil)
        case .brute:
            stats = EnemyStats(health: 100, speed: 25.0, damage: 20, size: CGSize(width: 48, height: 48), color: .blue, xpValue: 50, textureName: nil)
        case .elite:
            stats = EnemyStats(health: 200, speed: 45.0, damage: 15, size: CGSize(width: 48, height: 48), color: .cyan, xpValue: 100, textureName: nil)
        case .swarmer:
            stats = EnemyStats(health: 5, speed: 55.0, damage: 2, size: CGSize(width: 48, height: 48), color: .green, xpValue: 5, textureName: nil)
        case .boss:
            stats = EnemyStats(health: 1000, speed: 20.0, damage: 30, size: CGSize(width: 48, height: 48), color: .purple, xpValue: 500, textureName: nil)
        }
        

        
        // Stage Modifications
        // Construct Texture Name: enemy_{type}_stage{stage}
        // Example: enemy_walker_stage1, enemy_brute_stage3
        // Add 1 to stage index to match file naming convention (Stage 1 = Index 0)
        let baseTextureName = "enemy_\(type.rawValue)_stage\(stage + 1)"
        // Note: This relies on assets existing. If we want a fallback, we'd need to check existence or rely on sprite placeholder logic.
        // For now, we assume assets will be provided.
        // If specific stage variations are missing, we could fallback to stage0 if we had a way to check.
        
        // Apply Stage-Specific overrides (Stats scaling)
        var modifiedStats = stats
        
        // Dynamic Texture Name assignment
        // Create a new copy with the texture name
        modifiedStats = EnemyStats(
            health: stats.health,
            speed: stats.speed,
            damage: stats.damage,
            size: stats.size,
            color: stats.color,
            xpValue: stats.xpValue,
            textureName: baseTextureName
        )
        
        // Scaling Logic (Simple Linear Scaling)
        if stage > 0 {
            let multiplier = 1.0 + (Double(stage) * 0.1) // 10% per stage
            
            modifiedStats = EnemyStats(
                health: Int(Double(modifiedStats.health) * multiplier),
                speed: modifiedStats.speed * (1.0 + (Double(stage) * 0.02)), // 2% speed inc
                damage: Int(Double(modifiedStats.damage) * multiplier),
                size: modifiedStats.size,
                color: modifiedStats.color, // Could update color per stage if desired
                xpValue: Int(Double(modifiedStats.xpValue) * multiplier),
                textureName: modifiedStats.textureName
            )
        }
        
        return modifiedStats
    }
}
