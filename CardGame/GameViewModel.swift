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

    /// Calculates the projection before the roll.
    func calculateProjection(for action: ActionOption, with character: Character) -> String {
        // Determine base dice pool from the character's action ratings.
        let diceCount = character.actions[action.actionType] ?? 0
        return "Roll \(diceCount)d6. Position: \(action.position.rawValue), Effect: \(action.effect.rawValue)"
    }

    /// The main dice roll function.
    func performAction(for action: ActionOption, with character: Character, onClock clockID: UUID?) {
        guard let characterIndex = gameState.party.firstIndex(where: { $0.id == character.id }) else {
            return
        }

        // 1. Get dice pool from character stats.
        let dicePool = max(character.actions[action.actionType] ?? 0, 1)
        var highestRoll = 1
        for _ in 0..<dicePool {
            highestRoll = max(highestRoll, Int.random(in: 1...6))
        }

        // 2. Determine outcome and apply consequences or rewards.
        switch highestRoll {
        case 6:
            // Success
            if let clockID = clockID {
                updateClock(id: clockID, ticks: 2) // 2 for standard effect
            }
        case 4...5:
            // Partial Success
            gameState.party[characterIndex].stress += 2
        default:
            // Failure
            gameState.party[characterIndex].harm.lesser.append("Bruised")
        }
    }

    private func updateClock(id: UUID, ticks: Int) {
        if let index = gameState.activeClocks.firstIndex(where: { $0.id == id }) {
            gameState.activeClocks[index].progress = min(gameState.activeClocks[index].segments,
                                                         gameState.activeClocks[index].progress + ticks)
        }
    }
}

