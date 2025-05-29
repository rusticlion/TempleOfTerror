Task 1: Enhance Character Stat Display in PartyStatusView
Description: The current PartyStatusView shows Stress and Harm icons. Let's make it more comprehensive by clearly listing action ratings and any active Modifiers a character has.

Implementation Plan:

In PartyStatusView.swift, for each character, below their Harm icons, add a new section.
Action Ratings: Display each of the character's actions (e.g., "Study: 3," "Tinker: 2") in a compact list or grid.
Active Modifiers: If a character has any active modifiers from their treasures, list their descriptions (e.g., "from Lens of True Sight: +1 Effect to Survey (1 use left)").
Consider a distinct visual treatment (e.g., a different color, a small icon next to them) for active modifiers.