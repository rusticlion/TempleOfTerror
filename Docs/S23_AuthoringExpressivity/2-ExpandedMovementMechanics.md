## Task 2: Expanded Movement Mechanics

**Goal:** Make movement a richer authored design surface by supporting broader character relocation consequences and node-level room hooks for `onEnter` and `onFirstEnter`.

## Why This Pass Exists

The current engine already supports:

- normal connection-based travel
- connection conditions
- connection `onTraverse`
- local threat engagement that blocks movement
- split-party state queries
- `moveActingCharacterToNode`

That is enough for basic navigation and some traversal actions, but it still leaves authors doing awkward work when they want rooms to feel active.

Current pain points:

- forced movement can only move the acting character
- movement beats that affect a whole group require brittle workarounds
- room-level reveals must be duplicated across every inbound connection if they are automatic
- first-time room scenes do not have a clean primitive
- recurring room hazards on entry also require duplicated connection logic

This especially matters for the game the PRD says we are making:

- vulnerable expeditions
- meaningful split vs stay-together choices
- authored branching outcomes
- rooms that feel like scenes, not just containers

## Recommendation On `onEnter` / `onFirstEnter`

Keep them.

I would not talk us out of these hooks as long as we keep them constrained.

Why they are worth it:

- `onTraverse` is path-centric, not room-centric
- a room with multiple inbound routes should not require duplicated consequence bundles
- forced movement from actions or consequences should still trigger room behavior consistently
- first-time reveals are a core authored-scene tool

What would be dangerous is turning nodes into mini scripts.

So the recommendation is:

- add `onEnter` and `onFirstEnter`
- keep them as plain consequence arrays
- route them through the existing consequence pipeline
- do not add custom node-hook conditions or a separate trigger language in v1

That keeps them high leverage without becoming an ad hoc event system.

## Scope

In scope:

- generalized authored relocation beyond only the acting character
- room-level `onEnter`
- room-level `onFirstEnter`
- clear semantics for grouped vs solo movement
- validator and authoring reference updates
- tests for hook timing and persistence

Out of scope:

- `onExit`
- room-local scripting languages
- per-character first-enter memory
- animation redesign for movement
- tactical positioning within a room

## Proposed Content Additions

### 1. Expand Movement Consequences

Preferred v1 direction:

- keep `moveActingCharacterToNode`
- add `targetScope` support to it

Why this is preferable to inventing a second movement type:

- keeps backward compatibility
- authors already know the consequence name
- matches the existing scoped-fallout pattern

Updated semantics:

- default `targetScope` remains `actingCharacter`
- newly supported scopes:
  - `allHere`
  - `othersHere`
  - `allParty`

Meaning:

- `actingCharacter`: current behavior
- `allHere`: move everyone currently in the acting character's node
- `othersHere`: move everyone else currently in the acting character's node
- `allParty`: move every non-defeated party member

Important cohort rule:

- resolve the target cohort against the source room before any relocation happens
- move that snapshot together
- do not newly include characters who were already standing in the destination

That rule is what makes grouped movement predictable.

Example:

```json
{
  "type": "moveActingCharacterToNode",
  "toNodeID": "00000000-0000-0000-0000-000000000009",
  "targetScope": "allHere",
  "description": "The freight lift drops the whole team into Engineering."
}
```

This one change unlocks:

- forced splits
- emergency regroups
- collapses that dump multiple explorers elsewhere
- escort / rescue beats
- authored escape sequences

### 2. Add `onEnter` to `MapNode`

Purpose:

- consequences that fire every time the node is entered

Shape:

- optional `[Consequence]`

Use cases:

- recurring spores or radiation
- "the ghost notices you again"
- room-wide pressure ticks
- automatic reveal of pressure options or threats
- doors slamming, alarms rearming, lights flickering

### 3. Add `onFirstEnter` to `MapNode`

Purpose:

- consequences that fire only the first time the expedition enters the node during the run

Shape:

- optional `[Consequence]`

Use cases:

- first-time ambush
- initial discovery narration
- reveal new interactables
- spring a one-time trap
- mark scenario state when the room has truly been reached

## Proposed Model Changes

### `MapNode`

Add:

- `onEnter: [Consequence]? = nil`
- `onFirstEnter: [Consequence]? = nil`

### `GameState`

Add:

- `triggeredFirstEnterNodeIDs: [String] = []`

Use string UUIDs for save compatibility, matching other map-state patterns.

Do not overload `isDiscovered` for this.

Why:

- a node can be pre-discovered without having had its first-enter scene resolved in the current run
- discovery is visual state
- first-enter is authored trigger state

Keeping them separate avoids hidden coupling.

## Additional Runtime Decisions

### Who Counts As A Target For Scoped Movement?

