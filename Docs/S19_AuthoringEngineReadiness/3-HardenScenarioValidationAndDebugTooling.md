## Task 3: Harden Scenario Validation and Debug Tooling

**Goal:** Let scenario authors catch content problems and inspect runtime state without editing Swift code.

**Actions:**
- Expand `ScenarioValidator` to add higher-value authoring checks:
  - fixed-map reachability from the entry node
  - references to unsupported `actionType` values
  - warnings for authored events, treasures, or clocks that appear unreachable or unused
  - warnings for likely dead-end or soft-lock scenarios in fixed maps
- Keep validation output actionable:
  - include file and path information whenever possible
  - distinguish authoring errors from softer design warnings
- Add a lightweight debug mode for local playtesting:
  - deterministic dice or fixed dice input
  - node jump / scenario-state inspection
  - quick flag/counter editing
  - quick treasure/modifier grants for scenario verification
- Document how to run validator and debug tooling from the repo.

**Definition of Done:**
- Authors can validate a scenario folder and get meaningful structural feedback before opening the app.
- Designers can inspect state and test branches without adding one-off debug code to the engine.
