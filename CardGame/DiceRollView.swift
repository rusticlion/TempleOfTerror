import SwiftUI

struct DiceRollView: View {
    @ObservedObject var viewModel: GameViewModel
    let action: ActionOption
    let character: Character
    let clockID: UUID?
    let interactableID: String?

    @State private var diceValues: [Int] = []
    @State private var result: DiceRollResult? = nil
    @State private var projection: RollProjectionDetails? = nil
    @State private var isRolling = false
    @State private var extraDiceFromPush = 0
    @State private var hasPushed = false
    @State private var highlightIndex: Int? = nil
    @State private var fadeOthers = false
    @State private var showOutcome = false
    @State private var showVignette = false

    @StateObject private var diceController = SceneKitDiceController()


    @Environment(\.dismiss) var dismiss

    private func startShaking() {
        showVignette = true
        AudioManager.shared.play(sound: "sfx_dice_shake.wav")
    }

    private func stopShaking(results: [Int]) {
        AudioManager.shared.play(sound: "sfx_dice_land.wav")
        showVignette = false
        isRolling = false
        let rollResult = viewModel.performAction(for: action, with: character, interactableID: interactableID, usingDice: results)
        self.result = rollResult
        if let rolled = rollResult.actualDiceRolled {
            self.diceValues = rolled
            if let idx = rolled.firstIndex(of: rollResult.highestRoll) {
                self.highlightIndex = idx
            } else {
                self.highlightIndex = nil
            }
        } else {
            let totalDice = diceValues.count
            highlightIndex = Int.random(in: 0..<totalDice)
            diceValues = (0..<totalDice).map { idx in
                if idx == highlightIndex { return rollResult.highestRoll }
                return Int.random(in: 1...max(1, min(rollResult.highestRoll, 5)))
            }
        }
        fadeOthers = true
        diceController.highlightDie(at: highlightIndex, fadeOthers: true)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            showOutcome = true
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(character.name).font(.title)
            Text("is attempting to...").font(.subheadline).foregroundColor(.secondary)
            Text(action.name).font(.title2).bold()
            Text("\(action.actionType): \(character.actions[action.actionType] ?? 0)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            if let result = result, showOutcome {
                VStack {
                    Text(result.outcome)
                        .font(.largeTitle)
                        .bold()
                        .transition(.scale.combined(with: .opacity))
                    if result.isCritical == true {
                        Text("CRITICAL SUCCESS!")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                    if let eff = result.finalEffect {
                        Text("Effect: \(eff.rawValue.capitalized)")
                            .font(.subheadline)
                    }
                    Text("Rolled a \(result.highestRoll)").font(.title3)
                    Text(result.consequences).padding()
                }
            } else if let proj = projection {
                VStack(spacing: 4) {
                    Text("Dice: \(proj.finalDiceCount)d6")
                        .font(.headline)
                    Text("Position: \(proj.finalPosition.rawValue.capitalized), Effect: \(proj.finalEffect.rawValue.capitalized)")
                        .font(.subheadline)
                    ForEach(proj.notes, id: \.self) { note in
                        Text(note)
                            .font(.caption)
                            .foregroundColor(
                                note.contains("0 rating") ? .orange :
                                (note.contains("-") || note.contains("Cannot") ? .red : .blue)
                            )
                    }
                }
            }

            VStack(spacing: 20) {
                SceneKitDiceView(controller: diceController, diceCount: diceValues.count, pushedDice: extraDiceFromPush)
                    .frame(height: 200)

                if result == nil {
                    Button {
                        viewModel.pushYourself(forCharacter: character)
                        extraDiceFromPush += 1
                        diceValues.append(1)
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
                    isRolling = true
                    startShaking()
                    diceController.rollDice()
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
            let proj = viewModel.calculateProjection(for: action, with: character)
            self.projection = proj
            let diceCount = max(proj.finalDiceCount, 1)
            self.diceValues = Array(repeating: 1, count: diceCount)
            diceController.onDiceSettled = { results in
                self.stopShaking(results: results)
            }
        }
        .overlay(
            Group {
                if showVignette {
                    Image("vfx_damage_vignette")
                        .resizable()
                        .scaledToFill()
                        .transition(.opacity)
                        .ignoresSafeArea()
                }
            }
        )
    }
}

