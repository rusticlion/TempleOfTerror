## Task 6: Design a YAML Authoring Layer

**Goal:** Add a human-friendly scenario authoring layer in front of the existing JSON runtime contract so `temple_of_terror`, `charons_bargain`, and `shadow_of_a_doubt` can grow without content work becoming brittle.

## Decision

Keep JSON as the runtime and bundle format.

Add YAML as the source-of-truth authoring format.

Compile YAML sources into the existing `Content/Scenarios/<scenario_id>/` JSON files.

This keeps the engine stable while improving author ergonomics.

## Why This Layer Exists

The current JSON contract is acceptable for the engine, but weak for scenario writing:

- large nested structures are hard to scan
- repeated inline interactables cause copy-paste drift
- fixed maps require UUID-heavy editing
- events and map nodes are hard to split into readable source files
- JSON has no comments
- validator errors point at generated shapes rather than design intent

`charons_bargain` already demonstrates all of these issues:

- repeated droid threat payloads inside events
- deeply nested event consequences
- map nodes that would be easier to author with symbolic node ids
- authored state that wants comments and local structure

## Non-Goals

This layer should **not**:

- replace the runtime loader
- replace the current JSON schema in app code
- introduce a full custom editor
- change the current validator's semantic rules
- require scenario authors to learn a large DSL up front

The first version should be a compiler and a thin amount of authoring sugar, not a new engine.

## Proposed Directory Layout

Runtime output remains where it is now:

- `Content/Scenarios/<scenario_id>/...json`

Authoring source lives separately:

- `Authoring/Scenarios/<scenario_id>/`

Proposed source layout:

```text
Authoring/
  Scenarios/
    charons_bargain/
      scenario.yaml
      archetypes.yaml
      clocks.yaml
      treasures.yaml
      harm_families.yaml
      map.yaml
      events/
        game_over_coward_ending.yaml
        cb_reactor_meltdown.yaml
        cb_vfe_deactivated.yaml
        cb_droid_evaded_moves_node.yaml
      interactables/
        cb_corrupted_maintenance_droid.yaml
        cb_docking_beacon.yaml
    temple_of_terror/
      scenario.yaml
      archetypes.yaml
      clocks.yaml
      treasures.yaml
      harm_families.yaml
      map.yaml
      interactables/
        tot_sun_seal.yaml
        tot_guardian_relief.yaml
    shadow_of_a_doubt/
      scenario.yaml
      archetypes.yaml
      clocks.yaml
      map.yaml
      events/
      interactables/
```

Rationale:

- runtime content remains clean and bundle-ready
- authored source can be split across multiple files
- shared scenario-local interactables can be reused from a library folder
- `events/` and `interactables/` become readable units

## Source of Truth

Author-facing YAML is the source of truth.

Compiled JSON should still be committed for now.

That gives the team:

- simple app/runtime behavior
- no compile step required just to launch the app
- straightforward diffs for generated runtime payloads
- a future path to make generated JSON derived-only once the compiler is trusted

Near-term workflow:

1. Edit YAML in `Authoring/Scenarios/<scenario_id>/`
2. Run compile script
3. Review generated JSON diff in `Content/Scenarios/<scenario_id>/`
4. Run existing validator on generated JSON
5. Launch and playtest

## Compiler Entry Point

Add a repo script:

```bash
./Scripts/compile_scenarios.sh
```

Optional single-scenario mode:

```bash
./Scripts/compile_scenarios.sh charons_bargain
```

Validation flow becomes:

```bash
./Scripts/compile_scenarios.sh
./Scripts/validate_scenarios.sh
```

Later, `validate_scenarios.sh` can optionally compile first, but the initial rollout should keep compile and validate separate for clarity.

## Compiler Responsibilities

The compiler should do only these things in v1:

- load YAML source files for one scenario
- merge multi-file content into canonical JSON documents
- resolve symbolic references
- expand small authoring conveniences into full JSON payloads
- produce stable, deterministic output ordering
- report source-file-aware errors

It should not attempt game-balance analysis or scenario linting beyond structural compilation.

## Authoring Conveniences Worth Supporting in v1

### 1. Symbolic Node IDs

Authors should write:

