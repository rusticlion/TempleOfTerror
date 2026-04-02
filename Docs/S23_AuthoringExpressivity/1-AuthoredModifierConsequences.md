## Task 1: Authored Modifier Consequences

**Goal:** Let scenario authors grant and remove full authored `Modifier` payloads through consequences so the engine can express setup, support, curses, bargains, environmental advantages, and temporary tactical states without bespoke new mechanics.

## Why This Pass Exists

The current engine already has a solid `Modifier` model:

- optional vs always-on application
- bonus dice
- position improvement
- effect improvement
- action filtering
- interactable-tag filtering
- use counts

That is a strong primitive, but authored content can currently reach it only through:

- treasures
- harm boons
- the narrow `modifyDice` consequence
- `Push Yourself`

That leaves a lot of scenario design stranded between:

- "give a permanent treasure"
- or "just add stress / harm / clock ticks"

Authors cannot yet cleanly express things like:

- "Ng talks you through the calibration: gain +1 Effect on your next `Tinker` roll."
- "The warding circle holds: everyone here gets Improved Position against `Attune` fallout until it breaks."
- "The spores get in your lungs: `Prowl` is harder until you clear the contamination."
- "The guide anchors the rope: others here gain +1d on their next `Finesse` action in this chamber."
- "Accept the bargain: take +1d now, but carry a curse that keeps helping only in relic rooms."

This pass aims to unlock those patterns with one broad primitive rather than a pile of bespoke consequence types.

## Core Product Decision

`grantModifier` should be the engine's general-purpose authored "tactical state" primitive.

`modifyDice` should remain supported as a lightweight shorthand for very simple, legacy-compatible dice adjustments, but it should not be expanded into a parallel status system with more and more special cases.

That gives authors a clean rule of thumb:

- use `modifyDice` for simple immediate +/- dice adjustments
- use `grantModifier` for anything that should behave like a real, inspectable gameplay state

## Design Direction

Add authored modifier grant/remove consequences instead of inventing a separate "status effect" system.

Why:

- the engine already understands modifiers
- the roll UI already explains modifiers well
- tags and action filtering already compose with them
- authors already understand the shape from treasures and harms

This should be an expansion of an existing language, not a new subsystem.

## Scope

In scope:

- new authored consequence to grant a full modifier payload
- new authored consequence to remove previously granted authored modifiers
- minimal `Modifier` model extension needed to make authored modifiers addressable
- consumption semantics for finite always-on modifiers
- validator coverage
- authoring reference and examples

Out of scope:

- bespoke status-effect UI beyond existing modifier surfacing
- duration systems like "until end of scene" if they require a separate timeline model
- custom scripting or trigger expressions
- reworking treasure or harm systems

## Proposed Content Additions

### 1. New Consequence: `grantModifier`

Purpose:

- add a full `Modifier` payload to one or more characters

Required fields:

- `modifier`
- `modifier.sourceKey`

Optional fields:

- `targetScope`
- `description`
- `conditions`

Example:

```json
{
  "type": "grantModifier",
  "targetScope": "allHere",
  "modifier": {
    "sourceKey": "tot_rope_anchor",
    "bonusDice": 1,
    "applicableActions": ["Finesse"],
    "requiredTag": "Traversal",
    "uses": 1,
    "isOptionalToApply": false,
    "description": "from Anchored Rope Line"
  },
  "description": "The rope line steadies everyone crossing the chamber."
}
```

### 2. New Consequence: `removeModifier`

Purpose:

- remove one or more previously granted modifiers without relying on runtime UUIDs

Required fields:

- `sourceKey`

Optional fields:

- `targetScope`
- `description`
- `conditions`

Example:

```json
{
  "type": "removeModifier",
  "targetScope": "allHere",
  "sourceKey": "tot_rope_anchor",
  "description": "The rope snaps loose and the steady footing is gone."
}
```

## Proposed Model Changes

### `Modifier`

Add:

- `sourceKey: String? = nil`

Purpose:

- gives authored modifiers a stable address that does not depend on runtime-generated UUIDs
- allows removal, deduplication, refresh, and debugging

Recommended semantics:

- treasures may optionally set `sourceKey` to treasure id
- harm boons may optionally set `sourceKey` from harm family + tier
- authored `grantModifier` should require an explicit `sourceKey`
- authored payloads may omit runtime `id`; if present, runtime should ignore it and assign a fresh UUID

### Authoring Note

`id: UUID` remains the runtime identity.

`sourceKey` is the authored identity.

This keeps runtime behavior stable while giving authors a string handle they can reason about.

## Consequence Payload Rules

### `grantModifier`

The `modifier` payload should mirror the existing `Modifier` authoring surface, with one v1 caveat:

- `id` is runtime-owned and should not be authored

Supported authored fields:

- `sourceKey`
- `bonusDice`
- `improvePosition`
- `improveEffect`
- `applicableToAction`
- `applicableActions`
- `requiredTag`
- `uses`
- `isOptionalToApply`
- `description`

### `removeModifier`

`removeModifier` should remove by `sourceKey`, not by runtime UUID and not by loose trait matching.

