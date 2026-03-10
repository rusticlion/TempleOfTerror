# Scenario Authoring Reference (v1)

This is the authoritative reference for scenario authors.

It describes the current runtime contract for authored content in the anthology-focused Forged in the Dark engine.

For the step-by-step creation flow, see `Docs/ScenarioAuthoringWalkthrough.md`.

## Scope and Stability

The following content surfaces are considered v1-stable for authoring:

- scenario manifests
- archetypes and party-building inputs
- fixed maps and node connections
- interactables and actions
- tags
- treasures and modifiers
- clocks
- consequences
- events
- scenario flags and counters
- endings

If behavior in older docs conflicts with this file, this file wins.

## Scenario Folder Contract

Each scenario lives in `Content/Scenarios/<scenario_id>/`.

Experimental YAML authoring sources can also live in `Authoring/Scenarios/<scenario_id>/`.

Current workflow:

1. Edit YAML source files in `Authoring/Scenarios/<scenario_id>/`
2. Run `./Scripts/compile_scenarios.sh <scenario_id>` (or no arg to compile all authored scenarios)
3. Review the generated runtime JSON in `Content/Scenarios/<scenario_id>/`
4. Run `./Scripts/validate_scenarios.sh`

Preferred one-command authoring check:

```bash
./Scripts/check_authored_scenarios.sh <scenario_id>
```

This compiles authored YAML, validates the generated runtime scenario, and refreshes the authored map preview in `Authoring/Previews/` in one pass.

Schema-backed editing:

- YAML source files can point at local schemas under `Authoring/Schemas/` using a `yaml-language-server` modeline comment.
- The starter templates and current authored scenario files already include those modelines.
- Editors that support the common YAML language server convention can use them for enum completion, required-field checks, and inline docs.

Current YAML compiler support:

- direct YAML equivalents of `scenario.json`, `archetypes.json`, `clocks.json`, `treasures.json`, `harm_families.json`, and `interactables.json`
- `map.yaml` with symbolic node ids and symbolic node references
- optional `events.yaml` or `events/*.yaml`, compiled into `events.json`
- optional `interactables/*.yaml` split files, compiled into `interactables.json`

`map.yaml` is the only place where authoring sugar exists in v1:

- top-level `startingNode` may use a symbolic node id
- node keys are symbolic ids
- `connections[].to`, `fromNode`, `toNode`, and `inNode` compile back into UUID-based runtime fields
- authors may pin migrated maps to existing UUIDs with a node-local `uuid` field

Split interactable file notes:

- place reusable or focused authored entries under `Authoring/Scenarios/<scenario_id>/interactables/*.yaml`
- each split interactable file should declare `authoringGroup` so it merges back into the grouped `interactables.json` output
- scenario-local `interactables.yaml` can still exist alongside split files; the compiler merges both

Required files:

- `scenario.json`
- `archetypes.json`

Required global file (shared across all scenarios):

- `Content/harm_families.json`

Optional scenario-local files:

- `harm_families.json` (overrides/extends global harm families by id)
- `clocks.json`
- `treasures.json`
- `events.json`

Map/procgen split:

- Fixed-map scenario:
  - set `mapFile` in `scenario.json`
  - provide that map file in the scenario folder
  - `entryNode` is consumed (UUID string or unique node name)
- Procgen scenario:
  - omit `mapFile`
  - provide `interactables.json` templates
  - `entryNode` is ignored

## `scenario.json`

```json
{
  "id": "charons_bargain",
  "title": "Charon's Bargain",
  "description": "You board a distressed freighter.",
  "entryNode": "Docking Bay",
  "mapFile": "map_charons_bargain.json",
  "partySize": 3,
  "nativeArchetypeIDs": ["scientist", "mercenary", "pilot"],
  "stressOverflowHarmFamilyID": "vfe_cerebral_euphoria"
}
```

Field notes:

- `id`, `title`, `description` are required.
- `partySize` must be greater than zero when provided.
- `nativeArchetypeIDs` must reference ids from scenario-local `archetypes.json`.
- `stressOverflowHarmFamilyID` should be set explicitly.
  - If omitted, runtime defaults to `mental_fraying`.

## Archetypes and Character Tags

`archetypes.json` supports these authored fields:

- `id`, `name`, `description`, `defaultActions`
- optional `personalityTagPool`

`personalityTagPool` is a lightweight flavor pool for generated characters.

