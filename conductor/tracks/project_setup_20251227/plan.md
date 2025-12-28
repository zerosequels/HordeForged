# Plan: Project Setup and Infrastructure

This plan outlines the steps to initialize the Xcode project, set up core architectural patterns (ECS for game logic, UIKit+SpriteKit for UI/scene), and establish basic infrastructure for "Horde Forged."

## Phase 1: Xcode Project and Basic Structure

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
- [ ] Task: Conductor - User Manual Verification 'Xcode Project and Basic Structure' (Protocol in workflow.md)

## Phase 2: ECS Foundation and Offline Storage

### Objective
To establish the basic ECS framework and implement the `Codable` file-based storage for meta-progression.

- [ ] Task: Implement foundational ECS components
  - [ ] Write Failing Tests: Create unit tests for `Component` protocol and a sample concrete component (e.g., `PositionComponent`) to ensure data encapsulation.
  - [ ] Implement to Pass Tests: Define a `Component` protocol and implement basic component structs/classes (e.g., `PositionComponent`, `HealthComponent`).
  - [ ] Refactor: Ensure components are lightweight and data-only.
- [ ] Task: Implement foundational ECS entity
  - [ ] Write Failing Tests: Create unit tests for an `Entity` class/struct to ensure it can hold unique IDs and a collection of `Component`s.
  - [ ] Implement to Pass Tests: Define an `Entity` struct/class capable of holding a unique identifier and a dictionary/array of `Component`s.
  - [ ] Refactor: Optimize entity creation and component lookup.
- [ ] Task: Implement foundational ECS system
  - [ ] Write Failing Tests: Create unit tests for a `System` protocol/class and a sample system (e.g., `UpdatePositionSystem`) to ensure it can iterate over entities with specific components.
  - [ ] Implement to Pass Tests: Define a `System` protocol/class and implement a basic system (e.g., a system that updates positions based on a `VelocityComponent` and `PositionComponent`).
  - [ ] Refactor: Ensure systems operate purely on components and have no direct entity manipulation beyond component access.
- [ ] Task: Integrate ECS into SKScene
  - [ ] Write Failing Tests: Create an integration test within `SKScene` to verify that entities with components can be added and systems can process them during the `update` cycle.
  - [ ] Implement to Pass Tests:
    - Modify the initial `SKScene` to manage a collection of `Entity` objects.
    - Integrate the ECS `System` update logic into the `SKScene`'s `update(_:)` method.
  - [ ] Refactor: Optimize entity-system interactions within the `SKScene`.
- [ ] Task: Implement Codable file-based storage
  - [ ] Write Failing Tests: Create unit tests for a `GameSave` struct (or similar) that conforms to `Codable`, and tests for a `SaveLoadManager` class to verify saving and loading of this data to a file.
  - [ ] Implement to Pass Tests:
    - Define a top-level `Codable` struct (e.g., `GameSave`) to encapsulate meta-progression data.
    - Implement a `SaveLoadManager` responsible for encoding `GameSave` to JSON/Plist and writing to a file, and decoding from file.
  - [ ] Refactor: Ensure error handling for file operations and data corruption.
- [ ] Task: Conductor - User Manual Verification 'ECS Foundation and Offline Storage' (Protocol in workflow.md)

## Phase 3: Version Control and Basic Testing

### Objective
To establish the project's version control and basic testing setup.

- [ ] Task: Initialize Git repository and add .gitignore
  - [ ] Write Failing Tests: (N/A for Git setup)
  - [ ] Implement to Pass Tests:
    - Initialize a Git repository in the project root if one doesn't exist.
    - Create a `.gitignore` file suitable for Xcode projects to exclude derived data, user settings, etc.
  - [ ] Refactor: Ensure `.gitignore` is comprehensive.
- [ ] Task: Configure initial local testing setup
  - [ ] Write Failing Tests: (N/A, this is a setup task)
  - [ ] Implement to Pass Tests: Verify that the default Xcode unit test target is correctly configured and can run a basic test.
  - [ ] Refactor: Ensure test target is properly linked to the main app target.
- [ ] Task: Conductor - User Manual Verification 'Version Control and Basic Testing' (Protocol in workflow.md)
