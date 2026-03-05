## Task 2: Implement Player Choice and Resistance

**Goal:** Complete the missing player-facing decision systems that authored scenarios need in order to branch cleanly and feel like FitD.

**Actions:**
- Replace the current `createChoice` placeholder behavior with a real player-facing choice flow:
  - define a pending choice model that can be presented by the UI
  - surface authored option text and consequences
  - apply only the option the player selects
  - support save/load safety if a choice is pending mid-run
- Add a resistance flow for harmful outcomes:
  - define which consequence types can be resisted in v1
  - calculate stress cost using explicit engine rules
  - let the player choose to accept or resist after seeing the rolled outcome
  - apply the reduced/negated consequence result through the same consequence pipeline
- Update dice-result presentation so outcome, consequence text, and follow-up decisions are sequenced clearly instead of being flattened into one passive result panel.
- Add tests covering:
  - authored branching choices
  - consequence interruption and resolution ordering
  - resistance stress application
  - resistance edge cases when stress overflow occurs

**Definition of Done:**
- Authored `createChoice` content no longer auto-selects the first option.
- The player can respond to at least the core harmful outcomes with resistance.
- Scenario authors can write branching scenes and trust the engine to present them faithfully.
