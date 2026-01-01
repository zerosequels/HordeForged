import GameplayKit
import SpriteKit

class InteractionComponent: GKComponent {
    
    let interactionRadius: CGFloat
    var onInteract: (() -> Void)?
    var isInteractable: Bool = true
    
    init(radius: CGFloat) {
        self.interactionRadius = radius
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
