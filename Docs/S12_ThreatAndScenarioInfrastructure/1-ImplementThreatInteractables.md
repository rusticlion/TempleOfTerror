## Task 1: Implement Threat Interactables (Enemy/Hazard Encounters)

**Goal:** Allow rooms to contain "Threats" that must be resolved before any other actions or movement can be taken. Expresses enemies, environmental hazards, or narrative crises without requiring a combat subsystem.

**Actions:**
- Add a `subtype: "threat"` (or `isThreat: true`) property to Interactable model and content schema.
- Update node rendering logic: If a Threat is present in the current node, disable/hide all other interactables and navigation.
- In UI, visually differentiate Threats from normal interactables (e.g., red border, warning icon).
- Update InteractableCardView to render threat status.
- Playtest with sample Threats (e.g., monster, reactor breach).