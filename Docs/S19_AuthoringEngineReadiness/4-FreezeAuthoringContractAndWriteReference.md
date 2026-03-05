## Task 4: Freeze the Authoring Contract and Write the Reference

**Goal:** Stabilize the v1 content surface so scenario work can accelerate without constant engine/schema churn.

**Actions:**
- Audit and explicitly declare the v1-stable authoring primitives:
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
- Decide and document what is intentionally deferred from the authoring contract:
  - meta-progression
  - procgen expansion
  - bespoke class ability systems beyond the v1 archetype contract
  - any unsupported or experimental consequence/condition types
- Update the author-facing documentation so it matches actual runtime behavior, not just design intent.
- Add a concise “new scenario checklist” describing the expected workflow:
  - create scenario folder
  - add required files
  - validate content
  - boot and playtest in-game

**Definition of Done:**
- The repo contains one authoritative reference for scenario authors.
- The engine team has a clear line between stable v1 content features and deferred work.
