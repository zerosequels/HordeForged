import SpriteKit

struct Stage5Config: StageConfig {
    var stageColor: SKColor {
        return SKColor(red: 0.4, green: 0.05, blue: 0.05, alpha: 1.0) // Volcano/Dark Red
    }
    
    var spawnRateMultiplier: Double {
        return 2.0
    }
    
    var stageNumber: Int {
        return 5
    }
}
