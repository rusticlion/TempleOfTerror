### Task 5: UI Polish for Projections and Results

**Goal:** Ensure the `DiceRollView` clearly communicates the new dynamics introduced by zero-rating rolls, criticals, and the final impact of Position/Effect on outcomes.

**Actions:**

1.  **Verify `CardGame/DiceRollView.swift` - `projection.notes`:**
    * Ensure notes for 0-rating rolls are clearly displayed.
    * Consider if other active gates (e.g., "carrying X, special outcome possible!") should be hinted at in projection notes if determinable beforehand (this can be complex).
2.  **Display Critical & Final Effect:**
    * When `result.isCritical` is true, display a "CRITICAL SUCCESS!" message.
    * Display the `result.finalEffect` achieved on the roll.
3.  **Accurate Consequence Display:**
    * The existing logic of displaying `result.consequences` (the string description) should naturally reflect the actually applied consequences. Double-check this description is accurately built by `processConsequences` from the final list.