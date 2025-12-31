import GameplayKit

class ExperienceComponent: GKComponent {
    var currentExp: Int = 0
    var level: Int = 1
    var expToNextLevel: Int = 10 // Starting threshold
    
    // Callback for leveling up, can be set by the system managing this component
    var onLevelUp: ((Int) -> Void)?
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addExp(_ amount: Int) {
        currentExp += amount
        // Level up logic generally handled by system, but could be helper here.
        // We'll let the system handle the check to trigger events properly.
    }
}
