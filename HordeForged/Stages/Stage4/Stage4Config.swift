import SpriteKit

struct Stage4Config: StageConfig {
    var stageColor: SKColor {
        return SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0) // Ice/Pale Blue
    }
    
    var spawnRateMultiplier: Double {
        return 1.6
    }
}
