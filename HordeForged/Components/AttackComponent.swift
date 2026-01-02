import GameplayKit

class AttackComponent: GKComponent {
    var damage: Int
    
    init(damage: Int) {
        self.damage = damage
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
