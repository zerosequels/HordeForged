import GameplayKit

class DamageComponent: GKComponent {
    var damageAmount: Int
    
    init(damage: Int) {
        self.damageAmount = damage
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
