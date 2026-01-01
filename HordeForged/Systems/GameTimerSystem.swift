import GameplayKit

class GameTimerSystem: GKComponentSystem<GKComponent> {
    
    var timeRemaining: TimeInterval = 720 // 12 Minutes
    var isGameOver: Bool = false
    var onTimerExpired: (() -> Void)?
    var onGameEnd: ((Bool) -> Void)? // Keep for Defeat triggering from Manager?
    // Actually Manager relies on this system to store isGameOver state.
    
    override init() {
        super.init(componentClass: GKComponent.self)
    }
    
    init(duration: TimeInterval? = nil) {
        if let duration = duration {
            self.timeRemaining = duration
        }
        super.init(componentClass: GKComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard !isGameOver else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= seconds
            
            if timeRemaining <= 0 {
                timeRemaining = 0
                onTimerExpired?()
            }
        }
    }
}
