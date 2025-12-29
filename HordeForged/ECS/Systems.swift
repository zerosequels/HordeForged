import Foundation

struct UpdatePositionSystem: System {
    func update(entities: inout [Entity], deltaTime: TimeInterval) {
        for i in 0..<entities.count {
            if let position = entities[i].getComponent(ofType: PositionComponent.self),
               let velocity = entities[i].getComponent(ofType: VelocityComponent.self) {
                
                var newPosition = position
                newPosition.x += velocity.dx * Float(deltaTime)
                newPosition.y += velocity.dy * Float(deltaTime)
                entities[i].setComponent(newPosition)
            }
        }
    }
}
