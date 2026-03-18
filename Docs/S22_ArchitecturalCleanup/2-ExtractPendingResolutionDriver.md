## Task 2: Extract the Pending Resolution Driver

**Goal:** Move consequence continuation, pending choice handling, resistance flow, and related state transitions out of `GameViewModel` into one focused runtime collaborator.

## Why This Pass Exists

`GameViewModel` currently owns too much of the resolution pipeline:

- processing new consequences
- previewing queued resistances
- accepting or resisting fallout
- choosing authored options
- checking conditions through a freshly created executor
- checking stress overflow through the same path

Those behaviors are tightly related, but they are not UI concerns. Keeping them in the view model makes every consequence or resistance change more expensive than it needs to be.

## Scope

In scope:

- `CardGame/GameViewModel.swift`
- `CardGame/ConsequenceExecutor.swift`
- a new driver/coordinator type for pending resolution flow
- unit tests covering pending choice and resistance behavior

Out of scope:

- redesigning the resistance UI
- changing consequence data models
- changing authored consequence semantics

## Proposed Changes

### 1. Add a Resolution Driver

Create one focused type such as:

- `PendingResolutionDriver`
- or `ResolutionFlowCoordinator`

It should wrap the existing `ConsequenceExecutor` behavior needed by the run facade and expose operations like:

- process a new consequence batch
- resume an existing pending resolution
- choose a pending choice option
- accept a resistible consequence
- roll resistance
- preview upcoming resistances

### 2. Move State Transition Logic Out of `GameViewModel`

The new driver should own the resolution-state transitions that currently live in `GameViewModel`, including:

- writing the updated `PendingConsequenceResolution`
- determining when a resolution is complete
- returning the human-readable description text produced by consequence execution

`GameViewModel` should only:

- hand the driver the current run state
- assign the returned state
- trigger save behavior through the lifecycle layer

### 3. Centralize Condition and Overflow Access

If `GameViewModel` still needs condition checks or overflow checks during other flows, those calls should route through the resolution driver instead of directly constructing `ConsequenceExecutor`.

This keeps executor ownership consistent and avoids recreating wiring logic in multiple places.

### 4. Preserve Current Behavior

Do not change the external behavior of:

- pending choice sequencing
- resistance prompts
- resistance queue previews
- save/load survival of pending resolution state

This task is architectural cleanup, not a rules rewrite.

## Primary Files

- `CardGame/GameViewModel.swift`
- `CardGame/ConsequenceExecutor.swift`
- new runtime service file for the resolution driver
- `CardGameTests/CardGameTests.swift` and any split suites created during cleanup

## Definition of Done

- `GameViewModel` no longer directly constructs or calls `ConsequenceExecutor` for normal resolution flow.
- Pending choice and resistance transitions route through one dedicated collaborator.
- Condition checks and overflow checks no longer create ad hoc executor instances from the view model.
- Existing resolution behavior remains unchanged in-game.
- Focused tests cover pending choice, resistance acceptance, resistance rolling, and queued fallout preview.
