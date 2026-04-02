## Task 1: Expand the Authoring Toolbox for Beta

**Goal:** Add three tightly scoped engine features that meaningfully widen the kinds of scenarios authors can build before the first major content push:

- `Devil's Bargains`
- ambient `node modifiers`
- reversible clocks via `adjustClock`

This pass is intentionally about leverage, not novelty.

The engine already has a strong authoring core:

- actions with Position and Effect
- consequences and events
- flags and counters
- treasures and modifiers
- split-party-aware conditions
- room hooks
- clocks

What is still missing are a few small primitives that let authors express:

- tempting short-term risk for long-term trouble
- hostile or advantageous room state that lives in the environment
- tug-of-war progress tracks instead of one-way countdowns

Those three additions unlock a lot of design space without asking authors to learn a second authored language.

## Product Intent

The beta toolbox should support scenarios built around:

- pressure
- temptation
- unstable rooms
- contested progress
- environmental antagonism

It should not require:

- custom scripting
- heavyweight interrupt systems
- scenario-specific subsystem code
- a large expansion of the roll UI model

The guiding rule for this pass is:

- prefer extending existing primitives over adding bespoke mechanics

## Scope

In scope:

- one optional `Devil's Bargain` per action
- bargain presentation in the existing optional boost lane
- room-scoped ambient modifiers stored on nodes
- node-level modifier grant and removal consequences
- a signed clock adjustment consequence
- clarified clock callback semantics
- validator and authoring reference follow-up after implementation

Out of scope:

- multiple bargain choices per action
- a generic reaction / interrupt system
- flashbacks or authored loadout pools
- new condition syntax
- clock-specific reverse callbacks
- a separate environment-status subsystem distinct from `Modifier`

## Why These Three

### Devil's Bargains

This adds a clean authored way to offer:

- immediate momentum
- guaranteed future trouble
- meaningful player temptation

It strengthens the core expedition fantasy of choosing risk, not just suffering it.

### Node Modifiers

The runtime can already simulate room state awkwardly with:

- `onEnter`
- `grantModifier`
- `removeModifier`

Making room state first-class removes authoring friction and makes the environment an active participant in play.

### Reversible Clocks

Current clocks are mostly one-way pressure meters.

Adding regression unlocks:

- negotiations
- pursuits
- containment
- ritual stabilization
- suspicion tracks
- flooding, fire, collapse, and similar contested dangers

This is especially valuable because clocks are already one of the engine's best general-purpose authoring tools.

## Recommendation Summary

Ship exactly this beta contract:

1. `ActionOption.devilsBargain`
2. `MapNode.activeModifiers`
3. `grantNodeModifier`
4. `removeNodeModifier`
5. `adjustClock`

Do not add:

- multiple authored bargain options
- full protect / assist reactions
- scenario loadout declaration

Those can be revisited later if content proves a strong need.

## Feature 1: Devil's Bargains

### Core Decision

Support `0 or 1` authored bargain on an action.

Do not support a list of bargains in beta.

Why:

- keeps authoring light
- keeps the roll screen readable
- preserves the feeling that a bargain is a dramatic invitation, not a routine checklist item

### Proposed Model Shape

Add a new authored payload:

```swift
struct DevilBargain: Codable {
    var title: String
    var description: String
    var consequences: [Consequence]
}
```

Extend `ActionOption`:

```swift
struct ActionOption: Codable {
    ...
    var devilsBargain: DevilBargain? = nil
}
```

### Authoring Rules

`devilsBargain` is only valid on:

- actions with `requiresTest == true`

Required fields:

- `title`
- `description`
- `consequences`

Validation rules:

- `consequences` must be non-empty
- `title` and `description` must be non-blank
- authors should not attach a bargain to no-roll actions

### Runtime Semantics

Selecting a bargain:

- adds `+1d` to the roll
- uses the same optional boost selection flow as Push and optional modifiers
- may stack with `Push Yourself`
- may stack with other optional modifiers that already apply

Bargain fallout:

- always happens if the bargain was selected
- resolves regardless of roll result
- is appended after the normal roll outcome consequences for that action
- stays queued behind any pending choice or resistance created by the normal roll outcome

Beta rule:

- bargain consequences are not resistible

Rationale:

- the bargain needs to feel like a real price
- if authors want mitigable fallout, ordinary consequences and resistance already cover that space

### UI Guidance

The bargain should appear in the existing `Optional Boosts` section as a specialized boost card.

Recommended presentation:

