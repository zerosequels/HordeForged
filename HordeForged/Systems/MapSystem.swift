import SpriteKit
import GameplayKit

class MapSystem: GKComponentSystem<GKComponent> {
    
    let scene: SKScene
    private var tileNodes: [String: SKShapeNode] = [:]
    private let tileSize: CGFloat = 1000 // Large tiles
    private let bufferSize: Int = 1 // How many extra tiles around viewport
    
    private var tileContainer: SKNode
    
    init(scene: SKScene) {
        self.scene = scene
        self.tileContainer = SKNode()
        self.tileContainer.zPosition = -100 // Background
        self.tileContainer.name = "MapContainer"
        scene.addChild(tileContainer)
        
        super.init(componentClass: GKComponent.self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onStageChanged), name: NSNotification.Name("StageChanged"), object: nil)
        
        // Initial Draw
        updateMap()
    }
    
    @objc private func onStageChanged() {
        // Clear all tiles so they regenerate with new color
        tileContainer.removeAllChildren()
        tileNodes.removeAll()
        updateMap()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // Check if we need to generate new tiles based on camera position
        updateMap()
    }
    
    private func updateMap() {
        guard let camera = scene.camera else { return }
        
        let cameraPos = camera.position
        
        // Determine grid coordinates of camera
        let gridX = Int(floor(cameraPos.x / tileSize))
        let gridY = Int(floor(cameraPos.y / tileSize))
        
        // Loop through visible grid area including buffer
        // Viewport size? Assume 2x2 grid is enough cover or calculate based on screen size/zoom.
        // Screen width ~800, Tile 1000. 1 tile radius is usually enough, use 2 for safety.
        
        var activeKeys: Set<String> = []
        
        let range = -bufferSize...bufferSize
        
        for dx in range {
            for dy in range {
                let x = gridX + dx
                let y = gridY + dy
                let key = "\(x)_\(y)"
                activeKeys.insert(key)
                
                if tileNodes[key] == nil {
                    createTile(x: x, y: y, key: key)
                }
            }
        }
        
        // Cleanup old tiles (Optional memory optimization)
        var keysToRemove: [String] = []
        
        for (key, node) in tileNodes {
            if !activeKeys.contains(key) {
                node.removeFromParent()
                keysToRemove.append(key)
            }
        }
        
        for key in keysToRemove {
            tileNodes.removeValue(forKey: key)
        }
    }
    
    private func createTile(x: Int, y: Int, key: String) {
        let rect = CGRect(x: -tileSize/2, y: -tileSize/2, width: tileSize, height: tileSize)
        let tile = SKShapeNode(rect: rect)
        
        // Add random variation to color to distinguish tiles?
        // Or just check LevelManager
        let baseColor = LevelManager.shared.currentStageConfig.stageColor
        tile.fillColor = baseColor
        tile.strokeColor = .clear // Seamless
        
        // Position
        let posX = CGFloat(x) * tileSize
        let posY = CGFloat(y) * tileSize
        tile.position = CGPoint(x: posX, y: posY)
        
        tileContainer.addChild(tile)
        tileNodes[key] = tile
        
        // Optional: Add visual noise/texture here if we had assets
    }
}
