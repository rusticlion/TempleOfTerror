Task 4: Content Updates & Testing
T4.1: Review & Update Existing Content
Examine treasures.json and harm_families.json (especially harm boons).
Ensure Modifier definitions correctly reflect whether they should be isOptionalToApply = true (most treasures) or false (most harm boons, always-on item effects).
T4.2: Create New Test Content (if needed)
Add 1-2 new treasures that grant clearly optional, impactful, limited-use modifiers to thoroughly test the selection UI and consumption logic.
Consider a test interactable whose resolution significantly benefits from choosing these optional modifiers.
T4.3: Comprehensive Testing
Verify baseProjection calculations (non-optional penalties/boons applied).
Confirm availableOptionalModifiers list is accurate (including "Push Yourself").
Test selection/deselection of modifiers and the dynamic update of displayedProjection.
Confirm that rolling correctly applies chosen modifiers and consumes their uses.
Test scenarios with multiple optional modifiers available.
Test interactions between harm penalties, harm boons, and chosen optional modifiers.
Ensure sfx_modifier_consume.wav plays at the right time.
Verify visual cues for penalty/bonus actions on InteractableCardView still make sense with the new system.