## Task 1: Stabilize Run Dependency Composition

**Goal:** Remove hidden globals and silent default-owned collaborators so one run is always backed by one explicit set of runtime services.

## Why This Pass Exists

The current architecture is partway through the split described in `Docs/ArchitectureRefactor.md`, but a few hidden shortcuts still raise the cost of every change:

- `ContentLoader.shared` still exists as a global mutable escape hatch.
- some core services still create their own fallback runtime/content when no collaborator is supplied
- tests still prove correctness by mutating shared global state instead of constructing explicit run-scoped dependencies

That makes the code easier to revive incorrectly than to extend cleanly.

This first pass should make dependency ownership boring and explicit before we extract more logic out of `GameViewModel`.

## Scope

In scope:

- `CardGame/ContentLoader.swift`
- `CardGame/GameViewModel.swift`
- `CardGame/ConsequenceExecutor.swift`
- `CardGame/DungeonGenerator.swift`
- test helpers and unit tests that still depend on shared loader mutation

Out of scope:

- StoreKit or entitlement modeling beyond the current testing-access placeholder
- main-menu or scenario-catalog feature work
- rules changes, content changes, or UI redesign

## Proposed Changes

### 1. Introduce Explicit Run Composition

Add one narrow composition type for an active expedition, for example:

- `RunDependencies`
- or `RunServiceFactory`

It should own the collaborators that are truly run-scoped, such as:

- `ScenarioRuntime`
- `RollRulesEngine`
- `SaveGameStore`
- any driver / resolver factories introduced in later cleanup tasks

Default construction should happen only at app and test boundaries, not deep inside game services.

### 2. Remove `ContentLoader.shared`

Delete the shared mutable loader from `ContentLoader`.

The active scenario content should come from:

- the `ScenarioRuntime` attached to the current run
- explicit content passed into services that need it

No gameplay code or tests should depend on changing a singleton to prove that the current run still uses the correct scenario package.

### 3. Remove Silent Service Fallbacks

Stop letting core services quietly instantiate their own runtime/content through default parameters.

In particular, cleanup should remove patterns where a service can still do work by creating:

- a fresh `ScenarioRuntime()`
- or a fallback `ContentLoader(...)`

That behavior masks wiring mistakes and makes tests less trustworthy.

### 4. Add Small Test Builders

Introduce simple fixture helpers that can build:

- dependencies for a named scenario
- a view model backed by those dependencies
- a standalone runtime/content pair for logic-only tests

These should replace tests that currently mutate shared loader state mid-run.

## Implementation Notes

- Keep the runtime path injectable and lightweight. Do not introduce a broad app-wide service locator.
- Favor value-like composition where practical. The intent is explicit ownership, not a new global container.
- This task should leave behavior unchanged from the player's perspective.

## Definition of Done

- `ContentLoader.shared` no longer exists.
- Core runtime services do not silently create their own fallback runtime/content to proceed.
- A new run, loaded run, and test-created run all use explicit dependency wiring.
- Existing tests that proved correctness via shared-loader mutation are rewritten around explicit run dependencies.
- The cleanup creates the foundation needed for the later extraction of resolution, action, and lifecycle services.
