Enhance HarmTier Model for "Double-Edged" Effects:

Action: Add an optional boon: Modifier? property to the HarmTier struct in Models.swift.
Action: Update GameViewModel.calculateProjection() to check for and apply any active boons from a character's harm conditions, adding notes to RollProjectionDetails.
Action: Ensure the UI (CharacterSheetView.swift) can display these boons alongside penalties if a harm has both.
Action: Create 1-2 new HarmFamily definitions in Content/Scenarios/charons_bargain/harm_families.json (e.g., "vfe_physical_aberration") that utilize this new boon property alongside penalty.