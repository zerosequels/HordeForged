import GameplayKit
import SpriteKit

public class GameManager {
    var entities = Set<GKEntity>()
    
    // Component systems to update components in a deterministic order
    lazy var componentSystems: [GKComponentSystem] = {
        let movementSystem = GKComponentSystem(componentClass: MovementComponent.self)
        // Add other systems here as they are created
        return [movementSystem]
    }()
    
    weak var scene: SKScene?
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func add(_ entity: GKEntity) {
        entities.insert(entity)
        
        if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
            scene?.addChild(spriteComponent.node)
        }
        
        for system in componentSystems {
            system.addComponent(foundIn: entity)
        }
    }
    
    func remove(_ entity: GKEntity) {
        if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
            spriteComponent.node.removeFromParent()
        }
        
        entities.remove(entity)
        
        for system in componentSystems {
            system.removeComponent(foundIn: entity)
        }
    }
    
    func update(_ deltaTime: TimeInterval) {
        for system in componentSystems {
            system.update(deltaTime: deltaTime)
        }
    }
}