- Runtime draws up to two distinct tags from the pool when creating a character from that archetype.
- These become persistent character `traitTags` for the run.
- Scenario content can also add and remove temporary `stateTags` during play.

Authoring guidance:

- Keep generated tags short and evocative: `Curious`, `Superstitious`, `Hotheaded`, `Methodical`
- Prefer personality or outlook over direct stat modifiers
- Most tags should be flavor-forward and only occasionally referenced by authored conditions
- Avoid overly broad generic tags like `Smart`, `Strong`, `Good`

## Interactables and Threat Pressure

`Interactable` supports these authored fields:

- `id`, `title`, `description`, `availableActions`
- optional `isThreat`
- optional `usableUnderThreat`
- optional `isDisplayOnly`
- optional `tags`

Threat behavior in v1:

- A node containing one or more unresolved threat interactables engages characters in that node.
- Engaged characters cannot leave the node through normal movement until all local threats are resolved.
- Threats do not remove sibling interactables from the node.
- While a threat is present, only:
  - threat interactables, and
  - sibling interactables with `usableUnderThreat: true`
  remain actionable in the node UI.

Use `usableUnderThreat` for room elements that are intended to function as immediate counterplay under pressure:

- environmental shutdowns
- override consoles
- barricades, doors, vents, cranes, wards
- urgent objective grabs that are still reachable while the threat is active

Example:

```json
{
  "id": "engineering_override_console",
  "title": "Engineering Override Console",
  "description": "A scorched control station still responds to manual reroutes.",
  "usableUnderThreat": true,
  "availableActions": [
    {
      "name": "Trigger Emergency Shutdown",
      "actionType": "Tinker",
      "position": "risky",
      "effect": "standard",
      "requiresTest": false,
      "outcomes": {
        "success": [
          { "type": "removeInteractable", "id": "cb_corrupted_maintenance_droid" }
        ]
      }
    }
  ]
}
```

Authoring guidance:

- In a threat node, prefer one or two `usableUnderThreat` siblings rather than many.
- Treat them as pressure options, not general room clutter.
- Split-party play becomes interesting when one character is pinned by a local threat while offsite characters pursue tools, intel, or clocks elsewhere.

## Actions

Supported `actionType` values are fixed for v1:

- `Study`, `Survey`, `Hunt`, `Tinker`
- `Prowl`, `Finesse`, `Wreck`, `Skirmish`
- `Attune`, `Command`, `Consort`, `Sway`

Validator treats any other `actionType` as an error.

Roll outcomes use keys:

- `success`
- `partial`
- `failure`

## Conditions

Supported `GameCondition.type` values:

- `requiresMinEffectLevel` (`effectParam`)
- `requiresExactEffectLevel` (`effectParam`)
- `requiresMinPositionLevel` (`positionParam`)
- `requiresExactPositionLevel` (`positionParam`)
- `characterHasTreasureId` (`stringParam` treasure id)
- `characterHasTag` (`stringParam` tag)
- `characterLacksTag` (`stringParam` tag)
- `partyHasTreasureWithTag` (`stringParam` tag)
- `partyHasMemberWithTag` (`stringParam` tag)
- `clockProgress` (`stringParam` clock name, `intParam` minimum progress, optional `intParamMax`)
- `scenarioFlagSet` (`stringParam` flag id)
- `scenarioCounter` (`stringParam` counter id, optional `intParam` min and `intParamMax` max)

## Consequences

Supported `Consequence.type` values and required params:

- `gainStress`: `amount`
- `sufferHarm`: `level`, `familyId`
- `tickClock`: `clockName`, `amount`
- `unlockConnection`: `fromNodeID`, `toNodeID` (fixed-map usage)
- `removeInteractable`: `id` (or `id: "self"` for remove-self behavior)
- `removeAction`: `id`, `actionName`
- `addAction`: `id`, `action` payload
- `addInteractable`: `inNodeID`, `interactable` payload (`"current"` maps to add-here behavior)
- `gainTreasure`: `treasureId`
- `modifyDice`: `amount` (and optional `duration`)
- `createChoice`: `options` (one or more)
- `triggerEvent`: `eventId`
- `triggerConsequences`: `consequences` (nested)
- `healHarm`: no params
- `setScenarioFlag`: `flagId`
- `clearScenarioFlag`: `flagId`
- `incrementScenarioCounter`: `counterId`, optional `amount` (defaults to 1)
- `setScenarioCounter`: `counterId`, `amount` (target value)
- `addCharacterTag`: `tag` (applies to the acting character)
- `removeCharacterTag`: `tag` (applies to the acting character)
- `endRun`: optional `runOutcome`, optional `runOutcomeText`

