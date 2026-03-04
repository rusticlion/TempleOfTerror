## Architecture Refactor

The prototype has reached the point where `GameViewModel` is carrying too many responsibilities at once. The next phase of work keeps the existing UI-facing API stable while moving the underlying logic into focused services.

### Target Split

- `GameViewModel`
  - Remains the SwiftUI-facing facade.
  - Publishes `gameState` and `partyMovementMode`.
  - Delegates rules, consequence execution, and scenario lifecycle work to collaborators.
- `RollRulesEngine`
  - Owns roll projection, optional modifier availability, Push Yourself cost calculation, and dice result resolution.
  - Should stay mostly pure and deterministic from inputs.
- `ConsequenceExecutor`
  - Applies atomic consequences to mutable run state.
  - Evaluates conditions, clocks, harm, treasure grants, interactable mutations, and event triggers.
- `ScenarioRuntime`
  - Owns run setup, scenario loading, movement, map/node lookup, discovery, and scenario-scoped state helpers.
- `PartyBuilderService`
  - Replaces the current “random party generator” framing.
  - Supports recommended parties, native random parties, manual selection, and future crossover rules.
- `SaveGameStore`
  - Owns serialization and save-file location concerns.

### Content Model Direction

The engine should optimize for authored scenarios rather than procgen-first play. Procgen can remain as a variation layer, but the stable authoring toolbox should be:

- action ratings
- position/effect
- stress
- harm
- clocks
- modifiers and treasures
- tags
- choices
- consequences
- events
- scenario state

### Event System Direction

Events should be a reusable authored orchestration layer, not a second switch statement.

- `Consequence` stays atomic and mechanical.
- `Event` becomes named authored content with conditions and consequences.
- Scenario state should gain generic primitives such as flags and counters.

### Implementation Order

1. Extract `RollRulesEngine` while keeping `GameViewModel`'s public API intact.
2. Extract consequence execution behind a dedicated executor.
3. Move run setup and movement into a scenario runtime layer.
4. Introduce scenario state plus authored events.
5. Rework party generation into party building and scenario-native roster selection.
