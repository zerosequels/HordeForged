import SpriteKit
import GameplayKit

class MapSystem: GKComponentSystem<GKComponent> {
    
    let scene: SKScene
    private var tileMaps: [String: SKNode] = [:] // Key -> TileMapNode or ShapeNode (Fallback)
    
    // Config: 32x32 tiles per chunk.
    // Config: 32x32 tiles per chunk.
    private let tileDim: Int = 32
    private let tileSizePts: CGFloat = 32.0 // Standard Pixel Art Grid
    
    // Scale Factor: 3.0 means 32px tiles look like 96px on screen
    private let bgScale: CGFloat = 3.0
    
    private var chunkWidthPts: CGFloat { return CGFloat(tileDim) * tileSizePts * bgScale }
    
    private let bufferSize: Int = 1
    
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
        // Clear all tiles so they regenerate with new config
        tileContainer.removeAllChildren()
        tileMaps.removeAll()
        updateMap()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        updateMap()
    }
    
    private func updateMap() {
        guard let camera = scene.camera else { return }
        
        let cameraPos = camera.position
        
        // Grid Coordinates (Chunk Index)
        let gridX = Int(floor(cameraPos.x / chunkWidthPts))
        let gridY = Int(floor(cameraPos.y / chunkWidthPts))
        
        var activeKeys: Set<String> = []
        let range = -bufferSize...bufferSize
        
        for dx in range {
            for dy in range {
                let x = gridX + dx
                let y = gridY + dy
                let key = "\(x)_\(y)"
                activeKeys.insert(key)
                
                if tileMaps[key] == nil {
                    createChunk(x: x, y: y, key: key)
                }
            }
        }
        
        // Cleanup
        for (key, node) in tileMaps {
            if !activeKeys.contains(key) {
                node.removeFromParent()
                tileMaps.removeValue(forKey: key)
            }
        }
    }
    
    private func createChunk(x: Int, y: Int, key: String) {
        let config = LevelManager.shared.currentStageConfig
        
        // Attempt to load Tile Set
        if let tileSet = SKTileSet(named: config.tileSetName) {
            print("✅ [MapSystem] Successfully loaded TileSet: \(config.tileSetName)")
            createTileMapChunk(x: x, y: y, tileSet: tileSet, config: config, key: key)
        } else {
            print("❌ [MapSystem] Failed to find TileSet named: '\(config.tileSetName)'. Using Fallback.")
            // Fallback to Color Block
            createFallbackChunk(x: x, y: y, color: config.stageColor, key: key)
        }
    }
    
    private func createTileMapChunk(x: Int, y: Int, tileSet: SKTileSet, config: StageConfig, key: String) {
        let tileMap = SKTileMapNode(tileSet: tileSet, columns: tileDim, rows: tileDim, tileSize: CGSize(width: tileSizePts, height: tileSizePts))
        
        // Apply Scale
        tileMap.xScale = bgScale
        tileMap.yScale = bgScale
        
        // Identify Group
        guard let baseGroup = tileSet.tileGroups.first(where: { $0.name == config.baseTileGroupName }) else {
             print("Warning: Base TileGroup '\(config.baseTileGroupName)' not found in set '\(config.tileSetName)'.")
             createFallbackChunk(x: x, y: y, color: config.stageColor, key: key)
             return
        }
        
        // Fill Logic: Simple Flood Fill
        tileMap.fill(with: baseGroup)
        
        // Position Chunk
        let posX = CGFloat(x) * chunkWidthPts
        let posY = CGFloat(y) * chunkWidthPts
        tileMap.position = CGPoint(x: posX, y: posY)
        
        tileContainer.addChild(tileMap)
        tileMaps[key] = tileMap
    }
    
    private func createFallbackChunk(x: Int, y: Int, color: SKColor, key: String) {
        let rect = CGRect(x: -chunkWidthPts/2, y: -chunkWidthPts/2, width: chunkWidthPts, height: chunkWidthPts)
        let tile = SKShapeNode(rect: rect)
        tile.fillColor = color
        tile.strokeColor = .clear
        
        let posX = CGFloat(x) * chunkWidthPts
        let posY = CGFloat(y) * chunkWidthPts
        tile.position = CGPoint(x: posX, y: posY)
        
        tileContainer.addChild(tile)
        tileMaps[key] = tile
    }
}
