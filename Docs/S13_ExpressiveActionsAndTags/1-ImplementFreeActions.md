## Task 1: Implement Free Actions (Non-Test Actions)

**Goal:** Allow Interactables to present actions that do **not require a dice roll**, but simply execute their Consequences—unlocking narrative, utility, or environmental interactions without unnecessary randomness.

### Actions:
- Add a `requiresTest: Bool = true` property to the `ActionOption` model (defaulting to `true` for backwards compatibility).
- Update InteractableCardView:
    - If `requiresTest` is `false`, skip DiceRollView and process the `.success` consequences directly when the button is tapped.
    - Optionally, visually distinguish free actions (e.g., special icon, color, or label like “Automatic”).
- Update content schema and loader to allow `requiresTest: false` in JSON.
- Add/test example interactables such as levers, switches, readable inscriptions, or safe item pickups.
- (Optional stretch) Allow for consequences with costs (e.g., “Spend 1 Stress” for an automatic action).