That keeps removal deterministic and keeps the mental model simple for authors:

- "grant this named state"
- "remove this named state"

## Runtime Semantics

### Granting

When `grantModifier` resolves:

1. evaluate consequence conditions as normal
2. resolve target characters using `targetScope`
3. copy the authored modifier payload onto each target, assigning a fresh runtime UUID
4. if `sourceKey` is present and the target already has a modifier with the same `sourceKey`, replace the old one
5. append narrative text through the normal consequence pipeline

Replacement-on-match is the safest v1 rule.

Why:

- avoids silent stacking bugs from repeated room hooks
- makes refresh-style authored states predictable
- gives authors a simple mental model

If authors want true stacking, they can use distinct `sourceKey` values.

This replacement should happen per target character, not globally.

### Removal

When `removeModifier` resolves:

1. resolve target characters using `targetScope`
2. remove all modifiers on each target whose `sourceKey` matches
3. if no match is found, do nothing

### Consumption

The engine should preserve current optional-modifier behavior and add one missing rule:

- optional modifiers with `uses > 0` are consumed when selected on a committed roll
- always-on modifiers with `uses > 0` are consumed when they materially affect a committed roll
- modifiers with `uses == 0` remain indefinite until removed

"Materially affect" means the modifier changed at least one of:

- dice pool
- final position
- final effect

Previewing a roll does not consume uses.

This is important because authored modifiers will often be automatic support states rather than opt-in consumables.

## Backward Compatibility

- Existing `modifyDice` content remains valid.
- Existing treasure and harm modifiers remain valid without authored `sourceKey`.
- `grantModifier` is additive authoring surface, not a migration requirement for existing scenarios.

This lets us open design space without forcing a broad content rewrite before freeze.

## Supported Interactions

`grantModifier` should compose with the existing modifier language:

- `bonusDice`
- `improvePosition`
- `improveEffect`
- `applicableToAction`
- `applicableActions`
- `requiredTag`
- `uses`
- `isOptionalToApply`
- `description`

That gives authors a lot of range without new rules text.

Examples unlocked immediately:

- setup actions
- NPC assistance
- room-specific support auras
- temporary injuries or fear states modeled as modifiers instead of only harm
- scenario bargains
- coordinated split-party support

## Recommended YAML Shape

```yaml
- type: grantModifier
  targetScope: othersHere
  description: "The guide calls the rhythm of the blades."
  modifier:
    sourceKey: tot_blade_timing_callout
    bonusDice: 1
    applicableActions:
      - Finesse
    requiredTag: Trap
    uses: 1
    isOptionalToApply: false
    description: from Called Timing
```

```yaml
- type: removeModifier
  targetScope: othersHere
  sourceKey: tot_blade_timing_callout
  description: "The shouted timing is lost in the noise."
```

## Validator Expectations

Add semantic checks:

- `grantModifier` must include a `modifier`
- `grantModifier.modifier.sourceKey` is required
- `removeModifier` must include `sourceKey`
- authored `modifier.id` should be ignored and warned on if present
- at least one mechanical effect must be present on granted modifier:
  - `bonusDice != 0`
  - or `improvePosition == true`
  - or `improveEffect == true`
- `uses` must be `>= 0`
- `targetScope` should be allowed on `grantModifier` and `removeModifier`

## UI / UX Impact

This pass should mostly reuse existing modifier presentation:

- roll projection notes
- optional boost list
- action-row state cues

One small quality improvement is recommended:

- if a new authored modifier is gained outside a roll, include its short mechanical summary in the fallout log when practical

Example:

- `Gain modifier: +1d from Anchored Rope Line.`

That makes support/setup actions feel more legible.

## Design Guidance For Authors

Prefer authored modifiers when the fiction is:

- "for the next roll"
- "while this support is active"
- "against this kind of obstacle"
- "in this room / against tagged content"

Prefer tags, flags, counters, or clocks when the fiction is:

- broad scenario memory
- route gating
- narrative-state branching
- escalating pressure

Prefer harm when the fallout should feel like injury, contamination, or a lasting expedition wound rather than a tactical state.

## Implementation Checklist

### 1. Data Contract And Codable Surface

- [ ] Add `sourceKey` to `Modifier` in `CardGame/Models.swift`, preserving backward-compatible decode for older saves and content.
- [ ] Add `grantModifier` and `removeModifier` to `Consequence.ConsequenceKind` in `CardGame/Models.swift`.
- [ ] Extend `Consequence` in `CardGame/Models.swift` with the payload needed for authored modifier grant/remove:
  - authored modifier payload
  - removal `sourceKey`
  - Codable support
  - convenience helpers if we still want static constructors
- [ ] Update `Consequence.supportsTargetScope` so `grantModifier` and `removeModifier` participate in the same scoped-target flow as other character-facing fallout.
- [ ] Decide whether `Modifier.sourceKey` should be optional at the model layer but required by authored validation, and document that split explicitly in code comments if so.

### 2. Authoring Schema And Compilation

