# Plan: Core Gameplay Mechanics

This plan outlines the steps to implement the fundamental gameplay loop for "Horde Forged," focusing on character movement, combat, and the initial player progression system.

## Phase 1: Player Movement and Control

### Objective
To implement a responsive, virtual joystick-based movement system for the player character.

- [x] Task: Implement Virtual Joystick Logic
  - [x] Write Failing Tests: Create unit tests for a new `VirtualJoystick` class/struct that can track a start point (touch down) and an end point (drag), and calculate a normalized vector.
  - [x] Implement to Pass Tests: Create the `VirtualJoystick` logic.
  - [x] Refactor: Ensure the vector calculation is accurate and efficient.
- [x] Task: Connect Joystick to Player Movement in `GameScene`
  - [x] Write Failing Tests: Create integration tests in `GameSceneTests` to verify that touch events (began, moved, ended) correctly update the player's `VelocityComponent` via the virtual joystick.
  - [x] Implement to Pass Tests:
    - Add a `touchesBegan`, `touchesMoved`, and `touchesEnded` implementation to `GameScene`.
    - Use these touch events to update the `VirtualJoystick`.
    - In the `GameScene`'s `update` loop, use the joystick's vector to update the player entity's `VelocityComponent`.
  - [x] Refactor: Clean up touch handling logic in `GameScene`.
- [x] Task: Conductor - User Manual Verification 'Player Movement and Control' (Protocol in workflow.md)

## Phase 2: Basic Combat and Enemy Interaction

### Objective
To implement a basic auto-attack system for the player and create placeholder enemies to interact with.

- [x] Task: Implement Player Auto-Attack
  - [x] Write Failing Tests: Create tests to verify that a `FireProjectileSystem` creates a new projectile entity at a regular interval, with a velocity matching the player's direction.
  - [x] Implement to Pass Tests: Create the `FireProjectileSystem` and add it to the `EntityManager`.
  - [x] Refactor: Make the firing interval configurable.
- [x] Task: Create Placeholder Enemy
  - [x] Write Failing Tests: Create tests to verify that an "Enemy" entity can be created with `PositionComponent` and `HealthComponent`.
  - [x] Implement to Pass Tests: Create a factory or function to easily spawn enemy entities.
  - [x] Refactor: N/A
- [x] Task: Implement Health and Damage
  - [x] Write Failing Tests: Create tests for a `CollisionSystem` that detects collisions between "Projectile" and "Enemy" entities, reduces the enemy's `HealthComponent`, and removes the projectile.
  - [x] Implement to Pass Tests: Create the `CollisionSystem` and add it to the `EntityManager`. Implement logic for projectile-enemy collisions.
  - [x] Refactor: Ensure collision detection is performant.
- [x] Task: Conductor - User Manual Verification 'Basic Combat and Enemy Interaction' (Protocol in workflow.md)

## Phase 3: Progression and Leveling System

### Objective
To implement the EXP and level-up loop.

- [x] Task: Implement EXP Crystals and Collection
  - [x] Write Failing Tests: Create tests to verify that destroyed enemies spawn an "EXP Crystal" entity. Create tests for a `PlayerCollisionSystem` that detects player-crystal collisions and removes the crystal.
  - [x] Implement to Pass Tests:
    - Modify the `CollisionSystem` or `HealthSystem` to spawn an EXP crystal when an enemy's health reaches zero.
    - Create a `PlayerCollisionSystem` to handle player-specific collisions.
  - [x] Refactor: N/A
- [x] Task: Implement Leveling and EXP Bar
  - [x] Write Failing Tests: Create tests for a `PlayerExperienceSystem` that listens for "EXP collected" events, updates the player's `ExperienceComponent`, and determines when a level-up should occur.
  - [x] Implement to Pass Tests: Create the `PlayerExperienceSystem` and a simple rectangular EXP bar UI element.
  - [x] Refactor: N/A
- [x] Task: Implement Level-Up Modal
  - [x] Write Failing Tests: Create UI tests to verify that a full-screen modal view appears when a "level up" event occurs, pausing the game.
  - [x] Implement to Pass Tests: Create a SwiftUI view for the modal and a system to manage its presentation.
  - [x] Refactor: Ensure the game state is properly paused and resumed.
- [x] Task: Conductor - User Manual Verification 'Progression and Leveling System' (Protocol in workflow.md)

## Phase 4: Core Game Loop

### Objective
To implement the main game loop structure, including the run timer and end condition.

- [x] Task: Implement 12-Minute Run Timer
  - [x] Write Failing Tests: Create tests to verify that a `GameTimerSystem` tracks the total elapsed time for a run.
  - [x] Implement to Pass Tests: Create the `GameTimerSystem` and a simple text-based UI element to display the time.
  - [x] Refactor: N/A
- [x] Task: Implement Run End Condition
  - [x] Write Failing Tests: Create tests to verify that when the `GameTimerSystem` reaches 12 minutes, a "run ended" event is triggered.
  - [x] Implement to Pass Tests: Implement the logic to handle the "run ended" event (e.g., show a "Run Over" screen).
  - [x] Refactor: N/A
- [x] Task: Conductor - User Manual Verification 'Core Game Loop' (Protocol in workflow.md)
