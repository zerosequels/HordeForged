import XCTest
@testable import HordeForged

class HealthComponentTests: XCTestCase {
    
    var healthComponent: HealthComponent!
    
    override func setUp() {
        super.setUp()
        healthComponent = HealthComponent(maxHealth: 100)
    }
    
    override func tearDown() {
        healthComponent = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertEqual(healthComponent.maxHealth, 100)
        XCTAssertEqual(healthComponent.currentHealth, 100)
    }
    
    func testDamage() {
        healthComponent.currentHealth -= 20
        XCTAssertEqual(healthComponent.currentHealth, 80)
    }
    
    func testOverDamage() {
        healthComponent.currentHealth -= 150
        // Depending on logic, it might go negative or cap at 0. 
        // Our current implementation allows negative, but logically for "Death" check usually <= 0.
        // Let's assert it goes to -50 based on simple subtraction logic seen earlier.
        XCTAssertEqual(healthComponent.currentHealth, -50)
    }
    
    func testHealing() {
        healthComponent.currentHealth = 50
        healthComponent.currentHealth += 30
        XCTAssertEqual(healthComponent.currentHealth, 80)
    }
    
    // Note: If we had a 'heal' method that capped at maxHealth, we would test that too.
    // Currently logic is public property modification.
}
