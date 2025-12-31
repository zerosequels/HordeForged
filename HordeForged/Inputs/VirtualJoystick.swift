import CoreGraphics

class VirtualJoystick {
    var origin: CGPoint = .zero
    var currentPosition: CGPoint = .zero
    var maxRadius: CGFloat = 100.0
    var isActive: Bool = false
    
    var velocity: CGVector {
        guard isActive, maxRadius > 0 else { return .zero }
        let dx = currentPosition.x - origin.x
        let dy = currentPosition.y - origin.y
        return CGVector(dx: dx / maxRadius, dy: dy / maxRadius)
    }
    
    func start(at point: CGPoint) {
        isActive = true
        origin = point
        currentPosition = point
    }
    
    func move(to point: CGPoint) {
        guard isActive else { return }
        
        let dx = point.x - origin.x
        let dy = point.y - origin.y
        let distance = sqrt(dx*dx + dy*dy)
        
        if distance > maxRadius {
            let scale = maxRadius / distance
            currentPosition = CGPoint(
                x: origin.x + dx * scale,
                y: origin.y + dy * scale
            )
        } else {
            currentPosition = point
        }
    }
    
    func stop() {
        isActive = false
        currentPosition = origin
    }
}
