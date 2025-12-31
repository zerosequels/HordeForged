import GameplayKit

class ChargeComponent: GKComponent {
    var currentCharge: TimeInterval = 0
    let maxCharge: TimeInterval
    var isCharging: Bool = false // Still useful for visual feedback during frame
    
    init(maxCharge: TimeInterval) {
        self.maxCharge = maxCharge
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum CoreState {
        case charging
        case bossSummoned
        case portalOpen
    }
    
    var state: CoreState = .charging
    
    func addCharge(_ amount: TimeInterval) {
        guard state == .charging else { return }
        
        // If not charging this frame (caller handles this), decay?
        // For now just add.
        
        currentCharge = min(currentCharge + amount, maxCharge)
        if currentCharge >= maxCharge {
            state = .bossSummoned // Ready to spawn boss
            print("Crucible Entity Fully Charged! Boss Summoned State.")
        }
    }
    
    func setPortalOpen() {
        state = .portalOpen
        print("Crucible Entity Portal Open!")
    }
}
