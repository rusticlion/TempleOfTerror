Task 1: Data Model Enhancements (Models.swift)
T1.1: Enhance Modifier Struct
Add id: UUID = UUID() to Modifier for unique identification.
Add isOptionalToApply: Bool = true to Modifier.
Default to true for treasure-granted modifiers.
Ensure boons from HarmTier will result in Modifiers with isOptionalToApply = false.
T1.2: Define SelectableModifierInfo Struct
Create this struct (e.g., in GameViewModel.swift or a shared models file) for DiceRollView consumption.
Fields: id: UUID (Modifier's ID), description: String, detailedEffect: String, remainingUses: String, modifierData: Modifier (to hold the actual modifier details for recalculation/display).
