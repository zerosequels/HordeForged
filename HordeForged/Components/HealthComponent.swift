import GameplayKit

class HealthComponent: GKComponent {
    var currentHealth: Int {
        didSet {
            onHealthChanged?(currentHealth, maxHealth)
        }
    }
    var maxHealth: Int
    var isInvulnerable: Bool = false
    
    var onHealthChanged: ((Int, Int) -> Void)?
    
    init(maxHealth: Int) {
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
