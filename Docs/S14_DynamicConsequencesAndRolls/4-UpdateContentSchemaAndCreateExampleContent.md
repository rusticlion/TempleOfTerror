### Task 4: Update Content Schema & Create Example Interactables

**Goal:** Document the new JSON capabilities for `interactables.json`, `treasures.json`, and create test content demonstrating the new conditional consequence system and roll dynamics.

**Actions:**

1.  **Update JSON Schema Documentation:**
    * For `interactables.json`: Detail the new `Consequence` struct format, including the `conditions` array and `GameCondition` objects, and parameters for each `ConditionType`. Specify how shallow vs. deep pools would be structured if there's a formal distinction (e.g., a flag, or just by the number of consequences listed).
    * For `treasures.json`: Add `tags: [String]?` to the `Treasure` schema if implementing `partyHasTreasureWithTag`.
2.  **Create Example Content in `Content/` & `Content/Scenarios/`:**
    * **Simple Interactable:** In `interactables.json` (or a scenario-specific version), define an interactable with:
        * An action leading to shallow consequence pools.
        * A negative consequence gated by `requiresMinPositionLevel: "desperate"`.
        * A positive consequence gated by `requiresMinEffectLevel: "great"`.
    * **Set-Piece Interactable (Template):**
        * Define an action with deeper pools of potential positive and negative consequences.
        * Include consequences gated by `characterHasTreasureId` (referencing a test treasure).
        * Include consequences gated by `clockProgress` (referencing a test clock).
    * **Test Treasure:** Add a treasure in `treasures.json` with a specific ID and optionally a tag, to be used by the gating conditions.
3.  **Initialize Test Clocks:** In `DungeonGenerator.swift` or `GameViewModel.startNewRun()`, ensure a test clock mentioned in a gated consequence can be initialized.