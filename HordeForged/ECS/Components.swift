import Foundation

struct PositionComponent: Component {
    var id = UUID()
    var x: Float
    var y: Float
}

struct HealthComponent: Component {
    var id = UUID()
    var currentHealth: Int
    var maxHealth: Int
}
