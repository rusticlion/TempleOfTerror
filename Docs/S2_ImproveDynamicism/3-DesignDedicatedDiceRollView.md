Task 3: Design a Dedicated DiceRollView
The Alert is functional but not thematic. A dedicated modal view for the dice roll will significantly improve the game's feel.

Action: Create a new view DiceRollView.swift.
Action: Change ContentView to present this view as a sheet instead of an alert.
DiceRollView.swift (New File)

Swift

import SwiftUI

struct DiceRollResult {
    let highestRoll: Int
    let outcome: String // e.g., "Success", "Partial Success"
    let consequences: String
}

struct DiceRollView: View {
    @ObservedObject var viewModel: GameViewModel
    let action: ActionOption
    let character: Character
    let clockID: UUID?

    // Internal state for the animation
    @State private var diceValues: [Int] = []
    @State private var result: DiceRollResult? = nil
    @State private var isRolling = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text(character.name).font(.title)
            Text("is attempting to...").font(.subheadline).foregroundColor(.secondary)
            Text(action.name).font(.title2).bold()
            
            Spacer()

            if let result = result {
                // View to show after the roll
                VStack {
                    Text(result.outcome).font(.largeTitle).bold()
                    Text("Rolled a \(result.highestRoll)").font(.title3)
                    Text(result.consequences).padding()
                }
            } else {
                // View to show before the roll
                HStack(spacing: 10) {
                    ForEach(0..<diceValues.count, id: \.self) { index in
                        Image(systemName: "die.face.\(diceValues[index]).fill")
                            .font(.largeTitle)
                            .rotationEffect(.degrees(isRolling ? 360 : 0))
                    }
                }
            }

            Spacer()

            if result == nil {
                Button("Roll the Dice!") {
                    // This is where we call the VM logic.
                    // For a better UX, we'd add animation.
                    withAnimation {
                        isRolling = true
                        // The actual logic is now moved here!
                        self.result = viewModel.performAction(for: action, with: character, onClock: clockID)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(30)
        .onAppear {
            let diceCount = max(character.actions[action.actionType] ?? 0, 1)
            self.diceValues = Array(repeating: 1, count: diceCount)
        }
    }
}
To make this work, we'll need to refactor GameViewModel.performAction to return the result instead of just modifying the state directly. This makes the logic more testable and reusable.

GameViewModel.swift (Refactor)

Swift

/// The main dice roll function, now returns the result for the UI.
func performAction(for action: ActionOption, with character: Character, onClock clockID: UUID?) -> DiceRollResult {
    guard let characterIndex = gameState.party.firstIndex(where: { $0.id == character.id }) else {
        // This should not happen in a controlled environment
        return DiceRollResult(highestRoll: 0, outcome: "Error", consequences: "Character not found.")
    }

    let dicePool = max(character.actions[action.actionType] ?? 0, 1)
    var highestRoll = 0
    for _ in 0..<dicePool {
        highestRoll = max(highestRoll, Int.random(in: 1...6))
    }

    var outcome: String
    var consequences: String

    switch highestRoll {
    case 6:
        outcome = "Full Success!"
        consequences = "You master the situation."
        if let clockID = clockID {
            let ticks = 2 // Standard effect
            updateClock(id: clockID, ticks: ticks)
            consequences += "\nThe '\(gameState.activeClocks.first(where: {$0.id == clockID})?.name ?? "")' clock progresses by \(ticks)."
        }
    case 4...5:
        outcome = "Partial Success..."
        gameState.party[characterIndex].stress += 2
        consequences = "You do it, but at a cost. Gained 2 Stress."
    default:
        outcome = "Failure."
        gameState.party[characterIndex].harm.lesser.append("Bruised")
        consequences = "Things go wrong. You suffer minor harm."
    }
    
    return DiceRollResult(highestRoll: highestRoll, outcome: outcome, consequences: consequences)
}