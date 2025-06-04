Task 2: GameViewModel Logic Refactoring (GameViewModel.swift)
T2.1: Implement getRollContext(...) Method

Signature: func getRollContext(for action: ActionOption, with character: Character) -> (baseProjection: RollProjectionDetails, optionalModifiers: [SelectableModifierInfo])
Calculate baseProjection: Apply all non-optional Penalty effects from character.harm AND all non-optional Modifiers (e.g., harm boons, character modifiers with isOptionalToApply == false).
Gather optionalModifiers: Iterate character.modifiers for those with isOptionalToApply == true, uses > 0 (or unlimited), and matching applicableToAction. Convert to SelectableModifierInfo.
Inject "Push Yourself" as a SelectableModifierInfo (costing 2 Stress) if available.
T2.2: Implement calculateEffectiveProjection(...) Helper Method

Signature: func calculateEffectiveProjection(baseProjection: RollProjectionDetails, applying chosenModifierStructs: [Modifier]) -> RollProjectionDetails
Takes the baseProjection and a list of player-selected Modifier structs.
Layers the effects of chosenModifierStructs onto baseProjection to produce new RollProjectionDetails for UI display.
T2.3: Modify performAction(...) Method

Update signature: func performAction(for action: ActionOption, with character: Character, interactableID: String?, usingDice diceResults: [Int]? = nil, chosenOptionalModifierIDs: [UUID] = []) -> DiceRollResult
Internal Logic Update:
Determine initial roll parameters (action rating, etc.).
Apply all non-optional Penaltys from harm.
Apply all non-optional Modifiers.
Fetch the actual Modifier objects for the chosenOptionalModifierIDs from the acting character's modifiers list.
Apply their effects to the current roll calculation.
Crucially, decrement uses for these chosen modifiers in gameState. Remove if uses reach 0.
Play sfx_modifier_consume.wav if a modifier is consumed.
Execute dice roll (using diceResults if provided, or generating new ones).
Determine outcome and process consequences based on the final roll parameters.
T2.4: Update Harm Boon Application

When a HarmTier.boon (which is a Modifier) is applied to a character (e.g., in applyHarm), ensure its isOptionalToApply property is set to false so it's correctly included in the baseProjection.