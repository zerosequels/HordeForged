import SpriteKit

struct Stage6Config: StageConfig {
    var stageColor: SKColor {
        return SKColor(red: 0.33, green: 0.42, blue: 0.18, alpha: 1.0) // Swamp/Dark Olive
    }
    
    var spawnRateMultiplier: Double {
        return 2.0
    }
}
