## Task 2: Add a Tag System for Treasures (and Interactables)

**Goal:** Make Treasures and Interactables richer by supporting a flexible, composable “tags” system—enabling scenario logic and emergent design patterns without hardcoding.

### Actions:
- Add a `tags: [String] = []` property to the `Treasure` struct.
    - Update `treasures.json` format to allow a `"tags": [...]` array.
- Add an optional `tags: [String] = []` property to the `Interactable` struct.
    - Update `interactables.json` accordingly.
- Expose tags in the UI (as icon chips or small labels) for treasures (and optionally interactables).
- Update the scenario design language:
    - Document how to check for tags on treasures when evaluating interactable options or consequences.
    - Support action gating or bonuses in interactables based on tag presence (e.g., “If any party member has a Treasure tagged Light Source, reveal secret passage”).
- (Optional stretch) Allow tags to gate additional ActionOptions or Consequence branches in future scenario logic.
- Add a few test treasures (e.g., “Cursed Lantern” with tags `[“Haunted”, “Light Source”]`) and at least one interactable or scenario effect that checks tags.