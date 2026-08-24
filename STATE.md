# STATE — Dice Delver
Last updated: 2026-07-14 (by /wrap)

## Now
Next concrete task: Add one real Devil's Bargain to Salt and Ruin's Warden encounter, run `Scripts/check_authored_scenarios.sh salt_and_ruin`, then play that route through victory with one save/reload; record the first blocker.

## Open threads
- Treat the gameplay/authoring engine as provisionally frozen; add primitives only when real authored content proves a blocker.
- Define a Golden Expedition release gate: real packaged scenario, catalog/party setup, fixed path, save/reload, objective, and `endRun`.
- Restore a trustworthy verification baseline: update the four-scenario catalog assertion, add `ModifierSystemTests.swift` and `StressOverflowTests.swift` to the unit target, make fresh/stale derived-data runs self-healing, and make authoring checks idempotent.
- Choose the v1 catalog contract: included-only release, or implement StoreKit purchase/restore/verified entitlements for Charon's Bargain.
- Harden the production bundle: privacy manifest, opaque icon, valid accent color, final catalog/resources, atomic/recoverable saves, device scope, audio/art, and App Store metadata.

## Blockers
- No real-content acceptance test currently proves a packaged scenario from launch through save/load to an ending.
- The paid-scenario catalog contract is not shippable: StoreKit is not wired and release UI exposes local testing unlocks.
- Release verification is red: 86 unit tests ran with one stale catalog failure; 22 additional unit-test methods are not in the Xcode target.

## Content score
Scenarios authored end-to-end in YAML: 2 (`temple_of_terror`, `salt_and_ruin`). `shadow_of_a_doubt` is a placeholder; `charons_bargain` remains runtime-JSON-only.

## Session log (most recent first, keep 10)
- 2026-07-14: Bootstrapped project state; authoring checks passed, unit/release gaps were mapped, and a content-first engine-freeze test was selected.