```yaml
nodes:
  docking_bay:
    name: Docking Bay
```

The compiler should emit deterministic UUIDs into generated JSON.

Recommended rule:

- derive UUIDs from `scenario_id + symbolic_node_id`
- keep them stable across compiles

This removes the biggest fixed-map pain point without changing runtime expectations.

### 2. File-Split Events

Instead of one large `events.json`, allow:

- one YAML file per event in `events/`

Compiler output:

- one merged `events.json`

This is especially important for `charons_bargain`, where authored event chains are already substantial.

### 3. Reusable Interactable Templates

Allow scenario-local interactables to live in `interactables/*.yaml` and be referenced from:

- map nodes
- `addInteractable`
- `addInteractableHere`

This directly addresses repeated threat payloads like the maintenance droid.

### 4. Consequence Shorthand

The YAML layer should support a small amount of sugar for common consequence patterns.

Examples:

```yaml
- remove: self
- gain_stress: 1
- tick: { clock: Droid Pursuit, amount: 1 }
- event: cb_droid_evaded_moves_node
- set_flag: cb_lab_location_known
```

Compiler output should still be the existing explicit JSON consequence objects.

### 5. Comments

YAML comments are a feature, not an afterthought.

We should expect authors to annotate:

- intended reveal cadence
- fallback branches
- why a threat is marked `usableUnderThreat`
- narrative tone notes

## YAML Shape

The YAML authoring layer should remain close enough to the JSON contract that authors can still understand the runtime model.

Do not invent a highly abstract narrative language in v1.

Good rule:

- YAML should be "JSON, but nicer to write"
- plus references, templates, and small shorthand

## Example: Interactable Template

```yaml
id: cb_corrupted_maintenance_droid
title: Corrupted Maintenance Droid
description: >
  Its optical sensors are overgrown with twitching organic matter.
  It moves erratically.
isThreat: true
tags:
  - Mechanical
  - VFE-corrupted
  - Hostile
actions:
  - name: Disable Droid
    actionType: Wreck
    position: risky
    effect: standard
    outcomes:
      success:
        - remove: self
      partial:
        - harm: { level: lesser, family: vfe_physical_aberration }
        - gain_stress: 1
      failure:
        - harm: { level: moderate, family: vfe_physical_aberration }
  - name: Evade Droid
    actionType: Finesse
    position: desperate
    effect: limited
    outcomes:
      success:
        - event: cb_droid_evaded_moves_node
      failure:
        - tick: { clock: Droid Pursuit, amount: 1 }
```

Compiler notes:

- `actions` compiles to `availableActions`
- shorthand consequences expand to current JSON

## Example: Event Using a Reusable Interactable

```yaml
id: cb_droid_evaded_moves_node
consequences:
  - remove: self
    description: You slip past the droid as it clatters into the ventilation shafts.

  - add_interactable:
      node: main_corridor
      from_template: cb_corrupted_maintenance_droid
    description: A moment later, your tracker pings from the Main Corridor.
    when:
      scenarioCounter:
        id: cb_droid_relocations
        min: 0
        max: 0

  - add_interactable:
      node: crew_quarters
      from_template: cb_corrupted_maintenance_droid
    description: The sound of metal on decking erupts again up in the Crew Quarters.
    when:
      scenarioCounter:
        id: cb_droid_relocations
        min: 1
        max: 1

  - add_interactable:
      node: escape_pods
      from_template: cb_corrupted_maintenance_droid
    description: The droid races ahead, stalking the route toward the escape pods.
    when:
      scenarioCounter:
        id: cb_droid_relocations
        min: 2
        max: 2

  - increment_counter:
      id: cb_droid_relocations
```

This is the kind of source the team can actually maintain.

## Example: Fixed Map Authoring

```yaml
entry: docking_bay

nodes:
  docking_bay:
    name: Docking Bay
    soundProfile: metal_echoes_large
    discovered: true
    interactables:
      - ref: cb_ferryman_shuttle_ready
      - ref: cb_docking_beacon
    connections:
      - to: main_corridor
        description: Step through the blasted pressure hatch
        unlocked: true

  main_corridor:
    name: Main Corridor
    soundProfile: metal_echoes
    interactables: []
    connections:
      - to: docking_bay
        description: Return to Docking Bay
        unlocked: true
```

