## Architecture Refactor

The prototype has validated the active expedition loop. The next phase of work needs to align the architecture with the product we are actually building: an anthology of authored hazardous expeditions with included and paid scenarios.

That means keeping two concerns sharply separated:

- scenario runtime and authoring
- catalog, entitlements, and commerce

If those concerns blur together, StoreKit and storefront logic will leak into the active run, and scenario content will accumulate pricing and purchase metadata it should not own.

## Architectural Principles

- `GameViewModel` is run-scoped, not app-scoped.
- Scenario content packages describe how a scenario plays, not how it is sold.
- Catalog metadata describes ordering, recommendation, pricing tier, and entitlement behavior.
- Runtime services should be deterministic and testable where practical.
- A scenario that is included or already owned should be playable offline.
- Save-game state and ownership state are separate persistence domains.

## Target Split

- `GameViewModel`
  - Remains the SwiftUI-facing facade for one active expedition.
  - Publishes `gameState`, `partyMovementMode`, and pending resolution state.
  - Delegates rules, consequence execution, run lifecycle, and save/load work to collaborators.
  - Should never talk directly to StoreKit or scenario entitlements.

- `ScenarioCatalogViewModel`
  - Owns the scenario list shown in the main menu and scenario select flow.
  - Publishes included, owned, locked, and recommended scenario states.
  - Owns purchase and restore button state for the storefront-facing UI.
  - Hands an authorized scenario selection off to the run setup flow.

- `RollRulesEngine`
  - Owns roll projection, optional modifier availability, Push Yourself cost calculation, and dice result resolution.
  - Should stay mostly pure and deterministic from inputs.

- `ConsequenceExecutor`
  - Applies atomic consequences to mutable run state.
  - Evaluates authored conditions, clocks, harm, treasure grants, interactable mutations, event triggers, and run endings.

- `ScenarioRuntime`
  - Owns run setup, scenario loading, movement, map/node lookup, discovery, and scenario-scoped state helpers.
  - Applies optional scenario-local shuffle rules when they exist.
  - Should not know whether a scenario is free, paid, owned, or locked.

- `PartyBuilderService`
  - Builds parties from a scenario's native archetype pool.
  - Supports native random parties first, manual selection second, and any future remix rules only as a later extension.

- `SaveGameStore`
  - Owns serialization and save-file location concerns for the active run only.
  - Does not own storefront unlocks or entitlement persistence.

- `ScenarioCatalogStore`
  - Loads the app's scenario catalog manifest.
  - Merges static catalog metadata with entitlement state and StoreKit product data.
  - Surfaces the final included, owned, locked, recommended, and purchase-ready scenario list.

- `EntitlementStore`
  - Persists ownership state for scenarios.
  - Models included scenarios separately from purchased scenarios, but exposes a unified "playable" view.
  - Owns restore results and offline cached ownership.

- `PurchaseCoordinator`
  - Wraps StoreKit product lookup, purchase flow, transaction observation, and restore flow.
  - Converts verified transactions into scenario entitlements.
  - Reports storefront-friendly status back to `ScenarioCatalogStore` / `ScenarioCatalogViewModel`.

- `ScenarioContentLoader` (evolving from the current `ContentLoader`)
  - Replaces the current shared mutable loading model.
  - Loads scenario-local content for one selected scenario at a time.
  - Should be injectable into runtime services rather than accessed through global mutable state.

## Data Boundaries

### Scenario Package

Each scenario package should continue to live under `Content/Scenarios/<scenario_id>/`.

It owns play-facing data such as:

- `scenario.json`
- `archetypes.json`
- fixed maps or interactable templates
- `clocks.json`
- `treasures.json`
- `events.json`
- scenario-local harm families

This package should describe how a scenario plays. It should not carry price, purchase state, "included by default" flags, or other storefront concerns.

### Scenario Catalog Manifest

The storefront should be driven by a separate top-level catalog manifest, likely something like `Content/scenario_catalog.json`.

Each catalog entry should be able to express:

- `scenarioID`
- storefront title and short description
- sort order
- recommended-start flag
- complexity tier
- included vs paid
- `productID` for paid scenarios
- any catalog-only art or badge metadata

This lets the app surface locked and owned scenarios without polluting `scenario.json`.

### Save Data

Run saves should continue to focus on the active expedition:

- selected scenario id
- run state
- party
- map state
- clocks
- flags and counters
- pending resolution state

### Entitlement Data

Ownership persistence should be separate from the run save and should represent:

- included scenarios
- purchased scenarios
- restored purchases
- effective playable scenario ids

## Content Model Direction

The engine should optimize for authored scenarios rather than procgen-first play. Optional shuffle behavior can remain as a variation layer, but the stable authoring toolbox should be:

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
- run endings

Scenario-native archetype pools are part of the product model, not just a content flourish.

## Catalog and Commerce Direction

The product layer should treat scenarios as the primary sellable unit.

- Included scenarios behave like built-in entitlements.
- Paid scenarios are non-consumable IAPs keyed by `productID`.
- Restore purchases must happen above the runtime layer.
- Locked scenarios should be discoverable in the catalog without being startable.
- Once a scenario is included or owned, the app should be able to start it offline if its content is bundled.

The runtime should receive "player may start scenario X" as an input from the catalog layer rather than checking StoreKit or entitlements itself.

## Event System Direction

Events should remain a reusable authored orchestration layer, not a second switch statement.

- `Consequence` stays atomic and mechanical.
- `Event` remains named authored content with conditions and consequences.
- Scenario state keeps generic primitives such as flags and counters.

## Known Gaps in the Current Prototype

- `ContentLoader.shared` is still a global mutable dependency, which leaks scenario activation through shared state rather than explicit ownership.
- The current main menu can list bundled scenarios, but has no architecture for included, owned, locked, or restore-aware storefront states.
- `GameViewModel` is still too broad to become the home for purchase and catalog logic without turning back into an app-wide god object.
- Save/load is JSON-backed for the active run, but entitlement persistence is not modeled yet.
- Legacy Core Data / CloudKit scaffolding still exists even though the current product direction depends on JSON saves plus a separate entitlement layer.

## Implementation Order

1. Finish making run-scoped services injectable and remove reliance on `ContentLoader.shared` from runtime and consequence paths.
2. Introduce a dedicated `ScenarioCatalogEntry` model and a top-level scenario catalog manifest separate from `scenario.json`.
3. Add `ScenarioCatalogStore` and `ScenarioCatalogViewModel`, then move the main menu and scenario select flow onto them.
4. Add `EntitlementStore` to model included, purchased, owned, and locked scenario states.
5. Add `PurchaseCoordinator` for StoreKit product lookup, purchase flow, transaction observation, and restore flow.
6. Wire the catalog UI to entitlements and storefront presentation without expanding `GameViewModel` beyond active-run concerns.
7. Keep `SaveGameStore` focused on active run persistence only.
8. Add targeted tests around catalog loading, entitlement merging, and purchase-state transitions.
9. Only after the storefront and catalog architecture is stable, revisit optional scenario-local shuffling and any future remix features.
