## Task 1: Extract Scenario Runtime and Save Game Store

**Goal:** Finish the runtime split so the engine has a stable, non-UI core that authored scenarios can rely on.

**Actions:**
- Create `ScenarioRuntime` to own:
  - starting a run from a `ScenarioManifest`
  - restarting the current scenario
  - movement, node lookup, node discovery, and party location state
  - scenario flags and counters
  - map/interactable mutation helpers used by consequence resolution
- Create `SaveGameStore` to own:
  - save file location
  - save existence checks
  - save/load/delete behavior
  - migration hooks for future content-model changes
- Refactor `GameViewModel` into a thin SwiftUI facade that delegates:
  - roll math to `RollRulesEngine`
  - consequence execution to `ConsequenceExecutor`
  - run lifecycle and map state to `ScenarioRuntime`
  - persistence to `SaveGameStore`
- Introduce a narrow runtime mutation API that `ConsequenceExecutor` can use instead of reaching directly into unrelated view-model concerns.
- Preserve the existing UI-facing API where practical so current SwiftUI screens do not need a broad rewrite.

**Definition of Done:**
- `GameViewModel` no longer owns save-path details, scenario bootstrapping, or low-level map mutation.
- Starting, loading, restarting, and moving through a scenario work through runtime/store collaborators.
- Unit tests cover run startup, restart, save/load, and basic movement/discovery behavior.