Each consequence may also include:

- `conditions`: optional array of `GameCondition`
- `description`: optional narrative line
- `resistance`: optional explicit resistance rule

### Resistance Rules

Clock ticks are resistible in v1.

If `resistance` is omitted, runtime defaults are:

- `sufferHarm` -> `prowess`, mitigates by 1 harm level
- `gainStress` -> `resolve`, mitigates by 2 stress
- `tickClock` -> `insight`, mitigates by 2 clock ticks

Explicit `resistance.amount` must be `>= 0`.

## Events, Flags, and Counters

- `events.json` defines conditional consequence bundles.
- `triggerEvent` executes an event only when its conditions pass.
- `scenarioFlags` and `scenarioCounters` are global scenario state primitives and are the intended v1 way to gate authored branches.

## Endings

Use `endRun` to terminate the run.

`runOutcome` values:

- `victory`
- `escaped`
- `defeat`

`runOutcomeText` is optional narrative shown on the game-over screen.

## Validator Workflow

Run across all scenarios:

```bash
./Scripts/validate_scenarios.sh
```

Run for one scenario directory:

```bash
./Scripts/validate_scenarios.sh Content/Scenarios/<scenario_id>
```

Compile and validate authored scenarios in one step:

```bash
./Scripts/check_authored_scenarios.sh
./Scripts/check_authored_scenarios.sh <scenario_id>
```

This also refreshes `Authoring/Previews/<scenario_id>_map_preview.md` for authored fixed-map scenarios.

Validator highlights:

- schema/required-field errors
- unknown action types
- missing references (events, treasures, clocks)
- fixed-map reachability from entry
- likely soft-lock nodes (no unlocked exits and no obvious progression path)
- flag/counter reads without writes

Errors block content; warnings are design-quality signals.

## Guided Authoring Tools

Create a new scenario skeleton:

```bash
./Scripts/scaffold_authoring.rb scenario shadow_of_a_doubt "Shadow of a Doubt"
```

Add a split event file:

```bash
./Scripts/scaffold_authoring.rb event temple_of_terror tot_idol_stirs
```

Add a split interactable file:

```bash
./Scripts/scaffold_authoring.rb interactable temple_of_terror tot_collapsing_bridge --group hazards --action-type Finesse
```

Append a node stub to `map.yaml`:

```bash
./Scripts/scaffold_authoring.rb node temple_of_terror idol_vault "Idol Vault"
```

Generate or refresh the authored map/content preview:

```bash
./Scripts/preview_authored_map.rb temple_of_terror
```

The generated preview includes:

- scenario manifest summary
- content-surface counts (archetypes, shared interactables, clocks, treasures, harm families, events)
- fixed-map reachability summary
- a Mermaid diagram of authored connections
- per-node interactable and connection counts

The scaffold script is backed by starter files in `Authoring/Templates/`.

## Author Tooling (Local Playtest)

In debug builds, open a run and tap the toolbar wrench icon to open **Author Tools**.

Current tools:

- fixed dice pattern override (for deterministic branch testing)
- node jump (party or selected character)
- scenario state inspection (locations and clock progress)
- quick flag/counter editing
- quick treasure grants and modifier grants

These tools are for local branch verification and should not be used as runtime dependencies in authored content.

## Deferred / Not in v1 Contract

Explicitly deferred from authoring contract:

- meta-progression systems
- procgen expansion beyond current scenario-template flow
- bespoke class ability systems beyond archetype defaults and modifiers
- custom/experimental condition or consequence types not listed above
- custom action families beyond the 12 supported FitD actions

## New Scenario Checklist

1. Create `Content/Scenarios/<scenario_id>/`.
2. Add `scenario.json` and `archetypes.json`.
3. Add either:
   - fixed map file + `mapFile`, or
   - `interactables.json` for procgen.
4. Add optional `events.json`, `clocks.json`, `treasures.json`, scenario-local `harm_families.json`.
5. Prefer `./Scripts/check_authored_scenarios.sh <scenario_id>` while authoring.
6. Generate `./Scripts/preview_authored_map.rb <scenario_id>` when iterating on map structure, or rely on `check_authored_scenarios.sh` to refresh it automatically.
7. Launch the app and branch-test with Author Tools.
8. Resolve validator errors, then review warnings before content sign-off.
