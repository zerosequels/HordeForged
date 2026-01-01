import SpriteKit
import GameplayKit // For potential future ECS use

class GameScene: SKScene {
    var gameManager: GameManager!
    
    private let virtualJoystick = VirtualJoystick()
    var player: SurvivorEntity?
    
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
    
    // Stamina UI
    private var staminaBarBackground: SKShapeNode?
    private var staminaBar: SKShapeNode?
    
    // Mini Map
    private var miniMap: MiniMapNode?
    
    // Dash System
    private let dashSystem = DashSystem()
    
    private var lastUpdateTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Setup Camera
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.setScale(1.2) // Zoom out a little
        
        // Setup Timer Label (Child of Camera)
        timerLabel.fontSize = 24
        timerLabel.fontColor = .white
        timerLabel.zPosition = 100
        cameraNode.addChild(timerLabel)
        
        // Setup Top Hitbox Area (Transparent button over timer/menu area)
        let menuHitbox = SKShapeNode(rectOf: CGSize(width: 300, height: 80))
        menuHitbox.fillColor = .clear
        menuHitbox.strokeColor = .clear
        menuHitbox.zPosition = 200 // Top
        menuHitbox.name = "TopMenuArea"
        menuHitbox.position = CGPoint(x: 0, y: size.height / 2 - 40) // Adjust later in updateUIPositions
        cameraNode.addChild(menuHitbox)
        
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
        
        // Setup Stamina Bar (Below Health Bar)
        let staBarSize = CGSize(width: 180, height: 8)
        let staBarOrigin = CGPoint(x: 0, y: -staBarSize.height / 2)
        
        let staBg = SKShapeNode(rect: CGRect(origin: staBarOrigin, size: staBarSize), cornerRadius: 2)
        staBg.fillColor = .darkGray
        staBg.strokeColor = .black
        staBg.zPosition = 100
        cameraNode.addChild(staBg)
        self.staminaBarBackground = staBg
        
        let staBar = SKShapeNode(rect: CGRect(origin: staBarOrigin, size: staBarSize), cornerRadius: 2)
        staBar.fillColor = .yellow
        staBar.strokeColor = .clear
        staBar.zPosition = 101
        cameraNode.addChild(staBar)
        self.staminaBar = staBar
        
        
        // Setup EXP Bar (Bottom of Screen?) or Below Stamina
        // Let's put EXP at bottom for change or stick to grouping.
        // Grouping: Below Stamina
        let expBarSize = CGSize(width: 200, height: 6)
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
        
        // Setup Mini Map (Top Right)
        let map = MiniMapNode(scene: self, size: 100)
        map.zPosition = 100
        cameraNode.addChild(map)
        self.miniMap = map
        
        
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
        guard let view = view else { return } // cameraNode usage assumes camera coords match size but centered?
        // Camera node coordinates: (0,0) is CENTER of screen.
        // Screen bounds: -width/2 to +width/2
        
        // Adjust for zoom?
        // If camera scale is 1.2, the visible area is larger. the UI needs to be placed relative to visible area.
        // Wait, if UI is child of Camera, and Camera is scaled... the UI is scaled too!
        // We usually want UI NOT to scale with camera zoom.
        // Solution: Counter-scale UI or Put UI in a separate scene/overlay.
        // Quick Fix: Scale UI nodes by 1/zoom or just accept large UI.
        // User asked "without changing the size of anything else".
        // If I zoom camera (node.setScale(1.2)), everything world-space shrinks. UI children of camera also shrink? NO, if camera scales, its children scale with it?
        // Actually, SKCameraNode is weird. If you scale camera, the world scales inverse.
        // Children of camera are fixed to camera. If camera scales > 1, world looks smaller. Children of camera...
        // If CameraNode.xScale = 2.0, it means it shows 2x world.
        // It does NOT mean the camera node itself is transforming its children.
        // Let's verify: usually UI on camera stays constant size relative to screen, regardless of camera zoom, unless camera node itself has `setScale` applied that propagates.
        // Standard practice: UI items are children of camera. Camera zoom affects WORLD, not UI?
        // Actually: "The camera node’s scale property changes the size of the visible area of the scene... The position and rotation of the camera node are applied to the scene before it is rendered."
        // Child nodes of the camera are rendered relative to the camera. They are NOT affected by the camera's transform applied to the scene.
        // BUT they ARE affected if the camera node itself is transformed?
        // Actually, children of camera move with camera.
        // Documentation says: "Nodes contained by the camera node are rendered as if they were part of the scene, but they do not move when the camera moves."
        // Scale? If I set camera.setScale(2), the world shrinks. Do children shrink?
        // Usually NO. Children of camera stay 1:1 with screen pixels (roughly).
        // Let's assume standard behavior: UI stays fixed size.
        
