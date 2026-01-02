import SpriteKit

struct Stage8Config: StageConfig {
    var stageColor: SKColor {
        return SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Gold/Divine
    }
    
    var spawnRateMultiplier: Double {
        return 3.0
    }
}
