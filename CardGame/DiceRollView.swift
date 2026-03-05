import SwiftUI

struct ResolutionNarrativeView: View {
    let text: String

    var body: some View {
        ScrollView {
            if text.isEmpty {
                Text("Awaiting your decision.")
                    .font(Theme.bodyFont(size: 14, italic: true))
                    .foregroundColor(Theme.inkFaded)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            } else {
                Text(text)
                    .font(Theme.bodyFont(size: 14))
                    .foregroundColor(Theme.parchmentDark)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxHeight: 260)
        .background(Theme.parchment.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Theme.parchmentDeep.opacity(0.15), lineWidth: 1)
        )
    }
}

struct ResolutionDecisionCard: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showingResistanceRoll = false

    var body: some View {
        Group {
            if let choice = viewModel.gameState.pendingResolution?.pendingChoice {
                VStack(alignment: .leading, spacing: 12) {
                    Text(choice.prompt ?? "Choose what happens next.")
                        .font(Theme.bodyFont(size: 15))
                        .foregroundColor(Theme.parchment)

                    ForEach(Array(choice.options.enumerated()), id: \.offset) { index, option in
                        Button {
                            showingResistanceRoll = false
                            _ = viewModel.choosePendingChoice(at: index)
                        } label: {
                            HStack {
                                Text(option.title)
                                    .font(Theme.bodyFont(size: 14))
                                    .foregroundColor(Theme.parchment)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Theme.gold)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Theme.parchment.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Theme.parchmentDeep.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                .background(Theme.leather.opacity(0.65))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if let resistance = viewModel.gameState.pendingResolution?.pendingResistance {
                VStack(alignment: .leading, spacing: 12) {
                    Text(resistance.prompt ?? "A consequence is about to land.")
                        .font(Theme.bodyFont(size: 15))
                        .foregroundColor(Theme.parchment)

                    Text("Resist with \(resistance.attribute.title)")
                        .font(Theme.displayFont(size: 18))
                        .foregroundColor(Theme.gold)

                    Text(resistance.attribute.actionTypes.joined(separator: ", "))
                        .font(Theme.systemFont(size: 11))
                        .foregroundColor(Theme.inkFaded)

                    if showingResistanceRoll {
                        let pool = viewModel.pendingResistanceDicePool() ?? 0
                        Text(pool > 0
                             ? "Roll \(pool)d6 and pay 6 minus the highest result in Stress."
                             : "Roll 2d6, keep the lower die, and pay 6 minus that result in Stress.")
                            .font(Theme.systemFont(size: 12))
                            .foregroundColor(Theme.parchmentDark)

                        HStack(spacing: 12) {
                            Button("Back") {
                                showingResistanceRoll = false
                            }
                            .font(Theme.systemFont(size: 13, weight: .semibold))
                            .foregroundColor(Theme.parchmentDark)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Theme.parchmentDeep.opacity(0.35), lineWidth: 1)
                            )

                            Button("Roll Resistance") {
                                _ = viewModel.resistPendingConsequence()
                                showingResistanceRoll = false
                            }
                            .font(Theme.systemFont(size: 13, weight: .semibold))
                            .foregroundColor(Theme.ink)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Theme.gold)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    } else {
                        HStack(spacing: 12) {
                            Button("Take It") {
                                _ = viewModel.acceptPendingResistance()
                            }
                            .font(Theme.systemFont(size: 13, weight: .semibold))
                            .foregroundColor(Theme.parchmentDark)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Theme.parchmentDeep.opacity(0.35), lineWidth: 1)
                            )

                            Button("Resist") {
                                showingResistanceRoll = true
                            }
                            .font(Theme.systemFont(size: 13, weight: .semibold))
                            .foregroundColor(Theme.ink)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Theme.gold)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(16)
                .background(Theme.leather.opacity(0.65))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .onChange(of: viewModel.gameState.pendingResolution?.pendingResistance?.attribute.rawValue) { _ in
            showingResistanceRoll = false
        }
        .onChange(of: viewModel.gameState.pendingResolution?.pendingChoice?.options.count) { _ in
            showingResistanceRoll = false
        }
    }
}

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
        let debugOverride = displayedProjection.flatMap { projection in
            viewModel.debugActionDiceOverride(rawPool: projection.rawDicePool)
        }
        let resolvedDice = debugOverride ?? results
        let rollResult = viewModel.performAction(for: action,
                                                 with: character,
                                                 interactableID: interactableID,
                                                 usingDice: resolvedDice,
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

    private func outcomeLabel(for result: DiceRollResult) -> String {
        let normalized = result.outcome.lowercased()
        if normalized.contains("full success") {
            return "SUCCESS"
        }
        if normalized.contains("partial") {
            return "PARTIAL"
        }
        if normalized.contains("failure") || normalized.contains("cannot") || normalized.contains("error") {
            return "FAILURE"
        }
        return result.outcome.uppercased()
    }

    private func outcomeColor(for result: DiceRollResult) -> Color {
        let label = outcomeLabel(for: result)
        switch label {
        case "SUCCESS":
            return Theme.success
        case "PARTIAL":
            return Theme.gold
        case "FAILURE":
            return Theme.danger
        default:
            return Theme.parchment
        }
    }

    private var displayedConsequenceText: String {
        if let pending = viewModel.gameState.pendingResolution {
            return pending.resolvedText
        }
        return result?.consequences ?? ""
    }

    private var canDismiss: Bool {
        viewModel.gameState.pendingResolution?.isAwaitingDecision != true
    }

    var body: some View {
        ZStack {
            Theme.dramaticBackground.ignoresSafeArea()

            VStack(spacing: 20) {
                Text(character.name)
                    .font(Theme.displayFont(size: 14))
                    .foregroundColor(Theme.parchmentDark)

                if let result = result, showOutcome {
                    VStack(spacing: 6) {
                        let color = outcomeColor(for: result)
                        Text(outcomeLabel(for: result))
                            .font(Theme.displayFont(size: 42))
                            .foregroundColor(color)
                            .shadow(color: color.opacity(0.4), radius: 20)
                            .transition(.scale.combined(with: .opacity))

                        if result.isCritical == true {
                            Text("✦ CRITICAL ✦")
                                .font(Theme.systemFont(size: 13, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(Theme.goldBright)
                        }

                        Text("Rolled a \(result.highestRoll)")
                            .font(Theme.systemFont(size: 12))
                            .foregroundColor(Theme.parchmentDark)

                        if let eff = result.finalEffect {
                            Text("Effect: \(eff.rawValue.capitalized)")
                                .font(Theme.systemFont(size: 12))
                                .foregroundColor(Theme.inkFaded)
                        }
                    }
                } else {
                    Text("is attempting to...")
                        .font(Theme.systemFont(size: 13))
                        .foregroundColor(Theme.inkFaded)

                    Text(action.name)
                        .font(Theme.displayFont(size: 26))
                        .foregroundColor(Theme.parchment)

                    Text("\(action.actionType): \(character.actions[action.actionType] ?? 0)")
                        .font(Theme.systemFont(size: 12))
                        .foregroundColor(Theme.inkFaded)
                }

                Spacer()

                if result != nil, showOutcome {
                    VStack(spacing: 14) {
                        ResolutionNarrativeView(text: displayedConsequenceText)

                        if viewModel.gameState.pendingResolution?.isAwaitingDecision == true {
                            ResolutionDecisionCard(viewModel: viewModel)
                        }
                    }
                } else if let proj = displayedProjection {
                    VStack(spacing: 12) {
                        Text("\(proj.finalDiceCount)d6")
                            .font(Theme.displayFont(size: 48))
                            .foregroundColor(Theme.parchment)

                        HStack(spacing: 20) {
                            VStack(spacing: 2) {
                                Text("POSITION")
                                    .font(Theme.systemFont(size: 10, weight: .semibold))
                                    .tracking(1)
                                    .foregroundColor(Theme.inkFaded)
                                Text(proj.finalPosition.rawValue.capitalized)
                                    .font(Theme.displayFont(size: 18))
                                    .foregroundColor(Theme.positionColor(proj.finalPosition))
                            }

                            Rectangle()
                                .fill(Theme.inkFaded.opacity(0.3))
                                .frame(width: 1, height: 30)

                            VStack(spacing: 2) {
                                Text("EFFECT")
                                    .font(Theme.systemFont(size: 10, weight: .semibold))
                                    .tracking(1)
                                    .foregroundColor(Theme.inkFaded)
                                Text(proj.finalEffect.rawValue.capitalized)
                                    .font(Theme.displayFont(size: 18))
                                    .foregroundColor(Theme.parchment)
                            }
                        }

                        ForEach(proj.notes, id: \.self) { note in
                            Text(note)
                                .font(Theme.systemFont(size: 11))
                                .foregroundColor(
                                    note.contains("-") || note.contains("Cannot")
                                    ? Theme.dangerLight
                                    : Theme.goldDim
                                )
                                .multilineTextAlignment(.center)
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
                                        Text(info.description)
                                            .font(Theme.bodyFont(size: 14))
                                            .foregroundColor(Theme.parchment)
                                        Text(info.detailedEffect)
                                            .font(Theme.systemFont(size: 11))
                                            .foregroundColor(Theme.inkFaded)
                                    }
                                    Spacer()
                                    Text(info.remainingUses)
                                        .font(Theme.systemFont(size: 10))
                                        .foregroundColor(Theme.inkFaded)

                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(chosenModifierIDs.contains(info.id) ? Theme.gold : Theme.gold.opacity(0.4), lineWidth: 2)
                                        .frame(width: 20, height: 20)
                                        .overlay {
                                            if chosenModifierIDs.contains(info.id) {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(Theme.gold)
                                            }
                                        }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Theme.parchment.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Theme.parchmentDeep.opacity(0.2), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [Theme.leatherLight.opacity(0.9), Theme.leather.opacity(0.95)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Theme.parchmentDeep.opacity(0.25), lineWidth: 1)

                    RoundedRectangle(cornerRadius: 13)
                        .fill(Theme.bg.opacity(0.82))
                        .padding(8)

                    SceneKitDiceView(controller: diceController,
                                     diceCount: diceValues.count,
                                     pushedDice: pushedDiceCount)
                        .clipShape(RoundedRectangle(cornerRadius: 11))
                        .padding(10)

                    RoundedRectangle(cornerRadius: 11)
                        .stroke(Theme.ink.opacity(0.55), lineWidth: 1.2)
                        .padding(10)

                    RoundedRectangle(cornerRadius: 11)
                        .fill(
                            RadialGradient(
                                colors: [Color.clear, Theme.bg.opacity(0.14)],
                                center: .center,
                                startRadius: 40,
                                endRadius: 190
                            )
                        )
                        .padding(10)
                        .allowsHitTesting(false)

                    RoundedRectangle(cornerRadius: 13)
                        .stroke(
                            LinearGradient(
                                colors: [Theme.parchmentDeep.opacity(0.4), Theme.ink.opacity(0.2)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                        .padding(8)
                }
                .frame(height: 248)
                .shadow(color: .black.opacity(0.35), radius: 10, y: 6)

                Spacer()

                if result == nil {
                    if let projection = displayedProjection,
                       let debugDice = viewModel.debugActionDiceOverride(rawPool: projection.rawDicePool) {
                        Text("Debug fixed roll: \(debugDice.map(String.init).joined(separator: ", "))")
                            .font(Theme.systemFont(size: 11))
                            .foregroundColor(Theme.goldDim)
                    }

                    let canRoll = !isRolling && diceController.isViewportReady && !diceValues.isEmpty
                    Button("Roll the Dice") {
                        guard canRoll else { return }
                        isRolling = true
                        startShaking()
                        diceController.rollDice()
                    }
                    .font(Theme.displayFont(size: 18))
                    .foregroundColor(Theme.ink)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Theme.gold, Theme.goldDim],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: Theme.gold.opacity(0.3), radius: 12, y: 4)
                    .disabled(!canRoll)
                    .opacity(canRoll ? 1 : 0.55)
                } else {
                    Button("Done") {
                        if viewModel.gameState.pendingResolution?.isComplete == true {
                            viewModel.clearPendingResolution()
                        }
                        dismiss()
                    }
                    .font(Theme.displayFont(size: 16, weight: .semibold))
                    .foregroundColor(Theme.parchment)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Theme.parchmentDeep.opacity(0.4), lineWidth: 1)
                    )
                    .disabled(!canDismiss)
                    .opacity(canDismiss ? 1 : 0.45)
                }
            }
            .padding(30)
        }
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
        .interactiveDismissDisabled(!canDismiss)
    }
}
