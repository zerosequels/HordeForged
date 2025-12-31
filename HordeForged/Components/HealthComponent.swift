import GameplayKit

class HealthComponent: GKComponent {
    var currentHealth: Int
    var maxHealth: Int
    
    init(maxHealth: Int) {
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
