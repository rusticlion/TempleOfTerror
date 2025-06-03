Implement Clock-Triggered Consequences:

Action: Add onCompleteConsequences: [Consequence]? and an optional onTickConsequences: [Consequence]? to the GameClock struct in Models.swift.
Action: Modify GameViewModel.updateClock():
If onTickConsequences are present, process them immediately for the active character (or party-wide if a new context is needed).
If a clock's progress meets or exceeds segments and onCompleteConsequences are present, process these consequences. This might involve a new helper function in GameViewModel to process consequences outside the context of a specific character's action (e.g., party-wide effects, environmental changes).
Action: Ensure ContentLoader.swift can parse these new optional fields for GameClocks (if clocks are defined in JSON, though currently they are mostly procedurally generated or hardcoded in DungeonGenerator or GameViewModel.startNewRun).