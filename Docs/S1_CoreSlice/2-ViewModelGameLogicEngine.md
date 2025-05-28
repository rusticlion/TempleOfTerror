Task 2: The Game Logic Engine (The "ViewModel")
Action: Create the main GameViewModel. This will be the heart of our sprint.

Swift

// In a file named GameViewModel.swift
import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState

    init() {
        // For the sprint, we'll use hardcoded starting data.
        self.gameState = GameState(
            party: [
                Character(name: "Indy", characterClass: "Archaeologist", stress: 0, harm: HarmState(), actions: ["Study": 3, "Wreck": 1]),
                Character(name: "Sallah", characterClass: "Brawler", stress: 0, harm: HarmState(), actions: ["Finesse": 2, "Survey": 2]),
                Character(name: "Marion", characterClass: "Survivor", stress: 0, harm: HarmState(), actions: ["Tinker": 2, "Attune": 1])
            ],
            activeClocks: [
                GameClock(name: "The Guardian Wakes", segments: 6, progress: 0)
            ]
        )
    }

    // --- Core Logic Functions for the Sprint ---

    // Calculates the projection before the roll
    func calculateProjection(for action: ActionOption, with character: Character) -> String {
        // Logic to determine base dice pool from character.actions[action.actionType]
        // For now, just return a descriptive string.
        let diceCount = character.actions[action.actionType] ?? 0
        return "Roll \(diceCount)d6. Position: \(action.position), Effect: \(action.effect)"
    }

    // The main dice roll function
    func performAction(for action: ActionOption, with character: Character, onClock clockID: UUID?) {
        // 1. Get dice pool from character stats.
        // 2. Roll the dice (Int.random(in: 1...6)).
        // 3. Determine outcome (Success, Partial, Failure).
        // 4. Apply consequences/rewards based on Position & Effect.
        //    - On a 4-5 (Partial): self.gameState.party[characterIndex].stress += 2
        //    - On a 1-3 (Failure): self.gameState.party[characterIndex].harm.lesser.append("Bruised")
        //    - On a 6 (Success): Update the clock if a clockID was provided.
        //       if let clockID = clockID { updateClock(id: clockID, ticks: 2) } // 2 for standard effect
        // 5. Ensure the UI updates by modifying the @Published gameState.
    }

    private func updateClock(id: UUID, ticks: Int) {
        if let index = gameState.activeClocks.firstIndex(where: { $0.id == id }) {
            gameState.activeClocks[index].progress = min(gameState.activeClocks[index].segments, gameState.activeClocks[index].progress + ticks)
        }
    }
}