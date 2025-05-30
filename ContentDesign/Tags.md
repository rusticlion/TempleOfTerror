# Treasure and Interactable Tags

Treasures and interactables can include a `tags` array in their JSON definition.
Tags are simple strings used by scenario logic to unlock or modify actions.

Example treasure entry:
```json
{
  "id": "treasure_cursed_lantern",
  "name": "Cursed Lantern",
  "description": "An old lantern that glows with an eerie light.",
  "grantedModifier": { "bonusDice": 1, "description": "from Cursed Lantern" },
  "tags": ["Haunted", "Light Source"]
}
```

## Gating Actions
`ActionOption` now supports a `requiredTag` field. When set, the action
button is enabled only if any party member possesses a treasure with that tag.

Example snippet:
```json
{
  "name": "Illuminate",
  "actionType": "Survey",
  "position": "controlled",
  "effect": "standard",
  "requiresTest": false,
  "requiredTag": "Light Source",
  "outcomes": { "success": [ { "type": "removeInteractable", "id": "self" } ] }
}
```
Use tags to gate hidden options or trigger special consequences.

## Checking Tags in Scenario Code
Use the view model's helper to query the party's treasures:
```swift
if viewModel.partyHasTreasureTag("Key") {
    // unlock a branch or reveal a secret
}
```
This allows scenarios to react dynamically to items the players have found.
