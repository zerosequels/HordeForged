import SwiftUI
import UIKit
import SpriteKit
import GameplayKit

// MARK: - GameViewController

class GameViewController: UIViewController {
    
    var skView: SKView!
    var hostingController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        skView = SKView()
        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.accessibilityIdentifier = "GameSKView" // Set accessibility identifier for UI testing
        self.view.addSubview(skView)

        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: self.view.topAnchor),
            skView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            skView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])

        // Present the GameScene
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
        // Listen for Level Up Notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleLevelUp), name: NSNotification.Name("LevelUp"), object: nil)
        
        // Listen for Game Over Notification
        // Listen for Game Over Notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameOver(_:)), name: NSNotification.Name("GameOver"), object: nil)
        
        // Listen for Stats Menu Notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowStats), name: NSNotification.Name("ShowStats"), object: nil)
        
        // Listen for Item Pickup Notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleItemPickup(_:)), name: NSNotification.Name("ItemPickup"), object: nil)
    }
    
    @objc func handleItemPickup(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let item = userInfo["item"] as? ItemDefinition,
              let count = userInfo["count"] as? Int else { return }
        
        // Pause Game
        skView.isPaused = true
        
        // Show UI
        let itemView = ItemPickupView(item: item, count: count) { [weak self] in
            // Dismiss Callback
            self?.resumeGame()
        }
        
        let controller = UIHostingController(rootView: itemView)
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
        self.hostingController = controller
    }
    
    @objc func handleShowStats() {
        // Find Player Inventory
        guard let scene = skView.scene as? GameScene,
              let player = scene.gameManager.entities.first(where: { $0 is SurvivorEntity }),
              let inventory = player.component(ofType: InventoryComponent.self) else {
            return
        }
        
        // Pause Game
        skView.isPaused = true
        
        // Show UI
        let playerStats = PlayerStats(attackSpeed: inventory.attackSpeedMultiplier,
                                      moveSpeed: inventory.movementSpeedMultiplier,
                                      damage: inventory.damageMultiplier)
                                      
        let statsView = StatsView(activeAbilities: inventory.activeAbilities,
                                  passiveAbilities: inventory.passiveAbilities,
                                  items: inventory.items,
                                  stats: playerStats) { [weak self] in
            // Dismiss Callback
            self?.resumeGame()
        }
        
        let controller = UIHostingController(rootView: statsView)
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
        self.hostingController = controller
    }

    @objc func handleGameOver(_ notification: Notification) {
        // Pause Game
        skView.isPaused = true
        
        let isVictory = notification.userInfo?["isVictory"] as? Bool ?? false
        
        // Show UI
        let gameOverView = GameOverView(isVictory: isVictory) { [weak self] in
            self?.restartGame()
        }
        
        let controller = UIHostingController(rootView: gameOverView)
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
        self.hostingController = controller // Reuse property or rename if strictly typed? 
        // hostingController is typed to LevelUpView. need to change type or make it generic/any.
        // Quick fix: make hostingController generic UIViewController or just let it exist locally since present retains it. 
        // Actually, we might need a separate property if we want to dismiss it programmatically, but here the view dismisses itself via callback (conceptually).
        // Let's rely on local variable for now as 'present' retains it.
    }
    
    func restartGame() {
        self.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            
            // Restart Scene
             let scene = GameScene(size: self.view.bounds.size)
             scene.scaleMode = .resizeFill
             self.skView.presentScene(scene)
             self.skView.isPaused = false
        })
    }

    var pendingLevelUps = 0
    var isLevelUpActive = false // To prevent double presentation if notifications overlap before queue check

    @objc func handleLevelUp() {
        pendingLevelUps += 1
        if !isLevelUpActive {
             presentNextLevelUp()
        }
    }
    
    func presentNextLevelUp() {
        guard pendingLevelUps > 0 else {
            resumeGame()
            return
        }
        
        isLevelUpActive = true
        
        // Find Player Inventory
        guard let scene = skView.scene as? GameScene,
              let player = scene.gameManager.entities.first(where: { $0 is SurvivorEntity }),
              let inventory = player.component(ofType: InventoryComponent.self) else {
            isLevelUpActive = false
            pendingLevelUps = 0
            return
        }

        // Pause Game
        skView.isPaused = true
        
        // Get Options
        let rawOptions = ProgressionManager.shared.getUpgradeOptions(for: inventory)
        
        let options = rawOptions.map { def -> UpgradeOption in
            if let existing = inventory.hasAbility(def) {
                return UpgradeOption(definition: def, currentLevel: existing.level, nextLevel: existing.level + 1)
            } else {
                return UpgradeOption(definition: def, currentLevel: 0, nextLevel: 1)
            }
        }
        
        // Show UI
        let levelUpView = LevelUpView(options: options) { [weak self] selectedAbility in
            // Apply Selection
            inventory.addAbility(selectedAbility)
            
            // Handle Queue
            self?.pendingLevelUps -= 1
            
            self?.dismiss(animated: false, completion: {
                if self?.pendingLevelUps ?? 0 > 0 {
                    self?.presentNextLevelUp()
                } else {
                    self?.isLevelUpActive = false // Done
                    self?.resumeGame() // Actually resume
                }
            })
        }
        
        let controller = UIHostingController(rootView: levelUpView)
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
        self.hostingController = controller
    }
    
    func resumeGame() {
        // Dismiss UI if presented (generic)
        if presentedViewController != nil {
             self.dismiss(animated: true, completion: { [weak self] in
                 self?.skView.isPaused = false
                 self?.hostingController = nil
             })
        } else {
             self.skView.isPaused = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let skView = self.skView, skView.scene != nil {
             skView.scene?.size = skView.bounds.size
        }
    }
}

// MARK: - GameViewRepresentable (Bridge SwiftUI to UIKit)

struct GameViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        return GameViewController()
    }

    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        // Update the view controller if needed
    }
}
