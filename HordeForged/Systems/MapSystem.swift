import SpriteKit
import GameplayKit

class MapSystem: GKComponentSystem<GKComponent> {
    
    let scene: SKScene
    private var tileMaps: [String: SKNode] = [:] // Key -> TileMapNode or ShapeNode (Fallback)
    
    // Config: 32x32 tiles per chunk.
    private let tileDim: Int = 32
    private let tileSizePts: CGFloat = 32.0 // Standard Pixel Art Grid
    private var chunkWidthPts: CGFloat { return CGFloat(tileDim) * tileSizePts }
    
    // Noise for procedural generation
    private let noise: GKNoise
    private let noiseMap: GKNoiseMap
    
    private let bufferSize: Int = 1 // 1 chunk buffer is enough if chunks are large (1024px)
    
    private var tileContainer: SKNode
    
    init(scene: SKScene) {
        self.scene = scene
        self.tileContainer = SKNode()
        self.tileContainer.zPosition = -100 // Background
        self.tileContainer.name = "MapContainer"
        scene.addChild(tileContainer)
        
        // Setup Noise (Simplex is good for organic terrain)
        let source = GKPerlinNoiseSource()
        source.frequency = 0.5 // Scale of features
        source.persistence = 0.5
        source.lacunarity = 2.0
        
        self.noise = GKNoise(source)
        // Infinite noise map logic: we'll sample it manually or make a large map.
        // Actually, for infinite procedural local sampling, we can just use noise.value(at:)
        // But GKNoiseMap is optimized. Let's start with a large map centered on 0,0 and see if we hit limits.
        // Better: Sample noise directly at coordinates in createChunk.
        self.noiseMap = GKNoiseMap(noise) // Default size
        
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
            createTileMapChunk(x: x, y: y, tileSet: tileSet, config: config, key: key)
        } else {
            // Fallback to Color Block (Old Behavior)
            createFallbackChunk(x: x, y: y, color: config.stageColor, key: key)
        }
    }
    
    private func createTileMapChunk(x: Int, y: Int, tileSet: SKTileSet, config: StageConfig, key: String) {
        let tileMap = SKTileMapNode(tileSet: tileSet, columns: tileDim, rows: tileDim, tileSize: CGSize(width: tileSizePts, height: tileSizePts))
        
        // Identify Groups
        // We assume "Base" exists. Path is optional.
        guard let baseGroup = tileSet.tileGroups.first(where: { $0.name == config.baseTileGroupName }) else {
            // If base group missing in asset, fail to fallback
             print("Warning: Base TileGroup '\(config.baseTileGroupName)' not found in set '\(config.tileSetName)'.")
             createFallbackChunk(x: x, y: y, color: config.stageColor, key: key)
             return
        }
        
        let pathGroup = tileSet.tileGroups.first(where: { $0.name == config.pathTileGroupName })
        
        // Fill Logic
        // Enable Automapping so SpriteKit handles the Wang corners/edges
        tileMap.enableAutomapping = true
        
        for col in 0..<tileDim {
            for row in 0..<tileDim {
                // World Coords for Noise
                // Chunk Origin (Tiles) + Offset
                let worldTileX = Int32(x * tileDim + col)
                let worldTileY = Int32(y * tileDim + row)
                
                // Sample Noise (Scale down coordinate for wider features)
                // frequency 0.05 means features are ~20 tiles wide.
                let noiseVal = noise.value(atPosition: vector_float2(Float(worldTileX) * 0.1, Float(worldTileY) * 0.1))
                
                if let pathGroup = pathGroup, noiseVal > 0.4 {
                    tileMap.setTileGroup(pathGroup, forColumn: col, row: row)
                } else {
                    tileMap.setTileGroup(baseGroup, forColumn: col, row: row)
                }
            }
        }
        
        // Position Chunk
        // SKTileMapNode is centered? No, anchor is 0.5,0.5 usually.
        // Let's set anchor to 0,0 for easier "grid" placement or align centers.
        // Default anchor is 0.5.
        // Chunk Center Position:
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
