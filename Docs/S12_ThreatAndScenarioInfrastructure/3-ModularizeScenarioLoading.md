## Task 3: Modularize Scenario Loading

**Goal:** Support multiple scenarios as discrete content bundles, with plug-and-play architecture for scenario selection and loading.

**Actions:**
- Refactor ContentLoader:
    - Accept a scenario id/name and load content (`interactables.json`, `harm_families.json`, etc.) from a scenario-specific directory.
    - Add a `scenario.json` manifest with metadata: title, description, entry node, etc.
- Support fallback/default content for missing fields (for backwards compatibility).
- Playtest with two scenario folders ("tomb", "test_lab").