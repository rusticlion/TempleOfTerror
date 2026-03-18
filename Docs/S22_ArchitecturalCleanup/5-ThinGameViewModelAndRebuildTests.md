## Task 5: Thin `GameViewModel` and Rebuild the Test Harness

**Goal:** Finish the cleanup pass by collapsing `GameViewModel` into a thin facade, moving stray debug/runtime logic out of the main file, and reorganizing tests around the new service seams.

## Why This Pass Exists

The earlier extraction tasks only pay off if the codebase actually starts behaving like those seams are real.

Today the repo still carries two costs that will keep creeping back in unless we close the loop:

- `GameViewModel.swift` is still the instinctive place to add business logic
- `CardGameTests.swift` is a very large catch-all file that makes it harder to understand which architectural seam has broken

This final pass is about making the new architecture stick.

## Scope

In scope:

- `CardGame/GameViewModel.swift`
- any new `GameViewModel+...` files needed to separate debug or query-only helpers
- `CardGameTests/`
- test helper / fixture files

Out of scope:

- new gameplay systems
- UI redesign
- CI/storefront work

## Proposed Changes

### 1. Reduce the Main `GameViewModel` File to Facade Responsibilities

After Tasks 1-4, the primary `GameViewModel` implementation should mostly:

- publish state
- expose stable UI-facing methods
- delegate to runtime collaborators
- coordinate save timing where needed

It should not remain the default home for:

- action execution
- pending resolution logic
- low-level persistence
- low-level movement mutation

### 2. Split Stray Responsibilities Into Clear Files

If the view model still needs additional organization, use narrow files such as:

- `GameViewModel+Queries.swift`
- `GameViewModel+Debug.swift`

Prefer this only after the major logic has already moved into services. File-splitting alone is not the architectural cleanup.

### 3. Break Up the Test Suites by Runtime Concern

Replace the current catch-all testing shape with suites organized around the new seams, for example:

- dependency composition / runtime wiring tests
- pending resolution driver tests
- action resolver tests
- run session controller tests
- scenario runtime mutation tests

Keep UI tests focused on behavior, not on the internal refactor.

### 4. Add Shared Fixture Builders

Introduce lightweight helpers for:

- creating a scenario-backed dependency set
- building a view model for a specific scenario
- producing minimal custom `GameState` fixtures without repeating setup in every test

These helpers should make tests shorter without reintroducing hidden global state.

### 5. Keep the Scenario Validator in the Daily Loop

Document the validation command used during this cleanup pass and keep it part of the expected verification path for architectural refactors that touch runtime content loading.

This keeps content safety checks visible while code ownership is moving around.

Validation command used during this cleanup sprint:

```sh
swiftc CardGame/Models.swift CardGame/ContentLoader.swift CardGame/ScenarioValidator.swift Scripts/run_scenario_validator.swift -o .codex-artifacts/revival-survey/scenario-validate && .codex-artifacts/revival-survey/scenario-validate
```

## Validation Expectations

- run the focused unit suites created during this pass
- run the scenario validator against `Content/Scenarios`
- verify the main menu can still start a run and continue a save in a real app environment once Xcode-backed execution is available

## Definition of Done

- The main `GameViewModel` file is a facade rather than the implementation home for core runtime logic.
- Debug-only helpers no longer crowd the primary runtime facade.
- Tests are organized around the extracted service seams instead of one large catch-all file.
- No test depends on deleted shared-loader behavior.
- The cleanup sprint leaves the codebase noticeably cheaper to re-enter for the next round of content work.
