import Foundation

struct UpdatePositionSystem: System {
    func update(entities: inout [Entity], deltaTime: TimeInterval) {
        for i in 0..<entities.count { // Iterate through the mutable array
            var entity = entities[i] // Get a mutable copy of the entity
            
            guard let position = entity.getComponent(ofType: PositionComponent.self),
                  let velocity = entity.getComponent(ofType: VelocityComponent.self) else {
                continue
            }
            
            var newPosition = position
            newPosition.x += velocity.dx * Float(deltaTime)
            newPosition.y += velocity.dy * Float(deltaTime)
            
            entity.setComponent(newPosition) // Update the component
            
            entities[i] = entity // Assign the modified entity back to the array
        }
    }
}
