import SpriteKit

class LevelManager {
    static let shared = LevelManager()
    
    private(set) var currentLevelIndex: Int = 0
    private(set) var currentStageConfig: StageConfig
    
    // Cache configs for easy access
    private var stageConfigs: [Int: StageConfig] = [:]
    
    private init() {
        // Initialize with default stage
        self.currentStageConfig = Stage1Config()
        
        // Register known stages
        stageConfigs[0] = Stage1Config()
        stageConfigs[1] = Stage2Config()
        stageConfigs[2] = Stage3Config()
        stageConfigs[3] = Stage4Config()
        stageConfigs[4] = Stage5Config()
        stageConfigs[5] = Stage6Config()
        stageConfigs[6] = Stage7Config()
        stageConfigs[7] = Stage8Config()
    }
    
    func startNewGame() {
        currentLevelIndex = 0
        loadStage(index: 0)
    }
    
    func nextLevel() {
        currentLevelIndex += 1
        loadStage(index: currentLevelIndex)
        print("Advancing to Level \(currentLevelIndex + 1)")
    }
    
    private func loadStage(index: Int) {
        // Simple modulo for looping stages if we run out, or clamp to max
        // For now, let's loop through available configs if we go past 8
        // Or specific logic:
        
        // If we have a specific config for this index, use it.
        // Otherwise, wrap around or generate procedural?
        // Let's wrap 8 stages for now.
        let configIndex = index % 8
        
        if let config = stageConfigs[configIndex] {
            self.currentStageConfig = config
        } else {
            // Fallback
            self.currentStageConfig = Stage1Config()
        }
        
        // Notification for systems to update (e.g., Map System to clear tiles)
        NotificationCenter.default.post(name: NSNotification.Name("StageChanged"), object: nil)
    }
}
