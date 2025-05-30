### Task 3: Implement Consequence Gating and Position/Effect Modulation

**Goal:** Refactor `GameViewModel.performAction` to filter consequences based on their new conditions and to use `finalEffect` and `finalPosition` to determine the quantity/potency of actual applied consequences.

**Actions:**

1.  **Create `areConditionsMet()` helper in `GameViewModel.swift`:**
    ```swift
    private func areConditionsMet(
        conditions: [GameCondition]?,
        forCharacter character: Character,
        finalEffect: RollEffect,
        finalPosition: RollPosition
        // Pass gameState directly or access self.gameState
    ) -> Bool {
        guard let conditions = conditions, !conditions.isEmpty else { return true } // No conditions means eligible

        for condition in conditions {
            var conditionMet = false
            switch condition.type {
            case .requiresMinEffectLevel:
                if let reqEffect = condition.effectParam { conditionMet = finalEffect.isBetterThanOrEqualTo(reqEffect) } //
            case .requiresExactEffectLevel:
                conditionMet = (condition.effectParam == finalEffect)
            case .requiresMinPositionLevel:
                if let reqPos = condition.positionParam { conditionMet = finalPosition.isWorseThanOrEqualTo(reqPos) } // Assuming Position enum gets an orderValue
            case .requiresExactPositionLevel:
                conditionMet = (condition.positionParam == finalPosition)
            case .characterHasTreasureId:
                if let tId = condition.stringParam { conditionMet = character.treasures.contains(where: { $0.id == tId }) } //
            case .partyHasTreasureWithTag:
                // Assuming Treasure struct gets a `tags: [String]?` field.
                // And GameCondition stringParam holds the tag.
                // conditionMet = gameState.party.flatMap { $0.treasures }.contains(where: { $0.tags?.contains(condition.stringParam ?? "") == true })
                print("WARN: partyHasTreasureWithTag condition not fully implemented yet.")
            case .clockProgress:
                if let cName = condition.stringParam, let minProg = condition.intParam {
                    if let clock = gameState.activeClocks.first(where: { $0.name == cName }) { //
                        var metMin = clock.progress >= minProg
                        if let maxProg = condition.intParamMax { // Optional max check
                            metMin = metMin && clock.progress <= maxProg
                        }
                        conditionMet = metMin
                    }
                }
            }
            if !conditionMet { return false } // All conditions must be met
        }
        return true
    }
    ```
    *(Note: `RollPosition` will need an `orderValue` and `isWorseThanOrEqualTo` similar to `RollEffect` for min/max checks: Desperate > Risky > Controlled).*

2.  **Refactor `GameViewModel.performAction()` processing logic:**
    * After determining `finalRollOutcome`, `isCritical`, `finalPosition`, `finalEffect`:
    * Get the base list of `Consequence` structs for the `finalRollOutcome` from `action.outcomes`.
    * Filter this list using `areConditionsMet()` to create a new list of *eligibleConsequences*.
    * **Apply Consequences based on Pools & Modulation:**
        * **Success Outcome:**
            * From *eligibleConsequences* that are positive:
                * Shallow pool: Apply defined consequence(s). `finalEffect` might increase potency/quantity if defined (e.g., an "amount" field in Consequence struct could be base, and `finalEffect` applies a multiplier or adds to it).
                * Deep pool: Draw N positive consequences based on `finalEffect`. `isCritical` could allow an extra draw or access to special crit-only gated consequences.
        * **Partial Success Outcome:**
            * Positive side: From *eligibleConsequences*, apply/draw based on `finalEffect`.
            * Negative side: From *eligibleConsequences*, apply/draw based on `finalPosition`.
        * **Failure Outcome:**
            * From *eligibleConsequences* that are negative: Apply/draw based on `finalPosition`.
    * The `processConsequences` method will then take this *final, filtered, and selected* list of consequences to apply to the `gameState`.