- `allParty` means every non-defeated party member
- `allHere` means every non-defeated party member in the acting character's source node
- `othersHere` means the same cohort except the acting character

If the resolved target set is empty, the movement consequence becomes a no-op and should not fire node hooks.

### What If The Destination Is The Same Node?

Treat authored same-node relocation as a no-op.

Rationale:

- authors should not have to reason about fake re-entry
- `onEnter` should track real arrivals, not internal self-targeting tricks
- same-node moves are more likely to be authoring mistakes than intentional design

Validator guidance:

- warn when a fixed authored movement consequence obviously targets the acting character's current node

## Core Runtime Semantics

### Order Of Operations On Movement

For any successful move into a node:

1. apply relocation
2. mark destination discovered
3. determine whether this is the node's first enter for the run
4. process connection `onTraverse`
5. process node `onFirstEnter` if eligible
6. process node `onEnter`
7. persist result

Why this order:

- `onTraverse` remains about the path itself
- node hooks remain about the destination
- `onFirstEnter` establishes the room state before recurring `onEnter` pressure lands

If an earlier step creates a pending choice or resistance decision, later steps should wait until that pending frame resolves. In practice, that means `onEnter` should not start firing underneath an unresolved `onFirstEnter` choice.

### Starting Node Semantics

The scenario entry node should count as entered.

Therefore:

- `onFirstEnter` should fire for the starting node when a new run begins
- `onEnter` should also fire for the starting node when a new run begins

This is important for:

- opening scenes
- immediate scenario pressure
- "the room is already dangerous" starts

If a scenario wants a quiet start, authors simply leave those hooks empty.

Implementation note:

- new-run startup should route through the same node-hook executor as later movement so authored behavior stays consistent

### Grouped Movement Semantics

When the grouped party enters a node:

- hooks fire once per move, not once per party member
- the initiating character is the consequence context's acting character
- all moved characters are already in the destination when hooks resolve

This means:

- default `actingCharacter` consequences affect only the mover
- authors should use `targetScope: allHere` when the room effect should hit everyone who arrived together

This is the least surprising rule operationally and avoids duplicate room reveals.

`currentNodeID` should continue to follow the acting character's post-resolution location.

That means:

- if the acting character moves, focus shifts with them
- if `othersHere` moves other explorers away while the acting character stays put, the UI focus should remain in the source room

### Forced-Movement Semantics

If `moveActingCharacterToNode` is triggered by an action or consequence:

- destination discovery still happens
- node hooks still fire
- `actingCharacter` for node hooks is the character that initiated the move consequence
- connection `onTraverse` does not fire unless a real `NodeConnection` was traversed

If `targetScope` moved multiple characters:

- hooks still fire once using the original acting character as context

### Re-Entry Semantics

- `onFirstEnter` fires only once per node per run
- `onEnter` fires every successful arrival
- debug jumps may ignore or manually retrigger these hooks at tool discretion; authoring semantics should be defined only for real runtime movement and new-run startup

## Why Existing Primitives Are Not Enough

### Why Not Just Use `onTraverse`?

Because `onTraverse` is attached to an inbound connection, which creates duplication and blind spots:

- one room with three inbound routes needs three copies
- forced movement from actions skips connection traversal entirely
- content becomes path-authored when the intent is room-authored

### Why Not Just Add Display-Only Interactables?

Because automatic scenes are meaningfully different from actionable cards:

- a one-time ambush should not require the player to "click the ambush"
- a room that always inflicts spores on entry should not be modeled as a normal interactable
- authors should not need fake room bootstrap cards for basic scene framing

### Why Not Add a Full Event Trigger System Instead?

Because node hooks already become sufficient once they can trigger normal consequence bundles and events.

We should reuse:

- consequence arrays
- `triggerEvent`
- conditions on consequences

not introduce a third orchestration language.

## Authoring Guardrails

- `onFirstEnter` should generally carry the room's introduction, reveal, or one-time twist.
- `onEnter` should carry recurring pressure, not routine flavor text.
- Authors should not need both a path `onTraverse` and a node `onEnter` for the same fictional beat; if both are present, they should clearly describe different things.
- If a room hook needs complex branching, prefer `triggerEvent` or `createChoice` inside the hook over inventing multiple near-duplicate hook bundles.

## Recommended Authoring Examples

### Example 1: One-Time Reveal

```yaml
nodes:
  séance_room:
    name: Seance Room
    onFirstEnter:
      - type: addInteractableHere
        interactable:
          id: sod_whispering_circle
          title: Whispering Circle
          description: Candles flare to life around a chalk ring.
          availableActions:
            - name: Break the circle
              actionType: Wreck
              position: risky
              effect: standard
              outcomes:
                success:
                  - type: removeInteractable
                    id: self
```

