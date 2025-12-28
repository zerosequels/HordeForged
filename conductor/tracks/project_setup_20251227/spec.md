# Track: Project Setup and Infrastructure

## Overview
This track focuses on initializing the Xcode project for "Horde Forged," establishing its core architectural patterns and essential infrastructure. The goal is to create a solid foundation for future game development, adhering to mobile-first, offline-first principles, and ensuring performance for a 2D top-down roguelite.

## Architectural Patterns
- **Game Logic/Entities:** Entity-Component-System (ECS) will be the primary architectural pattern for managing game entities, their data (components), and logic (systems). This choice is driven by the need to efficiently manage a large number of dynamic on-screen elements, support flexible synergies, and optimize performance for a real-time, horde-based combat system.
- **UI/Scene Presentation:** A UIKit View Controller with an embedded `SKView` presenting an `SKScene` will be used for the primary game view. This approach leverages Apple's recommended pattern for performance-critical games, allowing the `UIViewController` to manage the app lifecycle and broader UI elements, while `SKView` and `SKScene` handle the 2D game rendering and SpriteKit-specific interactions.

## Functional Requirements
- **Xcode Project Initialization:** Create a new Xcode project configured for iOS development.
- **Core Game Scene:** Establish a main `SKScene` where game entities and systems (based on the ECS pattern) will reside and operate.
- **Offline Storage for Meta Progression:** Implement a data persistence mechanism using `Codable` to a file (e.g., JSON or Plist) to store meta-progression data such as unlocked heroes, currency, permanent boosts, and quest states. This will support the offline-first nature of the game.
- **Basic App Lifecycle Management:** Configure the app to handle launch screens, and support portrait/landscape orientation.
- **Initial Build/Test Pipeline:** Set up basic build configurations and integrate with version control (Git). CI setup (e.g., Xcode Cloud) will be considered for future tracks but a basic local test setup should be enabled.

## Non-Functional Requirements
- **Performance:** Maintain 60 FPS on mid-tier iOS devices (e.g., iPhone 12 equivalent) during active gameplay with multiple entities.
- **Download Size:** Initial app download size should be under 100MB.
- **Offline-First:** Core gameplay and meta-progression must function entirely offline.
- **Scalability:** The chosen architectural patterns (ECS, UIKit+SpriteKit) should support the planned growth of entities, skills, items, and procedural layers without significant refactoring.

## Acceptance Criteria
- An Xcode project is successfully created and runnable on an iOS simulator or device.
- A basic `SKScene` is presented within a `UIViewController`.
- A mechanism for saving and loading `Codable` data to a file is implemented and verifiable (e.g., saving dummy meta-progression data).
- The application launches with a splash screen and supports device rotation (portrait/landscape) with appropriate layout adjustments for the game scene.
- The project is configured for Git version control, and a minimal set of local tests can be run.

## Out of Scope for this Track
- Detailed ECS implementation beyond core structure (e.g., specific entities, components, systems for heroes, enemies, skills).
- Complex UI overlays using SwiftUI or UIKit (beyond the basic `UIViewController` container).
- Full CI/CD pipeline setup (only basic local build/test).
- Actual game content (e.g., assets, game logic, enemy AI).
- Cloud saving integration.