Compiler output:

- `entry` resolves to generated UUID
- `to` becomes `toNodeID`
- `ref` inlines a template interactable payload

## Minimal Schema Rules for v1

The YAML layer should support only a controlled set of sugar.

Recommended v1 rules:

- keys remain close to runtime naming where possible
- consequences allow shorthand aliases, but only for existing runtime types
- `from_template` is allowed only for interactables
- node references are symbolic in YAML and UUID in generated JSON
- events compile into a single ordered `events.json`
- interactable templates are expanded by value, not by runtime indirection

That last point matters:

- runtime should still see plain full interactables
- no runtime support for template inheritance should be added yet

## Validation Strategy

Keep the existing validator as the semantic authority for generated JSON.

Add a compiler-specific validation phase before that:

- missing YAML files
- duplicate authored ids
- unknown template references
- unknown symbolic node references
- circular includes if includes/macros are added later

Error reporting should preserve source context:

- source file path
- line number if possible
- resolved scenario id

Longer term, the scenario validator can learn to report back to YAML source locations, but that is not required for the first pass.

## Implementation Shape

The compiler should be external to the app runtime.

Recommended implementation options:

- Python script using YAML parser
- Swift command-line tool with a YAML dependency

Recommendation for first pass:

- use Python for the compiler

Reasoning:

- fastest to iterate
- no impact on app binary/runtime
- better suited for content transformation scripts
- avoids adding a Swift package dependency into the app target too early

If Python is used, pin the dependency in a small local environment or document the exact requirement clearly.

## Rollout Plan

### Phase 1: Compiler Skeleton

- add `Authoring/Scenarios/`
- add compile script for one scenario
- support `scenario.yaml`, `archetypes.yaml`, `clocks.yaml`, `treasures.yaml`, `harm_families.yaml`
- generate byte-stable JSON

Success condition:

- `temple_of_terror` can round-trip from YAML to its current JSON shape

### Phase 2: Fixed Map and Events

- add `map.yaml`
- add symbolic node id resolution
- add `events/` folder merge
- add basic consequence shorthand

Success condition:

- `charons_bargain` can compile without losing current behavior

### Phase 3: Reusable Interactable Templates

- add `interactables/` folder
- support `ref` and `from_template`
- migrate repeated authored threats and utility interactables

Success condition:

- repeated droid-style payloads in `charons_bargain` disappear from event files

### Phase 4: Shadow Starts in YAML

- author `shadow_of_a_doubt` in YAML first
- keep generated JSON checked in
- use it as the proof that new scenarios no longer need to start in raw JSON

## Migration Recommendations by Scenario

### `temple_of_terror`

Use as the first migration target.

Why:

- smaller than `charons_bargain`
- exercises fixed-map authoring cleanly
- easier to verify against existing JSON output

### `charons_bargain`

Use as the stress test.

Why:

- event-heavy
- repeated interactable payloads
- exactly the scenario that will prove whether the YAML layer is materially better

### `shadow_of_a_doubt`

Use as the first scenario authored directly in YAML.

Why:

- it prevents the team from treating YAML as a migration-only tool
- it tests whether the workflow works for greenfield content, not just conversion

## Recommended First Ticket Breakdown

1. Add `Authoring/Scenarios/temple_of_terror/` with YAML equivalents of the current JSON files.
2. Build `Scripts/compile_scenarios.rb` and `Scripts/compile_scenarios.sh`.
3. Make compile output deterministic and reviewable.
4. Verify generated `temple_of_terror` JSON matches current runtime behavior.
5. Extend the compiler for `map.yaml` symbolic node ids.
6. Migrate `charons_bargain` events and interactable templates once the fixed-map path is solid.

## Definition of Done

The YAML layer is ready to use when:

- at least one existing scenario compiles from YAML into the current JSON contract
- the generated JSON validates with the existing validator
- `charons_bargain` event authoring is measurably less repetitive
- authors can work with symbolic node ids instead of hand-editing UUIDs
- new scenario work (`shadow_of_a_doubt`) can begin in YAML without needing direct JSON edits