- title: authored `title`
- detail: `+1d`
- status: short authored `description`

This should look like a sibling of `Push Yourself`, not a separate step or modal.

### Authoring Guidance

Use bargains for trouble that is:

- clear
- guaranteed
- future-facing
- dramatically legible

Good bargain consequences include:

- `adjustClock`
- `setScenarioFlag`
- `lockConnection`
- `grantNodeModifier`
- `addInteractableHere`
- `triggerEvent`

Avoid bargains that require unusual timing or hidden state setup before the roll resolves.

If the authored downside must happen before the action outcome, it is probably normal fallout rather than a bargain.

### Example

```json
{
  "name": "Force The Vault Door",
  "actionType": "Wreck",
  "position": "risky",
  "effect": "standard",
  "devilsBargain": {
    "title": "Wake The Guardians",
    "description": "Take +1d, but the noise advances the guardian alert clock.",
    "consequences": [
      {
        "type": "adjustClock",
        "clockName": "guardian_alert",
        "amount": 2,
        "description": "The stone sentries stir elsewhere in the complex."
      }
    ]
  },
  "outcomes": {
    "success": [
      { "type": "unlockConnection", "fromNodeID": "...", "toNodeID": "..." }
    ]
  }
}
```

## Feature 2: Ambient Node Modifiers

### Core Decision

Node modifiers should reuse the existing `Modifier` mechanical shape, but they should live on a room rather than on a character.

This is not a new status system.

It is the same modifier language applied to environmental state.

### Proposed Model Shape

Extend `MapNode`:

```swift
struct MapNode: Identifiable, Codable {
    ...
    var activeModifiers: [Modifier] = []
}
```

Add new consequence kinds:

```swift
enum ConsequenceKind: String, Codable {
    ...
    case grantNodeModifier
    case removeNodeModifier
}
```

Reuse:

- `modifier`
- `sourceKey`
- optional `inNodeID`

Meaning:

- `grantNodeModifier` requires `modifier`
- `removeNodeModifier` requires `sourceKey`
- `inNodeID` is optional and defaults to the acting character's current node

### Beta Constraint

In beta, node modifiers are ambient room conditions, not consumable tactical boosts.

That means authored node modifiers should be constrained to:

- `uses: -1`
- `isOptionalToApply: false`
- `sourceKey` required

Validator should reject authored node modifiers that violate those constraints.

Why this constraint matters:

- it keeps the mental model simple
- it avoids confusing shared-use consumption semantics
- it makes room state readable and reliable

If later we want consumable environment affordances, that should be a separate design pass.

### Runtime Semantics

Node modifiers apply when:

- a character makes a roll while currently located in that node

They do not:

- travel with the character
- appear on the character sheet as owned gear or personal status

They should contribute to roll projection exactly like automatic character modifiers do:

- bonus dice
- position improvement
- effect improvement
- action filtering
- interactable tag filtering

If a node has multiple active modifiers, they stack using the same projection rules as character modifiers.

Grant/removal semantics:

1. resolve the target node
2. for `grantNodeModifier`, replace any existing node modifier in that node with the same `sourceKey`
3. for `removeNodeModifier`, remove matching modifiers by `sourceKey`
4. persist the node state in the save file as part of the map

### UI Guidance

Players should be able to see active room state in at least two places:

1. the node scene itself
2. the roll forecast notes

Recommended language:

- "Room Conditions"
- "Environmental Pressure"

Do not bury node modifiers inside character-owned modifier UI.

The whole point is to make the environment legible as a source of pressure or opportunity.

### Authoring Guidance

Good uses:

- flooded footing imposing `-1d` on `Prowl` or `Finesse`
- sanctified ground improving `Attune` position
- smoke reducing effect on ranged or precise actions
- stabilized rigging improving `Traversal`-tagged actions

### Example Node Authoring

```json
{
  "name": "Flooded Gallery",
  "soundProfile": "water",
  "activeModifiers": [
    {
      "sourceKey": "flooded_floor",
      "bonusDice": -1,
      "applicableActions": ["Prowl", "Finesse"],
      "uses": -1,
      "isOptionalToApply": false,
      "description": "Flooded footing"
    }
  ],
  "interactables": [
    {
      "id": "pump_console",
      "title": "Drainage Console",
      "description": "An old pump system still hums under the waterline.",
      "availableActions": [
        {
          "name": "Drain The Gallery",
          "actionType": "Tinker",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [
              {
                "type": "removeNodeModifier",
                "sourceKey": "flooded_floor",
                "description": "The waterline drops and footing improves."
              }
            ]
          }
        }
      ]
    }
  ]
}
```

