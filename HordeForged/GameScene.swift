import SpriteKit
import GameplayKit // For potential future ECS use

class GameScene: SKScene {
    var gameManager: GameManager!
    
    private var lastUpdateTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupGame()
    }
    
    public func setupGame() {
        gameManager = GameManager(scene: self)
        
        // Test Entity: "The Player"
        let player = SurvivorEntity(color: .blue, size: CGSize(width: 40, height: 40))
        if let movement = player.component(ofType: MovementComponent.self) {
            movement.velocity = CGVector(dx: 1.0, dy: 0.0) // Move right
        }
        
        player.component(ofType: SpriteComponent.self)?.node.position = CGPoint(x: 0, y: 0)
        
        gameManager.add(player)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }

        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        gameManager.update(deltaTime)
    }
}
