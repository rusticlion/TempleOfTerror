Task 3: DiceRollView UI/UX Overhaul (DiceRollView.swift)
T3.1: Update State Variables
@State private var baseProjection: RollProjectionDetails?
@State private var displayedProjection: RollProjectionDetails? (this will be dynamically updated)
@State private var availableOptionalModifiers: [SelectableModifierInfo] = []
@State private var chosenModifierIDs: Set<UUID> = []
T3.2: Update onAppear Logic
Call viewModel.getRollContext(...) to populate baseProjection and availableOptionalModifiers.
Initialize displayedProjection = baseProjection.
T3.3: Redesign body for Modifier Selection & Dynamic Projection
Display core action info (character, action name).
Display the current displayedProjection (dice count, position, effect, notes).
Below the projection, render a list of tappable elements (e.g., buttons with custom styling to show selection state) for each SelectableModifierInfo in availableOptionalModifiers.
Include "Push Yourself" in this list.
Each element should clearly display the modifier's description, effect summary (e.g., "+1d"), and remaining uses/cost.
When a modifier element is tapped:
Add/remove its Modifier.id from chosenModifierIDs.
Fetch the Modifier structs corresponding to the currently chosenModifierIDs.
Call viewModel.calculateEffectiveProjection(baseProjection: self.baseProjection!, applying: selectedModifierStructs) to get new RollProjectionDetails.
Update self.displayedProjection.
T3.4: Update "Roll the Dice!" Button Action
Call viewModel.performAction(...), passing Array(chosenModifierIDs).
T3.5: SceneKitDiceView Integration
The diceCount for SceneKitDiceView should be derived from displayedProjection.finalDiceCount.
The pushedDice parameter for SceneKitDiceView should be set based on whether "Push Yourself" is in chosenModifierIDs (and potentially if other dice-adding modifiers are also chosen and meant to be visually distinct).