import GameplayKit

enum HazardType {
    case slow
    case damage
}

class HazardComponent: GKComponent {
    let type: HazardType
    let value: CGFloat // For slow: multiplier (e.g. 0.5), for damage: amount
    
    init(type: HazardType, value: CGFloat) {
        self.type = type
        self.value = value
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