### Example 2: Recurring Room Pressure

```yaml
nodes:
  flooded_shaft:
    name: Flooded Shaft
    onEnter:
      - type: tickClock
        clockName: Rising Water
        amount: 1
        description: Every entry stirs the water level higher.
```

### Example 3: Forced Split

```yaml
- type: moveActingCharacterToNode
  toNodeID: lower_catwalk
  description: The catwalk breaks beneath you.
```

### Example 4: Whole-Team Evacuation

```yaml
- type: moveActingCharacterToNode
  toNodeID: escape_dock
  targetScope: allHere
  description: The freight platform carries the whole team to the dock.
```

## Validator Expectations

Add checks for:

- `onEnter` consequence arrays validate like any other consequence list
- `onFirstEnter` consequence arrays validate like any other consequence list
- movement consequences may now use `targetScope`
- warn if `onFirstEnter` contains obvious repeat-only pressure patterns better suited for `onEnter`
- warn if a node has both `onFirstEnter` and `onEnter` and they are structurally identical, which often signals accidental duplication

Keep this as guidance, not hard failure.

## UI / UX Expectations

This should mostly reuse the current resolution flow.

Important requirement:

- node-hook fallout must appear through the same consequence / resistance presentation as action fallout

That means:

- entering a room can surface authored aftermath
- entering a room can pause for resistance
- entering a room can present a choice if the hook creates one

This is desirable.

It makes rooms feel authored and consequential.

## Design Guidance For Authors

Use `onFirstEnter` for:

- reveals
- first-time jumpscares
- room introduction beats
- spawning unique interactables
- starting local clocks

Use `onEnter` for:

- recurring environmental pressure
- recurring cost of revisiting
- room-wide movement tax
- "being here is dangerous" fiction

Use `onTraverse` for:

- effects tied to a specific path
- bridge collapse while crossing
- tripwire in a particular doorway
- route-specific stealth or exposure

## Risks And Guardrails

### Risk: Authors Overuse Automatic Fallout

Guardrail:

- document that not every room should auto-fire
- recurring `onEnter` should be used for pressure, not routine flavor copy

### Risk: Grouped Entry Feels Unclear

Guardrail:

- keep context rule simple: hooks fire once, initiator is acting character
- encourage `targetScope: allHere` for room-wide consequences

### Risk: Node Hooks Become Hidden Scripts

Guardrail:

- keep them as plain consequence arrays
- do not add bespoke hook-only condition language yet
- route through existing logging and pending-resolution UI

## Implementation Checklist

### 1. Data Contract And Persistence

- [ ] Add `onEnter` and `onFirstEnter` to `MapNode` in `CardGame/Models.swift`.
- [ ] Add first-enter tracking state to `GameState` in `CardGame/Models.swift`.
- [ ] Update `GameState` Codable keys, init, decode, and encode so first-enter memory survives save/load.
- [ ] Extend `Consequence.ConsequenceKind` / `Consequence.supportsTargetScope` in `CardGame/Models.swift` so `moveActingCharacterToNode` can honor scoped movement.
- [ ] Keep backward compatibility for existing save files and content that do not include any of the new fields.

### 2. Authoring Schema And Validation Surface

- [ ] Update `Authoring/Schemas/common.schema.json` so `mapNode` supports `onEnter` and `onFirstEnter`.
- [ ] Update `Authoring/Schemas/common.schema.json` so `moveActingCharacterToNode` can legally carry `targetScope`.
- [ ] Confirm the YAML compiler in `Scripts/compile_scenarios.rb` passes the new node-hook arrays and movement payloads through without special-case transformation.
- [ ] Extend `CardGame/ScenarioValidator.swift` to validate node hooks anywhere a map node is loaded.
- [ ] Add validator guidance for suspicious cases:
  - structurally identical `onFirstEnter` and `onEnter`
  - obvious repeat pressure in `onFirstEnter`
  - clearly self-targeting same-node moves when they can be statically detected

### 3. Shared Movement Execution Path

- [ ] Refactor movement orchestration so normal traversal, forced movement consequences, and new-run startup can all flow through one shared "enter node" path.
- [ ] Avoid duplicating node-hook logic across `ScenarioRuntime`, `RunSessionController`, and `ConsequenceExecutor`.
- [ ] Decide whether `ScenarioRuntime.MoveOutcome` needs to carry extra metadata for node-hook processing, and only expand it if that removes real duplication.
- [ ] Preserve the distinction between:
  - connection traversal, which can fire `onTraverse`
  - arbitrary relocation, which cannot

### 4. Scoped Movement Semantics

