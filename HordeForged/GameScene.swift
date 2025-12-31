import SpriteKit
import GameplayKit // For potential future ECS use

class GameScene: SKScene {
    var gameManager: GameManager!
    
    private let virtualJoystick = VirtualJoystick()
    private var player: SurvivorEntity?
    
    // Camera
    private let cameraNode = SKCameraNode()
    private let timerLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
    
    // Joystick Visualization
    private var joystickBase: SKShapeNode?
    private var joystickKnob: SKShapeNode?
    private var joystickLine: SKShapeNode?
    
    // Debug Visualization
    private var pickupRadiusNode: SKShapeNode?
    
    // UI
    private var healthBarBackground: SKShapeNode?
    private var healthBar: SKShapeNode?
    private var healthLabel: SKLabelNode?
    
    private var expBarBackground: SKShapeNode?
    private var expBar: SKShapeNode?
    
    private var lastUpdateTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Setup Camera
        addChild(cameraNode)
        camera = cameraNode
        
        // Setup Timer Label (Child of Camera)
        timerLabel.fontSize = 24
        timerLabel.fontColor = .white
        timerLabel.zPosition = 100
        cameraNode.addChild(timerLabel)
        
        // Setup Health Bar (Top Left)
        // Setup Health Bar (Top Left)
        let barSize = CGSize(width: 200, height: 20)
        let barOrigin = CGPoint(x: 0, y: -barSize.height / 2) // Anchor Left Center-Y
        
        let barBg = SKShapeNode(rect: CGRect(origin: barOrigin, size: barSize), cornerRadius: 5)
        barBg.fillColor = .gray
        barBg.strokeColor = .white
        barBg.zPosition = 100
        cameraNode.addChild(barBg)
        self.healthBarBackground = barBg
        
        let bar = SKShapeNode(rect: CGRect(origin: barOrigin, size: barSize), cornerRadius: 5)
        bar.fillColor = .green
        bar.strokeColor = .clear
        bar.zPosition = 101
        cameraNode.addChild(bar)
        self.healthBar = bar
        
        // Setup Health Label
        let hLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        hLabel.fontSize = 14
        hLabel.fontColor = .white
        hLabel.zPosition = 102 // Above bar
        cameraNode.addChild(hLabel)
        self.healthLabel = hLabel
        
        // Setup EXP Bar (Below Health Bar)
        // Setup EXP Bar (Below Health Bar)
        let expBarSize = CGSize(width: 200, height: 10)
        let expBarOrigin = CGPoint(x: 0, y: -expBarSize.height / 2)
        
        let expBg = SKShapeNode(rect: CGRect(origin: expBarOrigin, size: expBarSize), cornerRadius: 3)
        expBg.fillColor = .darkGray
        expBg.strokeColor = .black
        expBg.zPosition = 100
        cameraNode.addChild(expBg)
        self.expBarBackground = expBg
        
        let expBar = SKShapeNode(rect: CGRect(origin: expBarOrigin, size: expBarSize), cornerRadius: 3)
        expBar.fillColor = .blue
        expBar.strokeColor = .clear
        expBar.zPosition = 101
        cameraNode.addChild(expBar)
        self.expBar = expBar
        
        // Initial Position Update
        updateUIPositions()
        
        // Setup Joystick Visualization
        setupJoystickNodes()
        
        // Setup Pickup Radius Debug
        let pickupRadius: CGFloat = 100.0
        let radiusNode = SKShapeNode(circleOfRadius: pickupRadius)
        radiusNode.strokeColor = .green
        radiusNode.lineWidth = 1
        radiusNode.alpha = 0.3
        // Add to Player Node (or follow player)
        // Since player entity has a sprite, let's find it after game start, or just position it in update.
        // Easiest is to add to scene and update position.
        addChild(radiusNode)
        self.pickupRadiusNode = radiusNode
        
