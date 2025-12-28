import Foundation

protocol System {
    func update(entities: inout [Entity], deltaTime: TimeInterval)
}
