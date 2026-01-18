import GameplayKit

class HealthComponent: GKComponent {
    var currentHealth: Int {
        didSet {
            onHealthChanged?(currentHealth, maxHealth)
        }
    }
    var maxHealth: Int
    
    // Barrier (Temporary Health)
    var barrier: Double = 0.0 {
        didSet {
             // Notify UI of barrier change? 
             // Ideally we'd have a separate callback or unified health+barrier callback.
             // For now, let's just keep track.
        }
    }
    var maxBarrier: Double = 100.0 // Limit stacking?
    
    var isInvulnerable: Bool = false
    
    var onHealthChanged: ((Int, Int) -> Void)?
    
    // Decay Logic helper
    var barrierDecayRate: Double = 5.0 // Amount per second
    
    init(maxHealth: Int) {
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if barrier > 0 {
            barrier -= barrierDecayRate * seconds
            if barrier < 0 { barrier = 0 }
        }
    }
}
