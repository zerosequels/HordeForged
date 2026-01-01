import SpriteKit

struct Stage2Config: StageConfig {
    var stageColor: SKColor {
        return SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) // Grey Graveyard/Stone
    }
    
    var spawnRateMultiplier: Double {
        return 1.2
    }
}
