# Plan: Project Setup and Infrastructure

This plan outlines the steps to initialize the Xcode project, set up core architectural patterns (ECS for game logic, UIKit+SpriteKit for UI/scene), and establish basic infrastructure for "Horde Forged."

## Phase 1: Xcode Project and Basic Structure [checkpoint: e39684d]

### Objective
To create a runnable Xcode project with the foundational app structure and game scene presentation.

- [x] Task: Create new Xcode project
  - Note: User confirmed project created with App template (SwiftUI lifecycle).
  - [ ] Write Failing Tests: (N/A for project creation)
  - [x] Implement to Pass Tests: Initialize an empty iOS project in Xcode.
  - [ ] Refactor: Review project settings and structure for cleanliness.
- [x] Task: Configure basic app lifecycle 2538378
  - [x] Write Failing Tests: (N/A for initial configuration, but consider testing launch screen presence via UI tests later)
  - [x] Implement to Pass Tests: Configure `Info.plist` for portrait/landscape orientation support and set up a default launch screen.
  - [x] Refactor: Ensure orientation changes are handled smoothly.
- [x] Task: Implement UIKit View Controller and SKView (Bridge SwiftUI to UIKit) de68241
  - [x] Write Failing Tests: Create a basic UI test to confirm `SKView` is present and visible within the `UIViewController` hosted in SwiftUI.
  - [x] Implement to Pass Tests:
    - Create a `GameViewController` (subclass of `UIViewController`).
    - Instantiate an `SKView` within `GameViewController`'s view hierarchy.
    - Set up the `SKView` to present an initial, empty `SKScene`.
    - Create a `UIViewControllerRepresentable` struct to bridge `GameViewController` to SwiftUI.
    - Update `ContentView` or `HordeForgedApp` to display the bridge.
  - [x] Refactor: Ensure proper setup and tear down of the `SKView` and `SKScene` within the view controller lifecycle.
- [x] Task: Conductor - User Manual Verification 'Xcode Project and Basic Structure' (Protocol in workflow.md) e39684d

## Phase 2: GameplayKit ECS and Offline Storage

### Objective
To establish the ECS framework using Apple's native GameplayKit and implement `Codable` file-based storage for meta-progression.

- [ ] Task: Create `GKComponent` Subclasses
  - [ ] Write Failing Tests: Create unit tests for custom `GKComponent` subclasses (e.g., `PositionComponent`, `VelocityComponent`) to ensure properties are correctly initialized.
  - [ ] Implement to Pass Tests: Create `PositionComponent` and `VelocityComponent` as subclasses of `GKComponent`.
  - [ ] Refactor: Ensure components are lightweight and data-only.
- [ ] Task: Create `GKComponentSystem` for Movement
  - [ ] Write Failing Tests: Create a unit test for an `UpdatePositionSystem` (subclass of `GKComponentSystem`) to verify it correctly processes entities with `PositionComponent` and `VelocityComponent`.
  - [ ] Implement to Pass Tests: Create `UpdatePositionSystem` that iterates through entities and updates their positions based on velocity.
  - [ ] Refactor: Ensure system logic is efficient.
- [ ] Task: Integrate GameplayKit ECS into `GameScene`
  - [ ] Write Failing Tests: Create an integration test to confirm that a `GKEntity` with components can be added to the scene's entity manager and that the `UpdatePositionSystem` modifies it during the `update` cycle.
  - [ ] Implement to Pass Tests:
    - Modify `GameScene` to hold a collection of `GKEntity` objects and a `GKComponentSystem`.
    - In `GameScene`'s `update(_:)` method, call the `update(deltaTime:)` method of the component system.
  - [ ] Refactor: Streamline the entity and system management within the scene.
- [ ] Task: Implement Codable file-based storage
  - [ ] Write Failing Tests: Create unit tests for a `GameSave` struct (or similar) that conforms to `Codable`, and tests for a `SaveLoadManager` class to verify saving and loading of this data to a file.
  - [ ] Implement to Pass Tests:
    - Define a top-level `Codable` struct (e.g., `GameSave`) to encapsulate meta-progression data.
    - Implement a `SaveLoadManager` responsible for encoding `GameSave` to JSON/Plist and writing to a file, and decoding from file.
  - [ ] Refactor: Ensure error handling for file operations and data corruption.
- [ ] Task: Conductor - User Manual Verification 'GameplayKit ECS and Offline Storage' (Protocol in workflow.md)
