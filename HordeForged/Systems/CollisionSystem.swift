import GameplayKit
import SpriteKit

class CollisionSystem: GKComponentSystem<GKComponent> {
    
    weak var scene: SKScene?
    private var lastDamageTime: TimeInterval = 0
    private let damageCooldown: TimeInterval = 0.5 // 0.5s invulnerability
    
    init(scene: SKScene) {
        self.scene = scene
        super.init(componentClass: GKComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // Simple O(N^2) collision detection for now
        guard let gameScene = scene as? GameScene else { return }
        
        // Get all Entities
        let entities = gameScene.gameManager.entities
        
        let projectiles = entities.filter { $0 is ProjectileEntity }
        let enemies = entities.filter { $0 is EnemyEntity }
        let orbs = entities.filter { $0 is ExpOrbEntity }
        
        // 1) Projectile vs Enemy
        for projectile in projectiles {
            guard let projSprite = projectile.component(ofType: SpriteComponent.self),
                  let damageComp = projectile.component(ofType: DamageComponent.self) else { continue }
            
            for enemy in enemies {
                guard let enemySprite = enemy.component(ofType: SpriteComponent.self),
                      let healthComp = enemy.component(ofType: HealthComponent.self) else { continue }
                
                if projSprite.node.frame.intersects(enemySprite.node.frame) {
                    // Apply Damage via Manager (Handles visuals + death)
                    gameScene.gameManager.applyDamage(target: enemy, amount: damageComp.damageAmount)
                    
                    // Remove Projectile
                    gameScene.gameManager.remove(projectile)
                    
                    break
                }
            }
        }
        
        // 2) Player Logic (Collection & Damage)
        guard let player = entities.first(where: { $0 is SurvivorEntity }),
              let playerSprite = player.component(ofType: SpriteComponent.self),
              let playerHealth = player.component(ofType: HealthComponent.self) else { return }
              
        let now = Date().timeIntervalSince1970
        
        // Enemy Damage Check
        if lastDamageTime + damageCooldown < now {
            var tookDamage = false
            let contactDistance: CGFloat = 30.0
            
            for enemy in enemies {
                guard let enemySprite = enemy.component(ofType: SpriteComponent.self) else { continue }
                
                let dx = playerSprite.node.position.x - enemySprite.node.position.x
                let dy = playerSprite.node.position.y - enemySprite.node.position.y
                let dist = hypot(dx, dy)
                
                if dist < contactDistance {
                    playerHealth.currentHealth -= 10
                    tookDamage = true
                    break
                }
            }
            
            if tookDamage {
                lastDamageTime = now
            }
        }
        
        // Orb Collection (Magnet)
        let pickupRadius: CGFloat = 100.0
        let collectionRadius: CGFloat = 20.0
        let magnetSpeed: CGFloat = 300.0
        
        for orb in orbs {
            guard let orbSprite = orb.component(ofType: SpriteComponent.self),
                  let expValue = orb.component(ofType: ExpValueComponent.self) else { continue }
            
            let dx = playerSprite.node.position.x - orbSprite.node.position.x
            let dy = playerSprite.node.position.y - orbSprite.node.position.y
            let dist = hypot(dx, dy)
            
            // Magnet
            if dist < pickupRadius {
                let normalizedDx = dx / dist
                let normalizedDy = dy / dist
                let moveAmount = CGFloat(seconds) * magnetSpeed
                
                let newX = orbSprite.node.position.x + normalizedDx * moveAmount
                let newY = orbSprite.node.position.y + normalizedDy * moveAmount
                
                orbSprite.node.position = CGPoint(x: newX, y: newY)
            }
            
            // Collect
            if dist < collectionRadius {
                if let expComp = player.component(ofType: ExperienceComponent.self) {
                    expComp.addExp(expValue.value)
                }
                gameScene.gameManager.remove(orb)
            }
        }
        // 3) Projectile vs Destructible
        let destructibles = entities.filter { $0 is DestructibleEntity }
        for projectile in projectiles {
            guard let projSprite = projectile.component(ofType: SpriteComponent.self),
                  let damageComp = projectile.component(ofType: DamageComponent.self) else { continue }
            
            // Optimization: If projectile is already removed by enemy collision, skip?
            // Current logic checks projectiles multiple times. 
            // Better to have a unified projectile collision pass, but filtering is okay for now.
            if gameScene.gameManager.entities.contains(projectile) == false { continue }

            for pot in destructibles {
                guard let potSprite = pot.component(ofType: SpriteComponent.self),
                      let healthComp = pot.component(ofType: HealthComponent.self) else { continue }
                
                if projSprite.node.frame.intersects(potSprite.node.frame) {
                     healthComp.currentHealth -= damageComp.damageAmount
                     gameScene.gameManager.remove(projectile)
                     
                     if healthComp.currentHealth <= 0 {
                         // Loot Drop
                         if let lootComp = pot.component(ofType: LootComponent.self) {
                             self.spawnLoot(from: lootComp, position: potSprite.node.position, gameScene: gameScene)
                         }
                         gameScene.gameManager.remove(pot)
                     }
                     break
                }
            }
        }

        // 4) Player vs Hazard
        guard let player = entities.first(where: { $0 is SurvivorEntity }),
              let playerSprite = player.component(ofType: SpriteComponent.self),
              let playerHealth = player.component(ofType: HealthComponent.self) else { return } // Should satisfy this guard from block 2
        
        // Reset Speed Modifier (default 1.0)
        let playerMove = player.component(ofType: MovementComponent.self)
        playerMove?.speedModifier = 1.0
        
        let hazards = entities.filter { $0 is HazardEntity }
        for hazard in hazards {
            guard let hazSprite = hazard.component(ofType: SpriteComponent.self),
                  let hazComp = hazard.component(ofType: HazardComponent.self) else { continue }
            
            if hazSprite.node.frame.intersects(playerSprite.node.frame) {
                if hazComp.type == .slow {
                    playerMove?.speedModifier = hazComp.value
                } else if hazComp.type == .damage {
                     if lastDamageTime + damageCooldown < Date().timeIntervalSince1970 {
                         playerHealth.currentHealth -= Int(hazComp.value)
                         lastDamageTime = Date().timeIntervalSince1970
                     }
                }
            }
        }
        
        // 5) Player vs Crucible Core (Charging & Portal)
        let cores = entities.filter { $0 is CrucibleCoreEntity }
        for core in cores {
             guard let coreSprite = core.component(ofType: SpriteComponent.self),
                   let chargeComp = core.component(ofType: ChargeComponent.self) else { continue }
            
            let dx = playerSprite.node.position.x - coreSprite.node.position.x
            let dy = playerSprite.node.position.y - coreSprite.node.position.y
            let dist = hypot(dx, dy)
            let chargeRadius: CGFloat = 100.0 // Interaction radius

            if dist < chargeRadius {
                 // Charging Interaction
                 if chargeComp.state == .charging {
                     chargeComp.isCharging = true
                     chargeComp.addCharge(seconds)
                     
                     if chargeComp.state == .bossSummoned {
                          // Transiton happened this frame
                          gameScene.gameManager.spawnBoss(at: CGPoint(x: coreSprite.node.position.x, y: coreSprite.node.position.y + 200)) // Spawn above
                          gameScene.gameManager.enemySpawnSystem.endSwarm() // End swarm when boss appears
                     } else if chargeComp.currentCharge > chargeComp.maxCharge * 0.5 {
                          // Swarm during second half of charge
                          gameScene.gameManager.enemySpawnSystem.triggerSwarm()
                     }
                     
                     // Update Visual Bar
                     if let barFill = coreSprite.node.childNode(withName: "chargeBarFill") {
                         let pct = CGFloat(chargeComp.currentCharge / chargeComp.maxCharge)
                         barFill.xScale = max(0, min(1.0, pct))
                     }
                 }
                 else if chargeComp.state == .portalOpen {
                     // Portal Entry
                     if dist < 40 {
                         LevelManager.shared.nextLevel()
                     }
                 }
            } else {
                 if chargeComp.state == .charging {
                     chargeComp.isCharging = false
                     gameScene.gameManager.enemySpawnSystem.endSwarm() // Ensure swarm stops if player leaves
                 }
            }
            
            // Global State Logic (Run regardless of distance)
            if chargeComp.state == .bossSummoned {
                 chargeComp.isCharging = false
                 
                 // Check Boss Death
                 if let boss = gameScene.gameManager.activeBoss, !gameScene.gameManager.entities.contains(boss) {
                     // Boss Dead
                     chargeComp.setPortalOpen()
                     coreSprite.node.run(SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: 1.0))
                     
                     // Spawn Boss Loot
                     if let bossSprite = boss.component(ofType: SpriteComponent.self) {
                          let dropPos = bossSprite.node.position
                          
                          // Drop a Lens!
                          let pickup = ItemPickupEntity(itemID: DragonsEye.id, count: 1, position: dropPos)
                          gameScene.gameManager.add(pickup)
                          
                          // And lots of XP
                          let orb = ExpOrbEntity(value: 500, position: CGPoint(x: dropPos.x + 20, y: dropPos.y))
                          gameScene.gameManager.add(orb)
                     }
                     // Clear reference
                     gameScene.gameManager.activeBoss = nil 
                 }
            }
                    

        }
        // ... existing Charge Logic ...
    
        // 6) Player vs Item Pickups
        let itemPickups = entities.filter { $0 is ItemPickupEntity }
        for pickup in itemPickups {
            guard let pickupEntity = pickup as? ItemPickupEntity,
                  let pickupSprite = pickupEntity.component(ofType: SpriteComponent.self) else { continue }
            
             if pickupSprite.node.frame.intersects(playerSprite.node.frame) {
                 // Add to Inventory
                 if let inventory = player.component(ofType: InventoryComponent.self),
                    let itemDef = ProgressionManager.shared.allItems.first(where: { $0.id == pickupEntity.itemID }) {
                     inventory.addItem(itemDef, count: pickupEntity.count)
                     
                     // Get new count
                     let newCount = inventory.items[itemDef] ?? 0
                     
                     // Notify UI
                     let userInfo: [String: Any] = [
                        "item": itemDef,
                        "count": newCount
                     ]
                     NotificationCenter.default.post(name: NSNotification.Name("ItemPickup"), object: nil, userInfo: userInfo)
                 }
                 
                 // Remove Pickup
                 gameScene.gameManager.remove(pickupEntity)
             }
        }
    }
}
    
// Helper extension to handle loot spawning cleanly
extension CollisionSystem {
    func spawnLoot(from lootComp: LootComponent, position: CGPoint, gameScene: GameScene) {
        // Simple logic: Drop first item that rolls true
        for item in lootComp.lootTable {
            if Double.random(in: 0...1) <= item.chance {
                switch item.type {
                case .expOrb:
                     let orb = ExpOrbEntity(value: item.value, position: position)
                     gameScene.gameManager.add(orb)
                    
                case .item(let itemID):
                     let pickup = ItemPickupEntity(itemID: itemID, count: item.value, position: position)
                     gameScene.gameManager.add(pickup)
                    
                case .randomItem:
                    let itemDef = ProgressionManager.shared.getRandomItem()
                    let pickup = ItemPickupEntity(itemID: itemDef.id, count: item.value, position: position)
                    gameScene.gameManager.add(pickup)

                case .healthPotion:
                    // TODO: Implement Potion
                    break
                }
            }
        }
    }
}
