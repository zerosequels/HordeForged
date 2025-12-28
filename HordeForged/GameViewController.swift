import SwiftUI
import UIKit
import SpriteKit

// MARK: - GameViewController

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = SKView()
        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.accessibilityIdentifier = "GameSKView" // Set accessibility identifier for UI testing
        self.view.addSubview(skView)

        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: self.view.topAnchor),
            skView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            skView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])

        // Present an empty SKScene
        let scene = SKScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let skView = self.view.subviews.first as? SKView {
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
        // Update the view controller if needed (e.g., when SwiftUI state changes)
    }
}
