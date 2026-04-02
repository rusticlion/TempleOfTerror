# Scenario Authoring Walkthrough (v1)

This is the practical step-by-step guide for creating or extending a scenario with the current YAML-first workflow.

Use this alongside `Docs/ScenarioAuthoringReference.md`.

- This walkthrough explains the recommended flow.
- The reference doc defines the actual content contract.
- If the two ever disagree, the reference doc wins.

## What This Covers

This walkthrough assumes you are authoring a scenario in:

- `Authoring/Scenarios/<scenario_id>/` as the source of truth
- `Content/Scenarios/<scenario_id>/` as generated runtime JSON

It reflects the current repo workflow:

1. author YAML
2. compile to runtime JSON
3. validate
4. inspect the generated preview
5. playtest with Author Tools

## 1. Decide the Scenario Shape

Before creating files, decide these basics:

- `scenario_id`
  - use lowercase snake_case
  - example: `shadow_of_a_doubt`
- authored structure
  - prefer a fixed map for most v1 scenarios
  - use procgen only if the scenario is intentionally template-driven
- party assumptions
  - party size
  - native archetype roster
- core pressure model
  - what clocks, harms, and scenario flags/counters drive the branches
- win/fail shape
  - what endings are possible
  - what makes the scenario escalate or collapse

Current v1 engine primitives are already broad enough for substantial scenario work. Avoid inventing new content structures unless the existing contract actually blocks the design.

## 2. Scaffold the Scenario

Start from the scaffold script instead of hand-creating the folder:

```bash
./Scripts/scaffold_authoring.rb scenario shadow_of_a_doubt "Shadow of a Doubt" \
  --description "A haunted house where consciousness itself is under attack." \
  --starting-node-id front_steps \
  --starting-node-name "Front Steps"
```

This creates:

- `Authoring/Scenarios/<scenario_id>/scenario.yaml`
- `Authoring/Scenarios/<scenario_id>/archetypes.yaml`
- `Authoring/Scenarios/<scenario_id>/map.yaml`
- `Authoring/Scenarios/<scenario_id>/clocks.yaml`
- `Authoring/Scenarios/<scenario_id>/treasures.yaml`
- `Authoring/Scenarios/<scenario_id>/harm_families.yaml`
- `Authoring/Scenarios/<scenario_id>/interactables.yaml`
- empty `events/` and `interactables/` folders for split files

The templates are intentionally simple and already include schema modelines where supported.

## 3. Fill In the Core Files

### `scenario.yaml`

Set the scenario identity and runtime entry points:

- `id`
- `title`
- `description`
- `entryNode`
- `mapFile`
- `partySize`
- `nativeArchetypeIDs`
- `stressOverflowHarmFamilyID`

For fixed-map scenarios, keep `entryNode` aligned with a node in `map.yaml`.

### `archetypes.yaml`

Define the scenario-native party roster.

Each archetype should be usable and distinct enough that random party generation produces meaningful variation.

### `map.yaml`

Use symbolic node ids here. This is the biggest authoring improvement over the runtime JSON.

Recommended pattern:

- keep room-specific interactables inline on nodes
- use node-local comments for reveal cadence or tone notes
- make node ids stable once content starts branching around them

Use inline interactables when the content is unique to one room.

### `interactables.yaml`

Use this for shared or library-style interactables that are not tied to a single room.

Grouped interactables are the normal pattern:

- `hazards`
- `opportunities`
- `threats`

If the scenario grows, split reusable entries into `interactables/*.yaml`.

Each split interactable file should declare `authoringGroup`.

### `clocks.yaml`

Add scenario pressure and longer-form progress here.

Use clocks when the scenario wants visible escalation, delayed payoffs, or state that multiple branches can push on.

### `treasures.yaml`

Author scenario-specific rewards and modifiers here.

Prefer treasures that reinforce scenario identity rather than generic numeric upgrades.

### `harm_families.yaml`

Add scenario-local harm only when the global catalog is not expressive enough.

The best local harms communicate both fiction and mechanics.

## 4. Add Branching Content

Use the current authoring split deliberately:

- actions handle immediate room-level interaction
- consequences handle atomic state changes
- events handle reusable orchestration
- flags/counters handle scenario-level branching state

Recommended structure:

- keep direct action outcomes readable and local
- move repeated or conditional bundles into events
- use flags/counters for scenario memory
- use clocks for visible pressure, not invisible bookkeeping

Use the newer room/state primitives deliberately:

