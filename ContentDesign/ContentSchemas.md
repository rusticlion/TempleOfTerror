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
