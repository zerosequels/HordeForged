import XCTest
internal import GameplayKit
@testable import HordeForged

class ProgressionSystemTests: XCTestCase {
    
    var inventory: InventoryComponent!
    
    override func setUp() {
        super.setUp()
        inventory = InventoryComponent()
        // Ensure database is set up
        _ = ProgressionManager.shared 
    }
    
    // MARK: - Inventory Logic Tests
    
    func testAddItemStacking() {
        let testItem = ItemDefinition(id: "test_item", name: "Test Item", description: "Tests stacking", rarity: .common, modifiers: [])
        
        inventory.addItem(testItem, count: 1)
        XCTAssertEqual(inventory.items[testItem], 1, "Item count should be 1")
        
        inventory.addItem(testItem, count: 2)
        XCTAssertEqual(inventory.items[testItem], 3, "Item count should stack to 3")
    }
    
    func testStatRecalculation() {
        // defined in ProgressionManager: Sigil: +15% AS
        let atkSpeedItem = ItemDefinition(id: "atk_test", name: "Speedup", description: "", rarity: .common, modifiers: [
            StatModifier(type: .attackSpeed, value: 0.1, isMultiplier: false)
        ])
        
        // Initial state
        XCTAssertEqual(inventory.attackSpeedMultiplier, 1.0)
        
        // Add 1
        inventory.addItem(atkSpeedItem)
        // 1.0 + 0.1 = 1.1
        XCTAssertEqual(inventory.attackSpeedMultiplier, 1.1, accuracy: 0.001)
        
        // Add 2 more (Total 3)
        inventory.addItem(atkSpeedItem, count: 2)
        // 1.0 + (0.1 * 3) = 1.3
        XCTAssertEqual(inventory.attackSpeedMultiplier, 1.3, accuracy: 0.001)
    }
    
    func testAbilityLimits() {
        // Create dummy definitions
        let a1 = AbilityDefinition(id: "a1", name: "A1", description: "", type: .active, rarity: .common, maxLevel: 1)
        let a2 = AbilityDefinition(id: "a2", name: "A2", description: "", type: .active, rarity: .common, maxLevel: 1)
        let a3 = AbilityDefinition(id: "a3", name: "A3", description: "", type: .active, rarity: .common, maxLevel: 1)
        let a4 = AbilityDefinition(id: "a4", name: "A4", description: "", type: .active, rarity: .common, maxLevel: 1)
        let a5 = AbilityDefinition(id: "a5", name: "A5", description: "", type: .active, rarity: .common, maxLevel: 1)
        
        inventory.addAbility(a1)
        inventory.addAbility(a2)
        inventory.addAbility(a3)
        inventory.addAbility(a4)
        
        XCTAssertEqual(inventory.activeAbilities.count, 4)
        XCTAssertTrue(inventory.canAddAbility(a1) == false, "Should not add duplicate if max level (1) reached, or just checking slot logic") 
        // Actually canAddAbility checks SLOTS.
        XCTAssertFalse(inventory.canAddAbility(a5), "Should return false if 4 slots full")
        
        inventory.addAbility(a5)
        XCTAssertEqual(inventory.activeAbilities.count, 4, "Should not have added 5th ability")
    }
    
    func testAbilityUpgrading() {
        let a1 = AbilityDefinition(id: "up_1", name: "Upgrade Me", description: "", type: .active, rarity: .common, maxLevel: 3)
        
        inventory.addAbility(a1)
        guard let instance = inventory.hasAbility(a1) else {
            XCTFail("Ability not added")
            return
        }
        XCTAssertEqual(instance.level, 1)
        
        // Add same ability again -> Upgrade
        inventory.addAbility(a1)
        XCTAssertEqual(instance.level, 2)
        
        inventory.addAbility(a1)
        XCTAssertEqual(instance.level, 3)
        
        // Check Max
        inventory.addAbility(a1)
        XCTAssertEqual(instance.level, 3, "Should not exceed max level")
    }
    
    // MARK: - Progression Manager Tests
    
    func testOptionsGeneration() {
        let manager = ProgressionManager.shared
        // Manager uses RNG, so precise testing is hard without mocking the randomizer.
        // However, we can assert structural constraints.
        
        let options = manager.getUpgradeOptions(for: inventory)
        XCTAssertTrue(options.count > 0, "Should return options")
        XCTAssertTrue(options.count <= 4, "Should not exceed 4 options")
        
        // Ensure no options are maxed out abilities?
        // Let's manually max out an ability and see if it appears.
        // This is flaky if RNG doesn't pick it anyway.
        // For logical unit tests, we usually rely on specific mocked scenarios.
        // Since we can't easily mock here without refactoring `shuffled()`, we'll skip deep RNG validation.
    }
}
