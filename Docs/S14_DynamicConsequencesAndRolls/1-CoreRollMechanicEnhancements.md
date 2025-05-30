### Task 1: Core Roll Mechanic Enhancements (Zero Rating & Criticals)

**Goal:** Implement foundational changes to dice roll processing for zero action ratings and critical successes, making rolls more varied and their extreme outcomes more meaningful.

**Actions:**

1.  **Modify `GameViewModel.swift` - `performAction()`:**
    * **Zero Action Rating:** If a character's rating for the `action.actionType` is 0, roll 2d6 and set `effectiveHighestRoll` to the *minimum* of the two dice. Store both dice rolled.
    * **Critical Success:** After rolling all dice for any action (including the two for a zero-rating roll), count the number of 6s. If `sixes > 1` (or your chosen threshold), set an `isCritical` flag to true.
        * **Benefit:** For now, a critical success will increase the `finalEffect` by one step (e.g., Standard to Great). This can be logged in the `consequencesDescription`.
    * Store all `actualDiceRolled` from any roll.

    ```swift
    // In GameViewModel.swift - performAction()

    // ... Determine base characterActionRating, bonusDice ...
    var actualDiceRolled: [Int] = []
    var effectiveHighestRoll: Int
    var isCritical = false
    // let projection = calculateProjection(for: action, with: character) // Call this to get final dice, position, effect
    // let initialDiceCount = projection.finalDiceCount // Or however you determine actual dice to roll
    // let finalPosition = projection.finalPosition
    // var finalEffect = projection.finalEffect


    if character.actions[action.actionType] ?? 0 == 0 { // Check original rating for zero-roll mechanic
        let d1 = Int.random(in: 1...6)
        let d2 = Int.random(in: 1...6)
        actualDiceRolled = [d1, d2]
        effectiveHighestRoll = min(d1, d2)
        // Check for critical on 0-rating roll (e.g. double 6s still a crit, but outcome based on lowest)
        // This might be rare/impossible for 0-rating to be a "success" crit.
        // For now, focus criticals on positive outcomes from normal rolls.
    } else {
        let dicePool = max(projection.finalDiceCount, 1) // Use finalDiceCount from projection
        for _ in 0..<dicePool {
            actualDiceRolled.append(Int.random(in: 1...6))
        }
        effectiveHighestRoll = actualDiceRolled.max() ?? 0
        let sixes = actualDiceRolled.filter { $0 == 6 }.count
        if sixes > 1 { // Or your preferred critical condition
            isCritical = true
        }
    }

    if isCritical {
        // Example: Improve effect on critical, if the outcome is already positive
        if effectiveHighestRoll >= 4 { // Only boost effect on partial or full success crits
             finalEffect = finalEffect.increased()
             // Add note to consequences string later
        }
    }

    // ... determine outcomeString, consequencesToApply based on effectiveHighestRoll ...
    // ... consequencesDescription = processConsequences(...)

    // Ensure DiceRollResult includes these new fields
    return DiceRollResult(
        highestRoll: effectiveHighestRoll,
        outcome: outcomeString,
        consequences: consequencesDescription,
        actualDiceRolled: actualDiceRolled, // New
        isCritical: isCritical,             // New
        finalEffect: finalEffect            // New or ensure it's passed if modified
    )
    ```

2.  **Update `Models.swift` - `DiceRollResult` (defined in `CardGame/DiceRollView.swift` currently):**
    * Add `let actualDiceRolled: [Int]?`
    * Add `let isCritical: Bool?`
    * Add `let finalEffect: RollEffect?` (if not already there or to ensure it carries modifications).

3.  **Update `GameViewModel.swift` - `calculateProjection()`:**
    * If character's action rating is 0, add a specific note to `RollProjectionDetails.notes` (e.g., "`\(character.name)` has 0 rating in `\(action.actionType)`: Rolling 2d6, taking lowest.").
    * `RollProjectionDetails.finalDiceCount` could be set to `2` for display purposes in `DiceRollView` for 0-rating rolls.

4.  **Update `CardGame/DiceRollView.swift`:**
    * Modify `onAppear` to set initial `diceValues` count to 2 if `projection.notes` indicates a 0-rating roll (or if `projection.finalDiceCount` signals it).
    * In `stopShaking()`, use `result.actualDiceRolled` to populate `self.diceValues`.
    * Set `self.highlightIndex` to the index of `result.highestRoll` within `self.diceValues`.
    * Display "Critical Success!" and the `result.finalEffect` if `result.isCritical` is true.