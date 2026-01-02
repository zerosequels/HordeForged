import SpriteKit

struct Stage3Config: StageConfig {
    var stageColor: SKColor {
        return SKColor(red: 0.93, green: 0.79, blue: 0.69, alpha: 1.0) // Desert Sand
    }
    
    var spawnRateMultiplier: Double {
        return 1.4
    }
}
