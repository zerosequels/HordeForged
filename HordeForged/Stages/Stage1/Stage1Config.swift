import SpriteKit

struct Stage1Config: StageConfig {
    var stageColor: SKColor {
        return SKColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1.0) // Dark Green Grass
    }
    
    var spawnRateMultiplier: Double {
        return 1.0
    }
}
