import GameplayKit

class BlastComponent: GKComponent {
    
    let center: CGPoint
    let maxRadius: CGFloat
    let duration: TimeInterval
    let baseDamage: Double
    let maxKnockback: CGFloat
    
    var currentRadius: CGFloat = 0
    var elapsed: TimeInterval = 0
    
    // Track entities already hit to prevent multi-hits
    var hitTargets: Set<GKEntity> = []
    
    init(center: CGPoint, maxRadius: CGFloat, duration: TimeInterval, baseDamage: Double, maxKnockback: CGFloat) {
        self.center = center
        self.maxRadius = maxRadius
        self.duration = duration
        self.baseDamage = baseDamage
        self.maxKnockback = maxKnockback
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