- use `grantModifier` when a scene should create a visible temporary state that can matter on later rolls
- use `removeModifier` when that state should be cleaned up explicitly by room flow or a resolving action
- use node `onFirstEnter` for a room's one-time reveal or setup beat
- use node `onEnter` for recurring pressure every time explorers arrive
- use scoped `moveActingCharacterToNode` when a trap, guide, escort, or supernatural effect should relocate a full local cohort

Current concrete example:

- `Authoring/Scenarios/shadow_of_a_doubt/map.yaml` now includes a small authored slice showing:
  - a support action that grants a modifier to `othersHere`
  - an action that unlocks a path and force-moves `allHere`
  - a room `onFirstEnter` hook that grants a temporary room-state modifier
  - a room `onEnter` hook that applies recurring pressure
  - a return-room `onEnter` hook that clears the room-specific modifier

For larger scenarios, create split event files:

```bash
./Scripts/scaffold_authoring.rb event shadow_of_a_doubt sod_house_turns_hostile
```

For reusable interactables:

```bash
./Scripts/scaffold_authoring.rb interactable shadow_of_a_doubt sod_locked_nursery --group hazards --action-type Study
```

For map expansion:

```bash
./Scripts/scaffold_authoring.rb node shadow_of_a_doubt nursery "The Nursery"
```

## 5. Compile the Runtime Output

Compile authored YAML into runtime JSON:

```bash
./Scripts/compile_scenarios.sh shadow_of_a_doubt
```

This writes generated output to:

- `Content/Scenarios/shadow_of_a_doubt/`

Review the generated JSON after structural changes.

Current expectation is:

- YAML is the source of truth
- generated JSON remains committed

Do not treat the generated JSON as the main authoring surface.

## 6. Run the One-Command Authoring Check

Prefer this during active development:

```bash
./Scripts/check_authored_scenarios.sh shadow_of_a_doubt
```

This currently does four things:

1. validates authored YAML against the local schemas
2. compiles authored YAML
3. validates the generated runtime scenario
4. refreshes the authored preview in `Authoring/Previews/`

Use plain validator runs when you only need semantic validation:

```bash
./Scripts/validate_scenarios.sh Content/Scenarios/shadow_of_a_doubt
```

## 7. Read the Generated Preview

For fixed-map scenarios, the authoring check refreshes:

- `Authoring/Previews/<scenario_id>_map_preview.md`

That preview is useful for catching:

- disconnected or unreachable nodes
- locked-path mistakes
- thin content coverage in specific rooms
- mismatch between intended scope and actual authored counts

It includes:

- scenario summary
- content-surface counts
- map metrics
- Mermaid diagram
- per-node interactable and connection counts

You can also regenerate it directly:

```bash
./Scripts/preview_authored_map.rb shadow_of_a_doubt
```

## 8. Playtest With Author Tools

After the authoring check is clean, open the app in a debug build and start the scenario.

Use the in-app **Author Tools** to verify branches quickly:

- fixed dice override
- node jump
- scenario state inspection
- flag/counter editing
- treasure grants
- modifier grants

Recommended playtest loop:

1. run `check_authored_scenarios.sh`
2. skim the preview
3. launch the scenario
4. force the key branches with Author Tools
5. adjust content
6. rerun the check

## 9. When to Split Files

Split only when readability improves.

Good reasons to split:

- an event chain has grown long enough to hide the main scenario flow
- an interactable is reused or important enough to deserve its own file
- the top-level files are becoming hard to scan in review

Bad reasons to split:

- very small one-off content with no reuse
- speculative modularity that makes the scenario harder to read

`temple_of_terror` is currently the cleanest reference scenario for the authored YAML flow.

## 10. Asset Requests

If a new scenario needs an asset you cannot create directly, add a placeholder markdown doc under:

- `CardGame/AssetPlaceholders/`

Describe:

- what the asset is
- where it is used
- tone/style expectations
- format expectations

Do not edit `Assets.xcassets` directly as part of authoring prep.

## 11. Authoring Checklist

Before considering a scenario branch or milestone ready:

- the YAML source reads cleanly without needing the generated JSON for context
- `./Scripts/check_authored_scenarios.sh <scenario_id>` passes
- the preview looks structurally correct
- the critical branches were playtested with Author Tools
- required assets have placeholder docs if they do not exist yet
- any new primitive request is justified by a real content blocker, not convenience

## 12. What Not to Expect From the Walkthrough

This walkthrough does not redefine the authoring contract.

For the canonical answers on:

- supported action types
- supported conditions
- supported consequence types
- threat behavior
- endings
- required vs optional files

see `Docs/ScenarioAuthoringReference.md`.
