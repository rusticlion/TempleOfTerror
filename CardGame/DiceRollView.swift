import SwiftUI

struct DiceRollResult {
    let highestRoll: Int
    let outcome: String
    let consequences: String
}

struct DiceRollView: View {
    @ObservedObject var viewModel: GameViewModel
    let action: ActionOption
    let character: Character
    let clockID: UUID?

    @State private var diceValues: [Int] = []
    @State private var result: DiceRollResult? = nil
    @State private var isRolling = false
    @State private var extraDiceFromPush = 0
    @State private var hasPushed = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text(character.name).font(.title)
            Text("is attempting to...").font(.subheadline).foregroundColor(.secondary)
            Text(action.name).font(.title2).bold()

            Spacer()

            if let result = result {
                VStack {
                    Text(result.outcome).font(.largeTitle).bold()
                    Text("Rolled a \(result.highestRoll)").font(.title3)
                    Text(result.consequences).padding()
                }
            } else {
                VStack(spacing: 20) {
                    HStack(spacing: 10) {
                        let totalDice = (diceValues.count + extraDiceFromPush)
                        ForEach(0..<totalDice, id: \.self) { index in
                            Image(systemName: "die.face.\(diceValues.indices.contains(index) ? diceValues[index] : 1).fill")
                                .font(.largeTitle)
                                .foregroundColor(index >= diceValues.count ? .cyan : .primary)
                                .rotationEffect(.degrees(isRolling ? 360 : 0))
                        }
                    }

                    Button {
                        viewModel.pushYourself(forCharacter: character)
                        extraDiceFromPush += 1
                        hasPushed = true
                    } label: {
                        Text("Push Yourself (+1d for 2 Stress)")
                    }
                    .disabled(hasPushed)
                    .buttonStyle(.bordered)
                }
            }

            Spacer()

            if result == nil {
                Button("Roll the Dice!") {
                    withAnimation {
                        isRolling = true
                        self.result = viewModel.performAction(for: action, with: character)
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

