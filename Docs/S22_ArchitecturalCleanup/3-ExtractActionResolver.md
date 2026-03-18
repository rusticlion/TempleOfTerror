## Task 3: Extract the Action Resolver

**Goal:** Move action execution, free-action handling, group-action handling, modifier consumption, and Push Yourself application out of `GameViewModel`.

## Why This Pass Exists

The single most expensive piece of `GameViewModel` to keep touching is action resolution.

Right now the view model directly owns:

- free-action execution
- normal roll execution
- group-action execution
- optional modifier consumption
- treasure depletion side effects
- Push Yourself stress application during rolls
- critical-effect messaging and post-roll fallout handoff

That is core game logic, but it is not view-model logic. It should live in a service that can be tested and evolved in isolation.

## Scope

In scope:

- `CardGame/GameViewModel.swift`
- `CardGame/RollRulesEngine.swift`
- the new action-resolution service
- integration with the pending-resolution driver from Task 2
- logic tests for standard rolls, free actions, group actions, modifier use, and push costs

Out of scope:

- redesigning `DiceRollView`
- changing FitD roll math
- adding new modifier schema features

## Proposed Changes

### 1. Add an `ActionResolver`

Create a runtime collaborator that coordinates:

- roll projection inputs from `RollRulesEngine`
- action availability checks
- chosen optional modifier application
- modifier and treasure depletion
- Push Yourself application during action commitment
- handoff into the pending-resolution driver

### 2. Move Action Execution Out of `GameViewModel`

Extract the current action-heavy methods into the new service, including:

- `performFreeAction`
- `performAction`
- `performGroupAction`
- helper logic tightly coupled to those flows, such as unavailable-action messaging if practical

The view model should delegate and publish the returned result, not implement the rules inline.

### 3. Keep Projection Queries Stable

The UI-facing API for:

- roll projection
- optional modifier selection
- effective projection preview

should remain stable for existing SwiftUI screens where practical.

That means the refactor should favor internal delegation over broad UI rewrites.

### 4. Preserve Existing Side Effects

The extracted resolver must preserve existing behavior around:

- treasure removal when a granted modifier is depleted
- consumed-modifier messaging
- critical-effect bumping
- pending fallout state after a roll resolves

This pass should not change what the player sees, only where the logic lives.

## Primary Files

- `CardGame/GameViewModel.swift`
- `CardGame/RollRulesEngine.swift`
- new runtime action-resolution service file
- tests covering action execution and modifier behavior

## Definition of Done

- `GameViewModel` no longer owns the implementation of standard, free, or group action execution.
- Optional modifier consumption and Push Yourself application are handled in the action-resolution service.
- `DiceRollView` continues to use the same high-level view-model API without a broad rewrite.
- Existing tests for modifier depletion, push costs, group actions, and banned actions still pass after being redirected to the new seam.
- New gameplay work related to roll execution has a clear home outside `GameViewModel`.
