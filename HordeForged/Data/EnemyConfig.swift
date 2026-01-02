import SpriteKit

enum EnemyType: String, CaseIterable {
    case walker
    case runner
    case brute
    case elite
    case swarmer
    case boss
}

struct EnemyStats {
    let health: Int
    let speed: CGFloat
    let damage: Int
    let size: CGSize
    let color: SKColor
    let xpValue: Int
}

struct EnemyConfig {
    static func stats(for type: EnemyType) -> EnemyStats {
        switch type {
        case .walker:
            return EnemyStats(health: 30, speed: 40.0, damage: 10, size: CGSize(width: 30, height: 30), color: .red, xpValue: 10)
        case .runner:
            return EnemyStats(health: 15, speed: 90.0, damage: 5, size: CGSize(width: 25, height: 25), color: .yellow, xpValue: 15)
        case .brute:
            return EnemyStats(health: 100, speed: 25.0, damage: 20, size: CGSize(width: 45, height: 45), color: .blue, xpValue: 50)
        case .elite:
            return EnemyStats(health: 200, speed: 45.0, damage: 15, size: CGSize(width: 35, height: 35), color: .cyan, xpValue: 100)
        case .swarmer:
            return EnemyStats(health: 5, speed: 55.0, damage: 2, size: CGSize(width: 15, height: 15), color: .green, xpValue: 5)
        case .boss:
            return EnemyStats(health: 1000, speed: 20.0, damage: 30, size: CGSize(width: 80, height: 80), color: .purple, xpValue: 500)
        }
    }
}