- [ ] Implement `moveActingCharacterToNode` targeting in `CardGame/ConsequenceExecutor.swift` using the same `ConsequenceTargetScope` enum already used elsewhere.
- [ ] Snapshot the movement cohort from the source room before relocation happens.
- [ ] Ensure `allHere` and `othersHere` only target party members in the acting character's current node.
- [ ] Ensure `allParty` targets every non-defeated party member.
- [ ] Treat empty target sets as no-ops.
- [ ] Treat same-node relocation as a no-op.
- [ ] Keep `currentNodeID` following the acting character after scoped movement resolves.

### 5. Node-Hook Runtime Flow

- [ ] Add a single executor path for node hooks that can run:
  - on new-run startup
  - after successful connection traversal
  - after forced movement consequences
- [ ] Apply destination discovery before hook resolution.
- [ ] Resolve first-enter eligibility from dedicated `GameState` tracking, not `isDiscovered`.
- [ ] Run hook order exactly as specified:
  - `onTraverse`
  - `onFirstEnter`
  - `onEnter`
- [ ] Ensure grouped entry fires hooks once per arrival, not once per arriving character.
- [ ] Ensure all moved characters are already in the destination when node hooks resolve.
- [ ] Keep node-hook fallout inside the existing pending-resolution pipeline so choices and resistance pauses behave normally.
- [ ] Ensure `onEnter` does not run underneath an unresolved `onFirstEnter` pending frame.

### 6. Startup And Debug Semantics

- [ ] Route new-run starting-node entry through the same node-hook executor used by runtime movement.
- [ ] Confirm the starting node can fire both `onFirstEnter` and `onEnter` on run start.
- [ ] Decide and document whether debug jump tools should bypass hooks, offer an explicit "trigger hooks" mode, or mimic runtime behavior.
- [ ] Keep debug semantics explicit so authors do not misread tool behavior as canonical runtime behavior.

### 7. UI And Log Legibility

- [ ] Reuse the existing consequence log / pending-resolution UI for room-entry fallout.
- [ ] Confirm resistance prompts, created choices, and narrative lines from node hooks read clearly when they happen outside a normal interactable tap.
- [ ] Verify ambient-audio sync still follows the final focused room after movement plus hook resolution.
- [ ] Sanity-check that a grouped forced move plus room hook does not leave the node screen focused on the wrong location.

### 8. Regression Tests

- [ ] Add model decode/encode tests for `MapNode.onEnter`, `MapNode.onFirstEnter`, and first-enter save data.
- [ ] Add validator tests for legal and malformed node-hook payloads.
- [ ] Add runtime tests for:
  - `onFirstEnter` fires once
  - `onEnter` fires on every real arrival
  - connection `onTraverse` runs before node hooks
  - forced movement triggers destination hooks
  - grouped movement triggers hooks once
  - `allHere` in a node hook affects the full arriving cohort
  - same-node relocation does not retrigger entry hooks
  - startup entry fires starting-node hooks
- [ ] Add save/load coverage proving first-enter memory persists across reloads.

### 9. Content Proof Before Freeze

- [ ] Update one canonical scenario with a one-time reveal via `onFirstEnter`.
- [ ] Update one canonical scenario with a recurring room-pressure beat via `onEnter`.
- [ ] Add at least one authored regroup or split beat using scoped `moveActingCharacterToNode`.
- [ ] Prefer proving these in scenario content rather than only in tests so future authors have a readable pattern to copy.

### 10. Verification Pass

- [ ] Run `./Scripts/run_tests.sh unit`.
- [ ] Run `./Scripts/check_authored_scenarios.sh`.
- [ ] Launch a short authored run and verify:
  - starting-room hooks
  - repeated re-entry hooks
  - forced movement into a hooked room
  - grouped relocation with room-wide fallout
- [ ] Use Author Tools only as a supplement, not as the primary proof of room-hook semantics.

## Testing Expectations

Add tests for:

- `onFirstEnter` fires exactly once
- `onEnter` fires on every successful arrival
- starting node hooks fire on new run
- grouped movement triggers hooks once, with `allHere` affecting the full arriving cohort
- forced movement consequence triggers destination hooks
- connection `onTraverse` runs before node hooks
- save/load preserves first-enter memory
- validator accepts and rejects hook payloads correctly

## Definition of Done

- Authors can express room-level recurring and first-time consequences directly on nodes.
- Authors can relocate cohorts, not only the acting character.
- Connection `onTraverse`, node `onFirstEnter`, and node `onEnter` each have clear, documented semantics.
- Node-hook fallout uses the normal consequence, resistance, and choice pipeline.
- At least one canonical scenario should be updated afterward to demonstrate:
  - a one-time room reveal
  - a recurring room-entry pressure hook
  - a split or regroup movement consequence
