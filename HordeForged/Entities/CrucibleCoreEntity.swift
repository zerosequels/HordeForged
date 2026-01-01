import SpriteKit
import GameplayKit

class CrucibleCoreEntity: GKEntity {
    
    init(position: CGPoint, chargeTime: TimeInterval) {
        super.init()
        
        // Visuals
        let node = SKShapeNode(rectOf: CGSize(width: 60, height: 60), cornerRadius: 5)
        node.fillColor = .cyan
        node.position = position
        node.zPosition = 1
        
        let label = SKLabelNode(text: "Core")
        label.fontSize = 12
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        node.addChild(label)
        
        // Charge Bar
        let barSize = CGSize(width: 80, height: 10)
        let barBg = SKShapeNode(rectOf: barSize)
        barBg.fillColor = .gray
        barBg.strokeColor = .black
        barBg.position = CGPoint(x: 0, y: -40)
        barBg.zPosition = 2
        node.addChild(barBg)
        
        let barFill = SKShapeNode(rectOf: barSize)
        barFill.fillColor = .green
        barFill.strokeColor = .clear
        barFill.position = CGPoint(x: 0, y: -40)
        barFill.zPosition = 3
        barFill.xScale = 0.0 // Start empty
        barFill.name = "chargeBarFill" // Tag for lookup
        node.addChild(barFill)
        
        // Fix anchor point for left-to-right fill?
        // standard rectOf is centered.
        // re-create barFill with offset anchor.
        node.removeChildren(in: [barFill])
        
        let barFillLeft = SKShapeNode(rect: CGRect(x: -barSize.width / 2, y: -barSize.height / 2, width: barSize.width, height: barSize.height))
        barFillLeft.fillColor = .green
        barFillLeft.strokeColor = .clear
        barFillLeft.position = CGPoint(x: 0, y: -40)
        barFillLeft.zPosition = 3
        barFillLeft.xScale = 0.0
        barFillLeft.name = "chargeBarFill"
        node.addChild(barFillLeft)
        
        let spriteComponent = SpriteComponent(node: node)
        addComponent(spriteComponent)
        
        // Charge Logic
        let chargeComponent = ChargeComponent(maxCharge: chargeTime)
        addComponent(chargeComponent)
        
        // Interaction Logic
        let interactionComp = InteractionComponent(radius: 60)
        interactionComp.onInteract = {
             // Logic will be handled via closure assignment in GameManager or Scene?
             // Or assign a default here that calls LevelManager?
             // LevelManager is a singleton, so we can call it.
             print("Interacting with Crucible Core!")
             LevelManager.shared.nextLevel()
        }
        interactionComp.isInteractable = false // Start disabled, enable after boss death
        addComponent(interactionComp)
        
        // Navigation Indicator
        addComponent(IndicatorComponent())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
