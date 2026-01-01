import SpriteKit

/// Protocol defining the configuration for a specific game stage/level.
protocol StageConfig {
    /// The base background color for the infinite map tiles in this stage.
    var stageColor: SKColor { get }
    
    /// Multiplier for enemy spawn rates in this stage.
    var spawnRateMultiplier: Double { get }
    
    // Future expansion:
    // var bossType: EnemyType { get }
    // var availableInteractables: [InteractableType] { get }
}
