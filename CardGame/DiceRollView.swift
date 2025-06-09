import SwiftUI

struct DiceRollView: View {
    @ObservedObject var viewModel: GameViewModel
    let action: ActionOption
    let character: Character
    let clockID: UUID?
    let interactableID: String?

    @State private var diceValues: [Int] = []
    @State private var result: DiceRollResult? = nil
    @State private var baseProjection: RollProjectionDetails? = nil
    @State private var displayedProjection: RollProjectionDetails? = nil
    @State private var availableOptionalModifiers: [SelectableModifierInfo] = []
    @State private var chosenModifierIDs: Set<UUID> = []
    @State private var isRolling = false
    @State private var highlightIndex: Int? = nil
    @State private var fadeOthers = false
    @State private var showOutcome = false
    @State private var showVignette = false

    @StateObject private var diceController = SceneKitDiceController()


    @Environment(\.dismiss) var dismiss

    private func toggleModifier(_ info: SelectableModifierInfo) {
        if chosenModifierIDs.contains(info.id) {
            chosenModifierIDs.remove(info.id)
        } else {
            chosenModifierIDs.insert(info.id)
        }
        let selectedMods = availableOptionalModifiers
            .filter { chosenModifierIDs.contains($0.id) }
            .map { $0.modifierData }
        if let base = baseProjection {
            let proj = viewModel.calculateEffectiveProjection(baseProjection: base,
                                                              applying: selectedMods)
            displayedProjection = proj
            let diceCount = max(proj.finalDiceCount, 1)
            diceValues = Array(repeating: 1, count: diceCount)
        }
    }

    private var pushedDiceCount: Int {
        guard let pushInfo = availableOptionalModifiers.first(where: { $0.description == "Push Yourself" }) else { return 0 }
        return chosenModifierIDs.contains(pushInfo.id) ? pushInfo.modifierData.bonusDice : 0
    }

    private func startShaking() {
        showVignette = true
        AudioManager.shared.play(sound: "sfx_dice_shake.wav")
    }

    private func stopShaking(results: [Int]) {
        AudioManager.shared.play(sound: "sfx_dice_land.wav")
        showVignette = false
        isRolling = false
        let rollResult = viewModel.performAction(for: action,
                                                with: character,
                                                interactableID: interactableID,
                                                usingDice: results,
                                                chosenOptionalModifierIDs: Array(chosenModifierIDs))
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
                    ScrollView {
                        Text(result.consequences)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxHeight: 200)
                }
            } else if let proj = displayedProjection {
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

            if result == nil && !availableOptionalModifiers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(availableOptionalModifiers) { info in
                        Button {
                            toggleModifier(info)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(info.description).font(.subheadline)
                                    Text(info.detailedEffect).font(.caption)
                                }
                                Spacer()
                                Text(info.remainingUses).font(.caption2)
                                if chosenModifierIDs.contains(info.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                            .padding(6)
                            .frame(maxWidth: .infinity)
                            .background(chosenModifierIDs.contains(info.id) ? Color.accentColor.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            SceneKitDiceView(controller: diceController,
                             diceCount: diceValues.count,
                             pushedDice: pushedDiceCount)
                .frame(height: 200)

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
            var tags: [String] = []
            if let id = interactableID,
               let nodeID = viewModel.gameState.characterLocations[character.id.uuidString],
               let inter = viewModel.gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.first(where: { $0.id == id }) {
                tags = inter.tags
            }
            let context = viewModel.getRollContext(for: action, with: character, interactableTags: tags)
            self.baseProjection = context.baseProjection
            self.displayedProjection = context.baseProjection
            self.availableOptionalModifiers = context.optionalModifiers
            let diceCount = max(context.baseProjection.finalDiceCount, 1)
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

