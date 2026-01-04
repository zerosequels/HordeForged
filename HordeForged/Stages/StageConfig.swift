import SpriteKit

/// Protocol defining the configuration for a specific game stage/level.
protocol StageConfig {
    /// The base background color for the infinite map tiles in this stage.
    var stageColor: SKColor { get }
    
    /// Multiplier for enemy spawn rates in this stage.
    var spawnRateMultiplier: Double { get }
    
    // MARK: - Tile Map Configuration
    // Default implementation provided via Extension based on stageNumber
    var tileSetName: String { get }
    var baseTileGroupName: String { get }
    
    /// The unique number of this stage (1-8)
    var stageNumber: Int { get }
}

extension StageConfig {
    var tileSetName: String {
        return "stage_\(stageNumber)"
    }
    
    var baseTileGroupName: String {
        return "Ground"
    }
}
