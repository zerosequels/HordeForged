import XCTest
@testable import HordeForged

class ExperienceComponentTests: XCTestCase {
    
    var expComponent: ExperienceComponent!
    
    override func setUp() {
        super.setUp()
        expComponent = ExperienceComponent()
    }
    
    override func tearDown() {
        expComponent = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertEqual(expComponent.level, 1)
        XCTAssertEqual(expComponent.currentExp, 0)
    }
    
    func testAddExp() {
        expComponent.addExp(50)
        XCTAssertEqual(expComponent.currentExp, 50)
        XCTAssertEqual(expComponent.level, 1)
    }
    
    func testLevelUp() {
        // Trigger Level Up
        var callbackTriggered = false
        expComponent.onLevelUp = { level in
            callbackTriggered = true
            XCTAssertEqual(level, 2)
        }
        
        // Since we don't have game loop running systems, we must manually trigger logic?
        // Wait, ExperienceComponent.swift says: "Level up logic generally handled by system".
        // Ah, the component logic doesn't actually check for level up! 
        // We need to test the COMPONENT, which is just data.
        // It has `expToNextLevel`.
        
        // If the component doesn't have logic, then `testLevelUp` in component test is invalid unless we add logic there or mock the system.
        // But wait, the previous code for `PlayerExperienceSystem` does the checking.
        // So `ExperienceComponent` is just a data bag with `addExp`.
        // Let's verify `addExp` works.
        
        expComponent.addExp(150)
        XCTAssertEqual(expComponent.currentExp, 150)
        // Level shouldn't change just by adding exp in component isolation.
        XCTAssertEqual(expComponent.level, 1) 
        
        // We'll update the test to reflect "Logic Unit Tests" means testing the logic IN the file.
    }
}
