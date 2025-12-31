import XCTest
import SpriteKit
@testable import HordeForged

class GameTimerSystemTests: XCTestCase {
    
    var timerSystem: GameTimerSystem!
    
    override func setUp() {
        super.setUp()
        timerSystem = GameTimerSystem()
        // Reset default time for testing if needed, though we test logic
        timerSystem.timeRemaining = 60 // Set to known value
    }
    
    override func tearDown() {
        timerSystem = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertFalse(timerSystem.isGameOver)
    }
    
    func testUpdatesTime() {
        timerSystem.update(deltaTime: 1.0)
        XCTAssertEqual(timerSystem.timeRemaining, 59.0)
    }
    
    func testGameOverCondition() {
        // Fast forward
        timerSystem.timeRemaining = 0.5
        
        var victoryTriggered = false
        timerSystem.onGameEnd = { isVictory in
            victoryTriggered = isVictory
        }
        
        timerSystem.update(deltaTime: 1.0)
        
        XCTAssertTrue(timerSystem.isGameOver)
        XCTAssertTrue(victoryTriggered) // Time running out = Victory in this game
        XCTAssertLessThanOrEqual(timerSystem.timeRemaining, 0)
    }
    
    func testStopUpdatingAfterGameOver() {
        timerSystem.isGameOver = true
        let time = timerSystem.timeRemaining
        
        timerSystem.update(deltaTime: 10.0)
        
        XCTAssertEqual(timerSystem.timeRemaining, time) // Should not change
    }
}
