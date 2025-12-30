# Track Specification: Core Gameplay Mechanics

## Overview
This track implements the fundamental gameplay loop for "Horde Forged," focusing on character movement, combat, and the initial player progression system. This will establish a playable, albeit basic, version of a single run.

## Functional Requirements
*   **Player Control (Virtual Joystick):**
    *   When the player's thumb touches the screen, that touch-down point becomes the center of an invisible virtual joystick.
    *   As the player drags their thumb away from the origin point, the character will move in that direction. The distance from the origin can determine the speed (e.g., a small drag moves slowly, a long drag moves at max speed).
    *   When the player lifts their thumb, the character stops moving, and the virtual joystick is reset.
    *   The player can initiate a new movement from anywhere on the screen by touching down again.
*   **Combat:**
    *   The character will auto-attack automatically at a fixed interval.
    *   Attacks will be directed in the current direction of the character's movement.
*   **Progression:**
    *   Enemies will drop EXP crystals upon death.
    *   When enough EXP is collected, the player will level up.
    *   Upon leveling up, the game will pause, and a full-screen modal overlay will present the player with four skill/evolution options to choose from.
    *   Player selection will dismiss the modal and resume the game.
*   **Game Loop:**
    *   The game session (a "run") will last for 12 minutes.
    *   After 12 minutes, the run will end.

## Visual Style
*   All game entities (player, enemies, projectiles, EXP crystals) will be rendered using simple, solid-colored rectangles.
*   All UI elements (EXP bar, level-up menu, timer) will be rendered as simple rectangles and text boxes.

## Non-Functional Requirements
*   Controls should feel responsive and intuitive for a single-thumb mobile experience.
*   Haptic feedback (via `UIFeedbackGenerator`) will be implemented for EXP crystal collection to enhance player satisfaction.

## Acceptance Criteria
*   A solid-colored rectangle representing the player is rendered on screen.
*   The player rectangle can be moved around using the virtual joystick logic.
*   The player rectangle automatically fires smaller rectangles (projectiles) in the direction of movement.
*   Placeholder enemy rectangles are present. When destroyed, they drop smaller rectangles (EXP crystals).
*   Collecting EXP crystals increases a simple rectangular EXP bar. When the bar is full, a level-up modal with four placeholder text options appears, pausing the game.
*   Selecting an option from the level-up modal dismisses it and resumes the game.
*   A text-based timer is displayed on screen, and the run concludes after 12 minutes.

## Out of Scope
*   Specific skill/evolution implementation (options will be placeholders).
*   Advanced enemy AI and attack patterns.
*   Environmental hazards and destructibles.
*   The Crucible Core charging event and boss swarms.
*   Integration of final art assets.
