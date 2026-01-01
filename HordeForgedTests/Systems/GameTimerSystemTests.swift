import XCTest
import SpriteKit
internal import GameplayKit
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
    
    func testTimerExpiration() {
        // Fast forward
        timerSystem.timeRemaining = 0.5
        
        var expiredTriggered = false
        timerSystem.onTimerExpired = {
            expiredTriggered = true
        }
        
        timerSystem.update(deltaTime: 1.0)
        
        XCTAssertTrue(expiredTriggered, "Timer expiration should trigger callback")
        XCTAssertLessThanOrEqual(timerSystem.timeRemaining, 0)
        XCTAssertFalse(timerSystem.isGameOver, "Timer expiration should NOT automatically end game (Hard Mode trigger)")
    }
    
    func testStopUpdatingAfterGameOver() {
        timerSystem.isGameOver = true
        let time = timerSystem.timeRemaining
        
        timerSystem.update(deltaTime: 10.0)
        
        XCTAssertEqual(timerSystem.timeRemaining, time) // Should not change
    }
}
