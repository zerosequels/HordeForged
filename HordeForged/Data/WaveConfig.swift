import Foundation

struct Wave {
    /// Start percentage (0.0 to 1.0)
    let startPct: Double
    /// Spawn Interval (seconds between spawns)
    let spawnInterval: TimeInterval
    /// Spawn Weights: [EnemyType: Weight]
    let spawnTable: [EnemyType: Double]
    /// Description for debug
    let description: String
}

struct WaveConfig {
    static let waves: [Wave] = [
        // 0% - Warmup
        Wave(startPct: 0.0, spawnInterval: 2.0, spawnTable: [.walker: 1.0], description: "Warmup"),
        
        // 8% - Awakening
        Wave(startPct: 0.08, spawnInterval: 1.5, spawnTable: [.walker: 0.8, .runner: 0.2], description: "Awakening"),
        
        // 25% - Escalation
        Wave(startPct: 0.25, spawnInterval: 1.0, spawnTable: [.walker: 0.6, .runner: 0.3, .brute: 0.1], description: "Escalation"),
        
        // 50% - Heavy Hitters
        Wave(startPct: 0.50, spawnInterval: 0.8, spawnTable: [.walker: 0.4, .brute: 0.4, .runner: 0.2], description: "Heavy Hitters"),
        
        // 66% - Swarm
        Wave(startPct: 0.66, spawnInterval: 0.2, spawnTable: [.swarmer: 0.7, .elite: 0.1, .walker: 0.2], description: "Swarm"),
        
        // 83% - Elite Guard
        Wave(startPct: 0.83, spawnInterval: 0.5, spawnTable: [.elite: 0.5, .brute: 0.3, .runner: 0.2], description: "Elite Guard"),
        
        // 100% - Sudden Death
        Wave(startPct: 1.0, spawnInterval: 0.1, spawnTable: [.elite: 1.0], description: "Sudden Death")
    ]
}