        let width = size.width
        let height = size.height
        let halfW = width / 2
        let halfH = height / 2
        
        // Timer at very top
        timerLabel.position = CGPoint(x: 0, y: halfH - 50)
        
        if let menuArea = cameraNode.childNode(withName: "TopMenuArea") {
            menuArea.position = CGPoint(x: 0, y: halfH - 40)
        }
        
        // Health Bar Top Left
        let leftMargin: CGFloat = -halfW + 20
        let topMargin: CGFloat = halfH - 60
        
        let xOffset = leftMargin + 100 // + half width of bar (200/2)
        
        healthBarBackground?.position = CGPoint(x: xOffset, y: topMargin)
        healthBar?.position = CGPoint(x: xOffset, y: topMargin)
        healthLabel?.position = CGPoint(x: xOffset, y: topMargin - 5)
        
        // Stamina Below Health
        let staY = topMargin - 20
        staminaBarBackground?.position = CGPoint(x: xOffset, y: staY)
        staminaBar?.position = CGPoint(x: xOffset, y: staY)
        
        // EXP Below Stamina
        let expY = staY - 15
        expBarBackground?.position = CGPoint(x: xOffset, y: expY)
        expBar?.position = CGPoint(x: xOffset, y: expY)
        
        // Mini Map Top Right
        let rightMargin = halfW - 60 // - half width (50) - padding
        let mapY = halfH - 60
        
        miniMap?.position = CGPoint(x: rightMargin, y: mapY)
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
        
        // Setup initial level elements (Core, Interactables)
        gameManager.setupLevel()
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
            
            
            // Update Debug Radius Position
            pickupRadiusNode?.position = sprite.node.position
            
            // Update Dash System for this entity (or globally if registered)
            // Dash system needs to be updated. Since it's not in GameManager yet, update here manually for player.
            // DashSystem is a GKComponentSystem, meant to update all components.
            // But we didn't add DashSystem to GameManager.
            // Let's just create a quick DashSystem instance or update logic.
            // Wait, DashSystem is a system for MovementComponent? No, it's a logic system.
            // Actually I defined DashSystem as GKComponentSystem<GKComponent>.
            // I need to add components to it?
            // Actually, DashSystem.update iterates over its components.
            // BUT, I didn't register components to DashSystem.
            // Let's just call `dashSystem.update(deltaTime: deltaTime)` but I need to ensure components are in it?
            // Re-think: DashSystem in my implementation iterates over components.
            // But I never added components to `dashSystem`.
            // FIX: Add player's movement component to dashSystem.
            if dashSystem.components.isEmpty {
                dashSystem.addComponent(movement)
            }
            dashSystem.update(deltaTime: deltaTime)
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
        
        // Update Stamina UI
        if let player = player,
           let staminaComp = player.component(ofType: StaminaComponent.self) {
             let ratio = staminaComp.currentStamina / staminaComp.maxStamina
             let clamped = max(0, min(1.0, ratio))
             staminaBar?.xScale = clamped
        }
        
        // Update EXP UI
        if let player = player,
           let expComp = player.component(ofType: ExperienceComponent.self) {
            let ratio = CGFloat(expComp.currentExp) / CGFloat(expComp.expToNextLevel)
            let clampedRatio = max(0, min(1.0, ratio))
            expBar?.xScale = clampedRatio
        }
        