### Remote Node Support

`inNodeID` should allow authors to affect rooms other than the acting character's current location.

This is useful for:

- opening a vent that clears another room
- reactivating warded ground elsewhere
- flooding a downstream chamber

That said, most authored node modifier use should stay local to keep cause and effect legible.

## Feature 3: Reversible Clocks

### Core Decision

Add `adjustClock`.

Do not overload `tickClock` with negative numbers.

Why:

- keeps authored intent obvious
- preserves readability in scenario files
- avoids muddling "advance pressure" with "change progress in either direction"

### Proposed Model Shape

Add a new consequence kind:

```swift
enum ConsequenceKind: String, Codable {
    ...
    case adjustClock
}
```

Payload:

- `clockName`
- `amount`

`amount` may be positive or negative.

### Runtime Semantics

`adjustClock` should:

- clamp resulting progress into `0...segments`
- instantiate a missing clock from template if `amount > 0`
- do nothing if the clock is missing and `amount <= 0`

Positive adjustments:

- increase progress
- may fire `onTickConsequences`
- may fire `onCompleteConsequences`

Negative adjustments:

- reduce progress
- do not fire `onTickConsequences`
- do not fire `onCompleteConsequences`

### Callback Clarification

This pass should also tighten clock callback behavior in general:

- `onTickConsequences` fire only when progress actually increases
- `onCompleteConsequences` fire only when a clock crosses from below full to full

That means:

- extra positive ticks on an already full clock should not retrigger completion
- negative adjustments should not create reverse callbacks in beta
- a clock that falls below full and later becomes full again may trigger completion again on that later crossing

This last behavior is acceptable in beta.

If authors need a one-time completion payoff, they should guard it with scenario state such as a flag.

### Resistance

Existing resistance behavior for `tickClock` should not automatically expand here unless implementation cost is clearly small and the UX stays legible.

Recommended beta rule:

- `adjustClock` is a normal consequence type
- if it needs to be resistible, authors can use explicit `resistance`

This keeps the default resistance model stable while still allowing authored exceptions.

### Authoring Guidance

Good uses:

- reducing suspicion
- pushing back a ritual collapse
- buying time against a flood
- improving containment
- calming a negotiation or pursuit clock

### Example

```json
{
  "type": "adjustClock",
  "clockName": "ritual_instability",
  "amount": -2,
  "description": "The glyphs settle and the chamber stops shaking for the moment."
}
```

## Cross-Feature Interaction Guidance

These features should compose cleanly.

Examples:

- a bargain can `adjustClock`
- a bargain can `grantNodeModifier`
- a room action can remove a node modifier and reduce a clock
- a node modifier can make the roll to reduce a clock harder

That is exactly the kind of authored loop this pass is meant to unlock:

- take a risk
- worsen the situation
- reshape the room
- buy time back elsewhere

## Validator Follow-Up

After implementation, validator coverage should include:

- `devilsBargain` only on roll actions
- bargain payload has non-empty title, description, and consequences
- authored bargain consequences do not declare `resistance`
- `grantNodeModifier` requires a valid modifier payload
- `removeNodeModifier` requires `sourceKey`
- authored node modifiers require `sourceKey`
- authored node modifiers must use `uses: -1`
- authored node modifiers must use `isOptionalToApply: false`
- `adjustClock` requires `clockName`
- `adjustClock` requires non-zero `amount`

## Authoring Reference Follow-Up

After implementation:

- update `Docs/ScenarioAuthoringReference.md`
- add examples to the walkthrough or canonical scenarios
- ensure the YAML schema surfaces these new fields

Do not update the authoritative reference before runtime support exists.

## Definition of Done

This pass is done when:

- authors can optionally attach one bargain to an action
- node state can carry ambient modifiers directly
- authored content can add and clear node modifiers
- clocks can move backward as well as forward
- roll projection and save/load remain legible and deterministic
- the resulting contract is documented with examples

## Recommendation On Sequencing

Implementation order should be:

1. `adjustClock`
2. node modifier model and projection support
3. node modifier consequences
4. `Devil's Bargain` UI and execution
5. validator and documentation updates

Why this order:

- clocks are the smallest and safest change
- node modifiers affect projection and persistence, so they should settle before bargain UX
- bargains become much more interesting once clocks and room state can carry their fallout