        setupGame()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        // Re-position UI elements when view size changes (e.g. rotation or init layout)
        updateUIPositions()
    }
    
    private func updateUIPositions() {
        guard let view = view else { return }
        // Use scene size or view bounds? Since camera is in scale with scene, and scene is .resizeFill, scene.size == view.bounds.size usually.
        let width = size.width
        let height = size.height
        
        // Timer at very top (with some padding for notch/safe area)
        timerLabel.position = CGPoint(x: 0, y: height / 2 - 50)
        
        // Health Bar Centered Below Timer
        let yPos = height / 2 - 80
        let xOffset: CGFloat = -100 // Half of 200 width to center it
        
        healthBarBackground?.position = CGPoint(x: xOffset, y: yPos)
        healthBar?.position = CGPoint(x: xOffset, y: yPos)
        
        // Label centered on bar (slightly adjusted for font baseline)
        healthLabel?.position = CGPoint(x: 0, y: yPos - 5)
        
        // EXP Bar directly below Health Bar
        let expYPos = yPos - 20
        expBarBackground?.position = CGPoint(x: xOffset, y: expYPos)
        expBar?.position = CGPoint(x: xOffset, y: expYPos)
    }
    
    public func setupGame() {
        gameManager = GameManager(scene: self)
        
        // Test Entity: "The Player"
        let player = SurvivorEntity(color: .blue, size: CGSize(width: 40, height: 40))
        self.player = player
        
        // Initial velocity is zero, controlled by joystick
        if let movement = player.component(ofType: MovementComponent.self) {
            movement.velocity = .zero
        }
        
        player.component(ofType: SpriteComponent.self)?.node.position = CGPoint(x: 0, y: 0)
        
        // Experience Callback
        if let expComp = player.component(ofType: ExperienceComponent.self) {
            expComp.onLevelUp = { level in
                // Post Notification to Controller
                NotificationCenter.default.post(name: NSNotification.Name("LevelUp"), object: nil)
            }
        }
        
        gameManager.add(player)
        
        // Timer Callback
        gameManager.gameTimerSystem.onTimerExpired = { [weak self] in
             // Enable Hard Mode
             self?.gameManager.enemySpawnSystem.activateHardMode()
             
             // Visual Cue?
             self?.timerLabel.fontColor = .red
        }
        
        gameManager.gameTimerSystem.onGameEnd = { isVictory in
             NotificationCenter.default.post(name: NSNotification.Name("GameOver"), object: nil, userInfo: ["isVictory": isVictory])
        }
        
        // Spawn Test Enemies
        let enemy1 = EnemyEntity(color: .red, size: CGSize(width: 30, height: 30), health: 30)
        enemy1.component(ofType: SpriteComponent.self)?.node.position = CGPoint(x: 200, y: 0)
        gameManager.add(enemy1)
        
        let enemy2 = EnemyEntity(color: .red, size: CGSize(width: 30, height: 30), health: 30)
        enemy2.component(ofType: SpriteComponent.self)?.node.position = CGPoint(x: -200, y: 100)
        gameManager.add(enemy2)
        
        let enemy3 = EnemyEntity(color: .red, size: CGSize(width: 30, height: 30), health: 30)
        enemy3.component(ofType: SpriteComponent.self)?.node.position = CGPoint(x: 0, y: 200)
        gameManager.add(enemy3)
        
        // --- New Features Test ---
        
        // 1. Crucible Core
        let core = CrucibleCoreEntity(position: CGPoint(x: -200, y: 0), chargeTime: 3.0)
        gameManager.add(core)
        
        // 2. Hazard (Goo Pool)
        let goo = HazardEntity(position: CGPoint(x: 100, y: 100), type: .slow, value: 0.2, radius: 40) // 0.2x speed
        gameManager.add(goo)
        
        // 3. Destructible (Pot)
        let loot = [LootItem(type: .item("syringe"), value: 1, chance: 1.0)]
        let pot = DestructibleEntity(position: CGPoint(x: 100, y: -100), lootTable: loot)
        gameManager.add(pot)
    }

    private func setupJoystickNodes() {
        // Base
        let base = SKShapeNode(circleOfRadius: 50)
        base.strokeColor = .white
        base.lineWidth = 2
        base.alpha = 0.5
        base.isHidden = true
        // Important: Add to camera so it stays on screen, OR add to scene and move it. 
        // Adding to scene is easier for coordinate matching with touches unless we convert.
        // Let's add to scene for now but we might need to adjust position relative to camera if we want it fixed UI.
        // Actually, virtual joystick is mostly screen-space related. 
        // Since we have a camera, UI elements should ideally be children of the camera.
        cameraNode.addChild(base)
        self.joystickBase = base
        
        // Knob
        let knob = SKShapeNode(circleOfRadius: 20)
        knob.fillColor = .white
        knob.alpha = 0.8
        knob.isHidden = true
        cameraNode.addChild(knob)
        self.joystickKnob = knob
        
        // Line
        let line = SKShapeNode()
        line.strokeColor = .white
        line.lineWidth = 1
        line.alpha = 0.5
        line.isHidden = true
        cameraNode.addChild(line)
        self.joystickLine = line
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }

        var deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Cap DeltaTime to prevent time skipping after pause/lag
        if deltaTime > 0.1 {
            deltaTime = 0.1
        }
        
        // Update player velocity from joystick
        if let player = player,
           let movement = player.component(ofType: MovementComponent.self),
           let sprite = player.component(ofType: SpriteComponent.self) {
            movement.velocity = virtualJoystick.velocity
            
            // Camera Follow
            cameraNode.position = sprite.node.position
            
            // Update Debug Radius Position
            pickupRadiusNode?.position = sprite.node.position
        }

        gameManager.update(deltaTime)
        
        // Update Timer UI
        let time = gameManager.gameTimerSystem.timeRemaining
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
        // Update Health UI
        if let player = player,
           let healthComp = player.component(ofType: HealthComponent.self) {
            let hpParams = CGFloat(healthComp.currentHealth) / CGFloat(healthComp.maxHealth)
            let clampedHP = max(0, min(1.0, hpParams))
            // Scale bar width. SKShapeNode rectOf is centered, so scaling X scales from center.
            // Better to use path or anchor, but for quick hack:
            // SKShapeNode doesn't have an anchor point in the same way. 
            // We can change xscale.
            healthBar?.xScale = clampedHP
            
            // Color change
            if clampedHP < 0.3 {
                healthBar?.fillColor = .red
            } else {
                healthBar?.fillColor = .green
            }
            
            // Text Update
            healthLabel?.text = "\(healthComp.currentHealth) / \(healthComp.maxHealth)"
        }
        
        // Update EXP UI
        if let player = player,
           let expComp = player.component(ofType: ExperienceComponent.self) {
            let ratio = CGFloat(expComp.currentExp) / CGFloat(expComp.expToNextLevel)
            let clampedRatio = max(0, min(1.0, ratio))
            expBar?.xScale = clampedRatio
        }
    }
    
    // MARK: - Touch Handling & Joystick Vis Updates
    
    // Helper to convert Scene Touch to Camera Space (UI Space)
    private func locationInCamera(_ touch: UITouch) -> CGPoint {
        // location(in: self) gives scene coords (world).
        // location(in: cameraNode) gives coords relative to camera center.
        return touch.location(in: cameraNode)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let locationCamera = locationInCamera(touch)
        
        // Check UI Touches (Health Bar)
        if let healthBg = healthBarBackground, healthBg.contains(locationCamera) {
             NotificationCenter.default.post(name: NSNotification.Name("ShowStats"), object: nil)
             return
        }
    
        // Logic for Joystick Input (still used .location(in: self) originally? No, virtual joystick logic usually wants screen relative or start-relative.)
        // But our VirtualJoystick class just takes points. If we use world coordinates, it works fine UNTIL the camera moves.
        // If the camera moves while dragging, the "current point" in world space changes even if finger doesn't move on screen.
        // FIX: Use location in camera (screen space) for joystick logic.
        let location = locationInCamera(touch)
        virtualJoystick.start(at: location)
        
        // Update Vis
        joystickBase?.position = location
        joystickBase?.isHidden = false
        
        joystickKnob?.position = location
        joystickKnob?.isHidden = false
        
        joystickLine?.isHidden = false
        updateJoystickLine(start: location, end: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = locationInCamera(touch)
        virtualJoystick.move(to: location)
        
        // Visuals
        // Current position of joystick knob is stored in virtualJoystick.currentPosition
        // But wait, virtualJoystick logic might clamp the position.
        // We should read back from virtualJoystick
        
        let clampedParams = virtualJoystick.currentPosition 
        // Note: VirtualJoystick stores whatever we passed in "start" as origin. If we passed camera-space, it stores camera space.
        
        joystickKnob?.position = clampedParams
        
        if let origin = joystickBase?.position {
            updateJoystickLine(start: origin, end: clampedParams)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        virtualJoystick.stop()
        hideJoystick()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        virtualJoystick.stop()
        hideJoystick()
    }
    
    private func hideJoystick() {
        joystickBase?.isHidden = true
        joystickKnob?.isHidden = true
        joystickLine?.isHidden = true
    }
    
    private func updateJoystickLine(start: CGPoint, end: CGPoint) {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        joystickLine?.path = path
    }
}
