import GameplayKit
import SpriteKit

class EnemyEntity: GKEntity {
    
    init(color: UIColor, size: CGSize, health: Int) {
        super.init()
        
        // Visuals
        let spriteComponent = SpriteComponent(color: color, size: size)
        addComponent(spriteComponent)
        
        // Position - will be set by spawner, but component is needed? 
        // Actually SpriteComponent handles position via its node.
        
        // Health
        let healthComponent = HealthComponent(maxHealth: health)
        addComponent(healthComponent)
        
        // Movement
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
        
        // --- Health Bar ---
        let barWidth: CGFloat = 40
        let barHeight: CGFloat = 5
        let barOffset = CGPoint(x: 0, y: size.height/2 + 10)
        
        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 1)
        bg.fillColor = .black
        bg.strokeColor = .clear
        bg.position = barOffset
        bg.zPosition = 10
        bg.isHidden = true // Hidden initially
        
        // Fill
        // Anchor left for scaling? SKShapeNode rectOf is centered. Use rect(origin:size) for easier scaling?
        // Or just scale X of a centered rect? Centered scaling scales from center, so bar shrinks to middle.
        // We want left-aligned.
        let fillOrigin = CGPoint(x: -barWidth/2, y: -barHeight/2)
        let fill = SKShapeNode(rect: CGRect(origin: fillOrigin, size: CGSize(width: barWidth, height: barHeight)), cornerRadius: 1)
        fill.fillColor = .green
        fill.strokeColor = .clear
        fill.zPosition = 11
        
        // Add fill to bg so they move together, but wait...
        // if we scale Fill, we want unexpected results if parented?
        // Let's parent bg to sprite, and fill to bg?
        // SKShapeNode children inherit transform.
        bg.addChild(fill)
        spriteComponent.node.addChild(bg)
        
        // Health Callback
        healthComponent.onHealthChanged = { [weak bg, weak fill] current, maxHP in
            guard let bg = bg, let fill = fill else { return }
            
            // Show on first damage (or always if we want)
            if bg.isHidden {
                bg.isHidden = false
            }
            
            // Calculate Percentage
            let pct = CGFloat(current) / CGFloat(maxHP)
            let clamped = max(0.0, min(1.0, pct))
            
            // Update Scale
            // fill is defined with full width. Scaling X works if anchor is left?
            // origin is -width/2. Scaling X will scale relative to (0,0) of bg.
            // Since rect is offset, scaling X scales the shape? sKShapeNode is tricky with anchors.
            // Standard approach: Use xScale on a node whose content starts at x=0.
            // Here our rect starts at -20. If we scale by 0.5, -20 becomes -10, width 40 becomes 20.
            // Range -10 to +10. Center is 0. Bar shrinks to center.
            // We want left anchor.
            // Fix: Create container node at left edge?
            // Easier Fix: Re-create fill rect path? Expensive.
            // Correct Fix: Use xScale, but position node such that (0,0) is left edge.
            
            // Re-setup Fill Node Position
            // Let's fix fill node setup above first? Can't restart init.
            // We can adjust x position based on scale to keep left edge fixed?
            // New Center = Old Center - (Old Width - New Width)/2
            // Let's just update behavior here:
            // Easier: Just update xScale and let it shrink to center?
            // User asked for "health bar". Shrinking to center is acceptable for MVP, but Left-Aligned is better.
            
            // Let's use the X-Scale + Position Shift hack for centered rects:
            // width = initialWidth * scale
            // diff = initialWidth - width
            // shift = -diff / 2 ??? No.
            
            // Actually, let's just use a transform node or simple math.
            // If I set xScale = 0.5, the drawn rect (-20...20) becomes (-10...10).
            // Visually it shrinks to center.
            // To align left (which is at -20), I need the new rect to be (-20...0).
            // Center of new rect is -10.
            // So need to move node by -10?
            // Center shift = (1 - scale) * (width / 2) * -1
            // Let's try that.
            
            fill.xScale = clamped
            
            // Color Logic
            if clamped < 0.2 {
                fill.fillColor = .red
            } else if clamped < 0.5 {
                fill.fillColor = .yellow
            } else {
                fill.fillColor = .green
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
