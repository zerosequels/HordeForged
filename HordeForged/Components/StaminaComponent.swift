import GameplayKit

class StaminaComponent: GKComponent {
    var currentStamina: CGFloat
    var maxStamina: CGFloat
    var regenRate: CGFloat // Stamina per second
    
    init(maxStamina: CGFloat = 100.0, regenRate: CGFloat = 10.0) {
        self.maxStamina = maxStamina
        self.currentStamina = maxStamina
        self.regenRate = regenRate
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if currentStamina < maxStamina {
            currentStamina += regenRate * CGFloat(seconds)
            if currentStamina > maxStamina {
                currentStamina = maxStamina
            }
        }
    }
    
    func consume(amount: CGFloat) -> Bool {
        if currentStamina >= amount {
            currentStamina -= amount
            return true
        }
        return false
    }
}
