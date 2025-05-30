# Content JSON Schemas

This document describes key fields used in the JSON content files.

## ActionOption

`ActionOption` objects appear in `interactables.json` under each interactable's `availableActions` array.

```json
{
  "name": "Pull Lever",
  "actionType": "Tinker",
  "position": "controlled",
  "effect": "standard",
  "requiresTest": false,
  "outcomes": { "success": [ { "type": "removeInteractable", "id": "self" } ] }
}
```

* `requiresTest` — Optional `Bool`. Defaults to `true`. If `false`, the action executes its `success` consequences immediately without a dice roll.

## Treasure

Treasure entries live in `treasures.json`.

```json
{
  "id": "treasure_silver_key",
  "name": "Silver Key",
  "description": "Opens a locked door somewhere in the tomb.",
  "grantedModifier": { "bonusDice": 1, "description": "from Silver Key" },
  "tags": ["Key"]
}
```

* `tags` — Optional array of strings used by scenario logic. Leave empty if the treasure does not provide any special tags.

## Interactable

Interactables in `interactables.json` may also define `tags`.

```json
{
  "id": "template_locked_door",
  "title": "Locked Door",
  "description": "A heavy door with a silver keyhole.",
  "tags": ["Door"],
  "availableActions": [ /* ActionOption objects */ ]
}
```

* `tags` — Optional array of strings describing properties scenario logic can query.

## Consequence

`Consequence` objects live inside the `outcomes` dictionaries for an `ActionOption`.

```json
{
  "type": "gainStress",
  "amount": 1,
  "conditions": [
    { "type": "requiresMinPositionLevel", "positionParam": "desperate" }
  ]
}
```

* `type` — The effect to apply (e.g. `gainStress`, `sufferHarm`, `tickClock`, `gainTreasure`).
* Additional parameters such as `amount`, `level`, `familyId`, or `clockName` are included only when required by the chosen `type`.
* `conditions` — Optional array of `GameCondition` objects. If provided, the consequence is only eligible when **all** conditions evaluate to true.

Multiple consequences can be listed for a single outcome. A single entry forms a *shallow* pool while several entries form a *deeper* pool that the system can draw from based on roll quality.

## GameCondition

`GameCondition` objects gate consequences based on roll results or game state.

```json
{ "type": "requiresMinEffectLevel", "effectParam": "great" }
```

Available `type` values and their parameters:

* `requiresMinEffectLevel` – `effectParam` (`limited|standard|great`)
* `requiresExactEffectLevel` – `effectParam`
* `requiresMinPositionLevel` – `positionParam` (`controlled|risky|desperate`)
* `requiresExactPositionLevel` – `positionParam`
* `characterHasTreasureId` – `stringParam` (treasure id)
* `partyHasTreasureWithTag` – `stringParam` (treasure tag)
* `clockProgress` – `stringParam` (clock name), `intParam` (min progress), optional `intParamMax` (max progress)
