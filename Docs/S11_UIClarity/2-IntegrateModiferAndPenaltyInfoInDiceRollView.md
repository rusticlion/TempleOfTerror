Task 2: Integrate Modifier/Penalty Info into DiceRollView Projection
Description: The calculateProjection string is good, but we need to make it explicitly clear why the dice pool, Position, or Effect might be different from their base values, especially due to Harm penalties or active Modifiers. The DiceRollView itself should also visually hint at these changes.

Implementation Plan:

Refactor GameViewModel.calculateProjection:
Instead of returning a simple String, modify it to return a new struct, e.g., RollProjectionDetails.
Swift

struct RollProjectionDetails {
    var baseDiceCount: Int
    var finalDiceCount: Int
    var basePosition: RollPosition
    var finalPosition: RollPosition
    var baseEffect: RollEffect
    var finalEffect: RollEffect
    var notes: [String] // e.g., ["-1d from Shattered Hand", "+1 Effect from Lens (1 use left)"]
}
The function should calculate the base values, then iterate through active HarmCondition penalties and applicable Modifier bonuses, adjusting the finalDiceCount, finalPosition, finalEffect, and populating the notes array.
Update DiceRollView.swift:
When presenting the pre-roll information (before result is set), use the RollProjectionDetails.
Display the finalDiceCount, finalPosition, and finalEffect prominently.
Below this, list each string from projectionDetails.notes. Use color-coding: red for notes originating from Harm, green or blue for notes from Modifiers/Treasures.
If a modifier is about to be consumed (e.g., a Treasure with uses: 1), make this clear in the notes (e.g., "Lens of True Sight will be consumed").
Visual Cues for ActionOption Buttons:
In InteractableCardView.swift, before an action is even tapped, if a selected character has a Harm penalty directly affecting an actionType for one of the availableActions (e.g., "Brain Lightning" banAction for "Study"), visually indicate this on the button itself.
This could be greying out the button slightly, adding a "cracked" overlay, or a small warning icon. This requires InteractableCardView to have access to the selectedCharacter's state or for ContentView to pass down pre-calculated penalty info.
Asset Callouts:

icon_penalty_action.png: A small, dithered red "X" or "broken tool" icon to overlay on an action button if it's negatively affected by Harm.
Canvas Size: 48x48 pixels (to be scaled down next to button text).
icon_bonus_action.png: A small, dithered green/cyan "+" or "star" icon if an action is positively affected by a Modifier.
Canvas Size: 48x48 pixels.