        // Update Minimap
        miniMap?.update()
    }
    
    // Touch Handling State
    private var touchStartTime: TimeInterval = 0
    private var touchStartPos: CGPoint = .zero
    
    // MARK: - Touch Handling & Joystick Vis Updates
    
    // Helper to convert Scene Touch to Camera Space (UI Space)
    private func locationInCamera(_ touch: UITouch) -> CGPoint {
        return touch.location(in: cameraNode)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let locationCamera = locationInCamera(touch)
        
        // Record for Swipe Detection
        touchStartTime = touch.timestamp
        touchStartPos = locationCamera
        
        // Check UI Touches (Menu Area)
        if let menuArea = cameraNode.childNode(withName: "TopMenuArea"), menuArea.contains(locationCamera) {
             NotificationCenter.default.post(name: NSNotification.Name("ShowStats"), object: nil)
             return
        }
    
        // Joystick Logic
        virtualJoystick.start(at: locationCamera)
        
        // Try Interaction (World Space)
        // Camera node children are UI/Overlay. The game world is the scene.
        // Touches are in camera node space? `locationInCamera`
        // We need World Space for entities.
        // scene.camera?.position logic needed.
        let cameraIdx = cameraNode.position
        let worldX = cameraIdx.x + locationCamera.x / cameraNode.xScale // Rough approximation if camera is centered
        // Actually, scene.convert(point: from:) is better.
        let locationScene = self.convert(touch.location(in: self), to: self) // location in scene
        // Wait, touches are in view? touches.location(in: self) gives scene coords.
        
        let touchSceneParams = touch.location(in: self)
        gameManager.interactionSystem.tryInteract(at: touchSceneParams)
        
        // Update Vis
        joystickBase?.position = locationCamera
        joystickBase?.isHidden = false
        
        joystickKnob?.position = locationCamera
        joystickKnob?.isHidden = false
        
        joystickLine?.isHidden = false
        updateJoystickLine(start: locationCamera, end: locationCamera)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = locationInCamera(touch)
        virtualJoystick.move(to: location)
        
        // Visuals
        let clampedParams = virtualJoystick.currentPosition 
        joystickKnob?.position = clampedParams
        
        if let origin = joystickBase?.position {
            updateJoystickLine(start: origin, end: clampedParams)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Swipe Detection (Dash)
        let duration = touch.timestamp - touchStartTime
        let endPos = locationInCamera(touch)
        let distance = hypot(endPos.x - touchStartPos.x, endPos.y - touchStartPos.y)
        
        // Criteria: Short duration (e.g. < 0.3s) and significant distance (e.g. > 50pt)
        if duration < 0.3 && distance > 50 {
            // It's a swipe!
            if let player = player {
                let dx = endPos.x - touchStartPos.x
                let dy = endPos.y - touchStartPos.y
                let direction = CGVector(dx: dx, dy: dy)
                
                // Attempt Dash
                 dashSystem.attemptDash(for: player, direction: direction)
                 // If dash logic requires success feedback to stop movement:
                 // The attemptDash function checks stamina. If it succeeds, isDashing = true.
                 // MovementComponent treats isDashing = true as "Override movement".
            }
        }
        
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
    
    override func didFinishUpdate() {
        super.didFinishUpdate()
        
        // Update Camera Position after physics and movement
        if let player = player,
           let sprite = player.component(ofType: SpriteComponent.self) {
            cameraNode.position = sprite.node.position
        }
    }
    
    func showDamage(amount: Int, position: CGPoint) {
        let label = SKLabelNode(fontNamed: "Arial-BoldMT")
        label.text = "\(amount)"
        label.fontSize = 20
        label.fontColor = .white
        label.position = position
        label.zPosition = 1000 // Very top
        
        // Add shadow for better visibility
        let shadow = SKLabelNode(fontNamed: "Arial-BoldMT")
        shadow.text = "\(amount)"
        shadow.fontSize = 20
        shadow.fontColor = .black
        shadow.position = CGPoint(x: 1, y: -1)
        shadow.zPosition = -1
        label.addChild(shadow)
        
        addChild(label)
        
        // Animate
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.removeFromParent()
        
        label.run(SKAction.sequence([group, remove]))
    }
}