- [ ] Update `Authoring/Schemas/common.schema.json` to allow `modifier.sourceKey`.
- [ ] Update `Authoring/Schemas/common.schema.json` to add `grantModifier` and `removeModifier` consequence types.
- [ ] Extend the consequence schema in `Authoring/Schemas/common.schema.json` with:
  - `modifier`
  - `sourceKey`
  - `targetScope` support for the new consequence kinds
- [ ] Confirm `Scripts/compile_scenarios.rb` does not need any special transformation for the new payloads beyond pass-through.
- [ ] Run `./Scripts/check_authored_scenarios.sh` once the schema changes are in to catch any unintentional contract regressions in existing authored content.

### 3. Runtime Execution

- [ ] Implement `grantModifier` resolution in `CardGame/ConsequenceExecutor.swift`.
- [ ] Reuse `scopedCharacterIDs` for targeting instead of inventing a parallel targeting path.
- [ ] On grant, assign a fresh runtime UUID even if authored content included `modifier.id`.
- [ ] On grant, replace by `sourceKey` per target character before appending the new modifier.
- [ ] Implement `removeModifier` resolution in `CardGame/ConsequenceExecutor.swift` by removing every modifier on each target whose `sourceKey` matches.
- [ ] Add a concise fallout-log message for newly granted modifiers so support/setup actions read clearly in play.

### 4. Roll Projection And Consumption

- [ ] Audit `CardGame/RollRulesEngine.swift` to separate "selected optional modifier consumption" from "automatic modifier consumption."
- [ ] Preserve current optional-modifier behavior for treasures, authored optional boosts, and `Push Yourself`.
- [ ] Add the new rule for always-on finite modifiers: consume only when the committed roll materially changed because of the modifier.
- [ ] Define "materially changed" in code at the same granularity as the spec:
  - dice pool changed
  - final position changed
  - final effect changed
- [ ] Ensure previews and roll recalculations in `GameViewModel` / `DiceRollView` do not consume uses.
- [ ] Confirm consumed authored modifiers are removed from both active character modifiers and any treasure-backed path that still relies on modifier identity.

### 5. Validation And Guardrails

- [ ] Extend `CardGame/ScenarioValidator.swift` to validate authored `grantModifier` payloads.
- [ ] Require `modifier.sourceKey` on authored `grantModifier`.
- [ ] Require `sourceKey` on authored `removeModifier`.
- [ ] Warn if authored `modifier.id` is present.
- [ ] Error if the granted modifier has no mechanical effect.
- [ ] Error if `uses < 0`.
- [ ] Keep legacy treasure and harm validation working unchanged.

### 6. Docs And Author Guidance

- [ ] Update `Docs/ScenarioAuthoringReference.md` with the new consequence types and their payload shapes.
- [ ] Add at least two examples to `Docs/ScenarioAuthoringReference.md`:
  - a one-roll support/setup modifier
  - a persistent curse/ward or room-state modifier
- [ ] Update `Docs/ScenarioAuthoringWalkthrough.md` with guidance on when to use `grantModifier` versus `modifyDice`.
- [ ] Make sure the docs explicitly say `modifyDice` remains valid but is no longer the preferred route for rich authored tactical states.

### 7. Regression Tests

- [ ] Add model decode/encode coverage for `Modifier.sourceKey`, `grantModifier`, and `removeModifier`.
- [ ] Add consequence execution tests for:
  - acting-character grant
  - `othersHere`
  - `allHere`
  - `allParty`
  - remove-by-`sourceKey`
  - replace-on-same-`sourceKey`
- [ ] Add roll-resolution tests proving always-on finite modifiers consume only when they actually affect the committed roll.
- [ ] Add save/load coverage proving authored modifiers persist correctly across `SaveGameStore`.
- [ ] Add validator tests for malformed payloads and warnings.

### 8. Content Proof Before Freeze

- [ ] Update one canonical authored scenario to use `grantModifier` in at least two different patterns.
- [ ] Prefer one proactive support pattern and one pressure/debuff pattern so the feature proves both halves of its design value.
- [ ] Verify the scenario remains readable as an authoring example, not just a mechanics dump.

### 9. Verification Pass

- [ ] Run `./Scripts/run_tests.sh unit`.
- [ ] Run `./Scripts/check_authored_scenarios.sh`.
- [ ] Play a short debug branch that grants, consumes, refreshes, and removes an authored modifier.
- [ ] Confirm no regression to treasure modifiers, harm boons, or `Push Yourself`.

## Testing Expectations

Add tests for:

- granting a modifier to the acting character
- granting scoped modifiers to `othersHere` / `allHere` / `allParty`
- removing by `sourceKey`
- replacement behavior when granting the same `sourceKey` twice
- automatic finite modifier consumption on committed roll
- optional finite modifier consumption preserving current behavior
- save/load persistence for authored modifiers
- validator rejection for malformed payloads

## Definition of Done

- Scenario authors can grant and remove full modifiers through consequences.
- Authored modifiers are addressable by `sourceKey` rather than runtime UUID.
- Finite always-on modifiers consume predictably on committed rolls.
- Existing treasure and harm modifier behavior remains intact.
- The authoring reference gains at least two concrete examples using authored modifiers for support or pressure states.
