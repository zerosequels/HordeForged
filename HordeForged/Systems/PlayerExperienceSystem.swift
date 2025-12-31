import GameplayKit
import SpriteKit

class PlayerExperienceSystem: GKComponentSystem<GKComponent> {
    
    let scene: SKScene
    
    init(scene: SKScene) {
        self.scene = scene
        super.init(componentClass: ExperienceComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // In this system, we really just want to iterate over ExperienceComponents and check for level up.
        // Since we initialized super with ExperienceComponent.self, we can use components property.
        
        for component in components {
            guard let expComp = component as? ExperienceComponent else { continue }
            
            while expComp.currentExp >= expComp.expToNextLevel {
                levelUp(expComp)
            }
        }
    }
    
    func levelUp(_ expComp: ExperienceComponent) {
        expComp.currentExp -= expComp.expToNextLevel
        expComp.level += 1
        // Simple scaling: require 10 more exp each level
        expComp.expToNextLevel += 10
        
        print("Level Up! New Level: \(expComp.level)")
        
        // Trigger UI Callback
        expComp.onLevelUp?(expComp.level)
    }
}
