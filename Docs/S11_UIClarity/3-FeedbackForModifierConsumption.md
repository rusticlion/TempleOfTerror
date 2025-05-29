Task 3: Explicit Feedback for Modifier Consumption
Description: When a Treasure's Modifier with limited uses is consumed, provide clear feedback that it happened.

Implementation Plan:

GameViewModel.performAction():
When applying Modifiers, if a modifier has its uses decremented to 0 (or removed if it was the last use), this information should be part of the DiceRollResult.consequences string. E.g., "Used up Lens of True Sight."
DiceRollView.swift: The result.consequences text will automatically display this.
PartyStatusView.swift: This view will naturally update as the character's modifiers list changes (as GameViewModel is an @ObservedObject), so consumed modifiers will disappear from the list.
Sound Effect (Optional but Recommended):
Play a distinct sound effect when a limited-use modifier is consumed.
Asset Callouts:

Audio:
sfx_modifier_consume.wav: A short, slightly "magical" or "vanishing" sound (e.g., a quick shimmer or puff).