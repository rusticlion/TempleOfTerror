## Task 4: Extract the Run Session Controller

**Goal:** Move run lifecycle, persistence, movement, and ambient-session coordination out of `GameViewModel` into one run-scoped controller.

## Why This Pass Exists

Even after rules cleanup, `GameViewModel` will still stay too broad if it continues to own:

- starting a run
- restarting the current scenario
- loading and saving
- movement and discovery updates
- grouped vs solo move application
- ambient audio sync when entering a room

Those are run-session concerns. They should be coordinated in one place so the view model stays a facade instead of regrowing into a god object.

## Scope

In scope:

- `CardGame/GameViewModel.swift`
- `CardGame/Persistence.swift`
- `CardGame/DungeonGenerator.swift` / `ScenarioRuntime`
- new run-session controller file
- app entry points that create or continue a run

Out of scope:

- changing save-file format
- changing movement rules
- changing catalog selection or main-menu feature scope

## Proposed Changes

### 1. Add a Run Session Controller

Create one focused runtime collaborator such as:

- `RunSessionController`
- or `RunLifecycleController`

It should coordinate:

- `ScenarioRuntime`
- `SaveGameStore`
- ambient room-entry effects such as audio sync

### 2. Move Lifecycle Methods Out of `GameViewModel`

Extract the current lifecycle and persistence methods into the session controller, including:

- `startNewRun`
- `restartCurrentScenario`
- `saveGame`
- `loadGame`
- movement application and discovery updates

`GameViewModel` should remain the owner of published state, but it should stop implementing those workflows directly.

### 3. Keep Movement-Mode State UI-Facing

`PartyMovementMode` can remain a view-model-facing concept if that keeps the SwiftUI layer simple.

However, once the player commits to a move, the actual grouped or solo movement application should route through the session controller and `ScenarioRuntime`, not be partially implemented in the view model.

### 4. Isolate Ambient Session Side Effects

The current ambient-audio sync is small, but it is exactly the kind of side effect that tends to sprawl across the app.

This task should keep room-entry side effects behind the session controller or a tiny injected protocol so future polish work has a clean integration point.

## Primary Files

- `CardGame/GameViewModel.swift`
- `CardGame/Persistence.swift`
- `CardGame/DungeonGenerator.swift`
- `CardGame/CardGameApp.swift`
- `CardGame/MainMenuView.swift`

## Definition of Done

- `GameViewModel` no longer directly owns run startup, restart, save/load, or move execution logic.
- Starting a new run, continuing a save, restarting a scenario, and moving between nodes all route through the session controller.
- Ambient room-entry effects are coordinated outside the main view model.
- Save/load behavior remains unchanged from the player's perspective.
- The controller forms the final major service seam needed to keep future content work out of `GameViewModel`.
