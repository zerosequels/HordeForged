import XCTest
import CoreGraphics
@testable import HordeForged

final class VirtualJoystickTests: XCTestCase {
    var joystick: VirtualJoystick!
    
    override func setUp() {
        super.setUp()
        joystick = VirtualJoystick()
    }
    
    func testStartSetsOriginAndActive() {
        let startPoint = CGPoint(x: 100, y: 100)
        joystick.start(at: startPoint)
        
        XCTAssertEqual(joystick.origin, startPoint)
        XCTAssertTrue(joystick.isActive)
        // Current position should reset to origin on start
        XCTAssertEqual(joystick.currentPosition, startPoint)
    }
    
    func testMoveUpdatesPosition() {
        joystick.start(at: .zero)
        let movePoint = CGPoint(x: 50, y: 0)
        joystick.move(to: movePoint)
        
        XCTAssertEqual(joystick.currentPosition, movePoint)
    }
    
    func testStopResetsJoystick() {
        joystick.start(at: .zero)
        joystick.move(to: CGPoint(x: 50, y: 50))
        joystick.stop()
        
        XCTAssertFalse(joystick.isActive)
        XCTAssertEqual(joystick.velocity, .zero)
    }
    
    func testVelocityCalculation() {
        joystick.maxRadius = 100
        joystick.start(at: .zero)
        
        // Move 50 units right -> (0.5, 0)
        joystick.move(to: CGPoint(x: 50, y: 0))
        
        XCTAssertEqual(joystick.velocity.dx, 0.5, accuracy: 0.001)
        XCTAssertEqual(joystick.velocity.dy, 0.0, accuracy: 0.001)
        
        // Move 100 units up -> (0, 1.0)
        joystick.move(to: CGPoint(x: 0, y: 100))
        XCTAssertEqual(joystick.velocity.dx, 0.0, accuracy: 0.001)
        XCTAssertEqual(joystick.velocity.dy, 1.0, accuracy: 0.001)
        
        // Move 200 units left -> (-1.0, 0) (Clamped)
        joystick.move(to: CGPoint(x: -200, y: 0))
        XCTAssertEqual(joystick.velocity.dx, -1.0, accuracy: 0.001)
        XCTAssertEqual(joystick.velocity.dy, 0.0, accuracy: 0.001)
    }
}
