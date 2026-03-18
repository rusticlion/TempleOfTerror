import SwiftUI

struct ResolutionAftermathView: View {
    let entries: [String]
    var isDecisionPending: Bool = false

    private var visibleEntries: [String] {
        entries.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private var maxHeight: CGFloat {
        if visibleEntries.isEmpty {
            return 54
        }
        return isDecisionPending ? 170 : 240
    }

    var body: some View {
        Group {
            if visibleEntries.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "text.line.first.and.arrowtriangle.forward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Theme.inkFaded)

                    Text("Resolved fallout will collect here.")
                        .font(Theme.bodyFont(size: 13, italic: true))
                        .foregroundColor(Theme.inkFaded)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(visibleEntries.enumerated()), id: \.offset) { index, entry in
                            HStack(alignment: .top, spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.goldDim.opacity(0.25))
                                        .frame(width: 22, height: 22)

                                    Text("\(index + 1)")
                                        .font(Theme.systemFont(size: 10, weight: .semibold))
                                        .foregroundColor(Theme.goldBright)
                                }
                                .padding(.top, 1)

                                Text(entry)
                                    .font(Theme.bodyFont(size: 14))
                                    .foregroundColor(Theme.parchmentDark)
                                    .lineSpacing(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(maxHeight: maxHeight)
        .background(Theme.parchment.opacity(visibleEntries.isEmpty ? 0.03 : 0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Theme.parchmentDeep.opacity(0.15), lineWidth: 1)
        )
    }
}

private struct ResistanceVerdictState: Equatable {
    let attribute: ResistanceAttribute
    let title: String
    let sequenceLabel: String
    let highestRoll: Int
    let stressCost: Int
    let resolutionSummary: String
}

private struct ResistanceVerdictCard: View {
    let verdict: ResistanceVerdictState

    private func accent(for attribute: ResistanceAttribute) -> Color {
        switch attribute {
        case .insight:
            return Color(red: 0.45, green: 0.70, blue: 0.72)
        case .prowess:
            return Theme.dangerLight
        case .resolve:
            return Theme.goldBright
        }
    }

    var body: some View {
        let accent = accent(for: verdict.attribute)

        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verdict.sequenceLabel)
                        .font(Theme.systemFont(size: 11, weight: .semibold))
                        .foregroundColor(accent)
                        .textCase(.uppercase)
                        .tracking(0.7)

                    Text(verdict.title)
                        .font(Theme.bodyFontMedium(size: 16))
                        .foregroundColor(Theme.parchment)
                }

                Spacer(minLength: 8)

                Text(verdict.attribute.title)
                    .font(Theme.systemFont(size: 11, weight: .semibold))
                    .foregroundColor(Theme.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(accent, in: Capsule())
            }

            HStack(spacing: 8) {
                Text("Rolled \(verdict.highestRoll)")
                    .font(Theme.systemFont(size: 11, weight: .semibold))
                    .foregroundColor(Theme.parchmentDark)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.parchment.opacity(0.08), in: Capsule())

                Text(verdict.stressCost == 0 ? "No Stress" : "\(verdict.stressCost) Stress")
                    .font(Theme.systemFont(size: 11, weight: .semibold))
                    .foregroundColor(Theme.parchmentDark)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.parchment.opacity(0.08), in: Capsule())
            }

            Text(verdict.resolutionSummary)
                .font(Theme.bodyFont(size: 14))
                .foregroundColor(Theme.parchment)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accent.opacity(0.11), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(accent.opacity(0.35), lineWidth: 1)
        )
    }
}

private struct OptionalBoostCard: View {
    let title: String
    let detail: String
    let status: String
    let isSelected: Bool
    let onTap: () -> Void

    private var borderStroke: LinearGradient {
        LinearGradient(
            colors: isSelected
                ? [Theme.goldBright.opacity(0.95), Theme.parchmentDeep.opacity(0.45)]
                : [Theme.parchmentDeep.opacity(0.26), Theme.ink.opacity(0.12)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var backgroundFill: LinearGradient {
        LinearGradient(
            colors: isSelected
                ? [Theme.gold.opacity(0.17), Theme.leatherLight.opacity(0.82)]
                : [Theme.parchment.opacity(0.06), Theme.leather.opacity(0.56)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Theme.bodyFont(size: 15))
                        .foregroundColor(Theme.parchment)

                    Text(detail)
                        .font(Theme.systemFont(size: 11, weight: .medium))
                        .foregroundColor(isSelected ? Theme.goldBright : Theme.inkFaded)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 8) {
                    Text(status)
                        .font(Theme.systemFont(size: 10, weight: .semibold))
                        .foregroundColor(isSelected ? Theme.ink : Theme.parchmentDark)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(
                            isSelected ? Theme.goldBright : Theme.parchment.opacity(0.08),
                            in: Capsule()
                        )

                    Image(systemName: isSelected ? "seal.fill" : "seal")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isSelected ? Theme.goldBright : Theme.inkFaded)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(backgroundFill, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderStroke, lineWidth: isSelected ? 1.4 : 1)
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(isSelected ? Theme.goldBright : .clear)
                    .frame(width: 4)
                    .padding(.vertical, 10)
                    .padding(.leading, 7)
            }
            .shadow(
                color: isSelected ? Theme.gold.opacity(0.12) : .clear,
                radius: 10,
                y: 5
            )
        }
        .buttonStyle(.plain)
    }
}

struct ResolutionDecisionCard: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var guidanceStore: GuidanceStore
    let onOpenReference: () -> Void
    var resistanceRollArmed: Bool = false
    var upcomingResistanceQueue: [PendingResistanceState] = []
    var onPrepareResistanceRoll: (() -> Void)? = nil
    var onCancelResistanceRoll: (() -> Void)? = nil
    var onAcceptResistance: (() -> Void)? = nil
    @State private var showingResistanceRoll = false

    private func resistanceAccent(for attribute: ResistanceAttribute) -> Color {
        switch attribute {
        case .insight:
            return Color(red: 0.45, green: 0.70, blue: 0.72)
        case .prowess:
            return Theme.dangerLight
        case .resolve:
            return Theme.goldBright
        }
    }

    private func poolInstruction(for resistance: PendingResistanceState) -> String {
        let pool = viewModel.pendingResistanceDicePool() ?? 0
        if pool > 0 {
            return "Roll \(pool)d6 in the tray and pay 6 minus the highest result in Stress."
        }
        return "Roll 2d6 in the tray, keep the lower die, and pay 6 minus that result in Stress."
    }

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
                let accent = resistanceAccent(for: resistance.attribute)
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 10) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(resistance.sequenceTotal > 1
                                 ? "Fallout \(resistance.sequenceIndex) of \(resistance.sequenceTotal)"
                                 : "Fallout")
                                .font(Theme.systemFont(size: 11, weight: .semibold))
                                .foregroundColor(accent)
                                .textCase(.uppercase)
                                .tracking(0.7)

                            Text(resistance.title)
                                .font(Theme.displayFont(size: 22))
                                .foregroundColor(Theme.parchment)
                        }

                        Spacer(minLength: 8)

                        Text("Resist with \(resistance.attribute.title)")
                            .font(Theme.systemFont(size: 11, weight: .semibold))
                            .foregroundColor(Theme.ink)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(accent, in: Capsule())
                    }

                    if let prompt = resistance.prompt {
                        Text(prompt)
                            .font(Theme.bodyFont(size: 15, italic: true))
                            .foregroundColor(Theme.parchment)
                    }

                    Text(resistance.summary)
                        .font(Theme.bodyFont(size: 13))
                        .foregroundColor(Theme.parchmentDark)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("If You Resist")
                            .font(Theme.systemFont(size: 11, weight: .semibold))
                            .foregroundColor(accent)
                            .textCase(.uppercase)
                            .tracking(0.6)

                        Text(resistance.resistPreview)
                            .font(Theme.bodyFont(size: 13))
                            .foregroundColor(Theme.parchmentDark)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(resistance.attribute.actionTypes.joined(separator: ", "))
                            .font(Theme.systemFont(size: 11))
                            .foregroundColor(Theme.inkFaded)

                        Text(poolInstruction(for: resistance))
                            .font(Theme.systemFont(size: 12))
                            .foregroundColor(Theme.parchmentDark)
                    }

                    if !upcomingResistanceQueue.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Still In The Queue")
                                .font(Theme.systemFont(size: 11, weight: .semibold))
                                .foregroundColor(Theme.inkFaded)
                                .textCase(.uppercase)
                                .tracking(0.6)

                            ForEach(Array(upcomingResistanceQueue.enumerated()), id: \.offset) { _, upcoming in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(upcoming.title)
                                        .font(Theme.systemFont(size: 12, weight: .semibold))
                                        .foregroundColor(Theme.parchment)
                                    Text(upcoming.summary)
                                        .font(Theme.bodyFont(size: 12))
                                        .foregroundColor(Theme.parchmentDark)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Theme.parchment.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }

                    if guidanceStore.shouldShow(.resistancePrompt) {
                        GuidanceHintCard(
                            hintID: .resistancePrompt,
                            title: "Resistance Trades Certainty For Stress",
                            message: "When a consequence appears, resisting can soften it or stop it entirely. Better rolls mean less Stress paid afterward.",
                            onDismiss: { guidanceStore.dismiss(.resistancePrompt) },
                            onOpenReference: onOpenReference
                        )
                    }

                    if onPrepareResistanceRoll != nil {
                        if resistanceRollArmed {
                            Text("Resistance is armed in the tray below.")
                                .font(Theme.systemFont(size: 12, weight: .semibold))
                                .foregroundColor(accent)

                            HStack(spacing: 12) {
                                Button("Cancel") {
                                    onCancelResistanceRoll?()
                                }
                                .font(Theme.systemFont(size: 13, weight: .semibold))
                                .foregroundColor(Theme.parchmentDark)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Theme.parchmentDeep.opacity(0.35), lineWidth: 1)
                                )

                                Button("Take It") {
                                    if let onAcceptResistance {
                                        onAcceptResistance()
                                    } else {
                                        _ = viewModel.acceptPendingResistance()
                                    }
                                }
                                .font(Theme.systemFont(size: 13, weight: .semibold))
                                .foregroundColor(Theme.parchmentDark)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Theme.parchmentDeep.opacity(0.35), lineWidth: 1)
                                )
                            }
                        } else {
                            HStack(spacing: 12) {
                                Button("Take It") {
                                    if let onAcceptResistance {
                                        onAcceptResistance()
                                    } else {
                                        _ = viewModel.acceptPendingResistance()
                                    }
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
                                    onPrepareResistanceRoll?()
                                }
                                .font(Theme.systemFont(size: 13, weight: .semibold))
                                .foregroundColor(Theme.ink)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(accent)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    } else {
                        if showingResistanceRoll {
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
                                .background(accent)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        } else {
                            HStack(spacing: 12) {
                                Button("Take It") {
                                    if let onAcceptResistance {
                                        onAcceptResistance()
                                    } else {
                                        _ = viewModel.acceptPendingResistance()
                                    }
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
                                .background(accent)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
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
    @ObservedObject var guidanceStore: GuidanceStore
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
    @State private var showOutcome = false
    @State private var showVignette = false
    @State private var showingQuickReference = false
    @State private var resistanceRollArmed = false
    @State private var recentResistanceVerdict: ResistanceVerdictState? = nil
    @State private var resistanceVerdictToken: UUID? = nil

    @StateObject private var diceController = SceneKitDiceController()

    @Environment(\.dismiss) var dismiss

    private func toggleModifier(_ info: SelectableModifierInfo) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
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
                let diceCount = proj.isActionBanned ? 0 : max(proj.finalDiceCount, 1)
                diceValues = Array(repeating: 1, count: diceCount)
            }
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

    private func clearTrayHighlights() {
        diceController.highlightDice(at: [], fadeOthers: false, isCritical: false)
    }

    private func highlightedIndices(
        for rolled: [Int],
        highlightedValue: Int,
        highlightAllMatches: Bool
    ) -> [Int] {
        let matches = rolled.enumerated()
            .filter { $0.element == highlightedValue }
            .map(\.offset)

        if highlightAllMatches {
            return matches.isEmpty ? [0] : matches
        }
        return matches.first.map { [$0] } ?? [0]
    }

    private func applyResolvedDice(
        _ rolled: [Int]?,
        highlightedValue: Int,
        highlightAllMatches: Bool = false,
        playCue: Bool = true
    ) {
        let highlightedDice: [Int]

        if let rolled, !rolled.isEmpty {
            diceValues = rolled
            highlightedDice = highlightedIndices(
                for: rolled,
                highlightedValue: highlightedValue,
                highlightAllMatches: highlightAllMatches
            )
        } else {
            let totalDice = max(diceValues.count, 1)
            let winningIndex = Int.random(in: 0..<totalDice)
            diceValues = (0..<totalDice).map { idx in
                if idx == winningIndex { return highlightedValue }
                return Int.random(in: 1...max(1, min(highlightedValue, 5)))
            }
            highlightedDice = [winningIndex]
        }

        let isCriticalHighlight = highlightAllMatches && highlightedDice.count > 1
        diceController.highlightDice(at: highlightedDice, fadeOthers: true, isCritical: isCriticalHighlight)
        if playCue {
            AudioManager.shared.play(sound: "sfx_ui_pop.wav")
        }
    }

    private func resistanceResolutionSummary(for resistance: PendingResistanceState) -> String {
        let cleaned = resistance.resistPreview
            .replacingOccurrences(of: "Resist:", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else { return "Consequence softened." }

        let lowered = cleaned.lowercased()
        if lowered.hasPrefix("avoid") {
            return "Consequence avoided."
        }
        if lowered.hasPrefix("reduce to") {
            let remainder = cleaned.dropFirst("reduce to".count).trimmingCharacters(in: .whitespacesAndNewlines)
            return "Reduced to \(remainder)"
        }
        if lowered.hasPrefix("reduce this") {
            return "Consequence reduced."
        }
        return cleaned.prefix(1).uppercased() + cleaned.dropFirst()
    }

    private func scheduleResistanceVerdictClear() {
        let token = UUID()
        resistanceVerdictToken = token
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
            guard resistanceVerdictToken == token else { return }
            withAnimation(.easeInOut(duration: 0.24)) {
                recentResistanceVerdict = nil
            }
            if let rolled = result?.actualDiceRolled {
                applyResolvedDice(
                    rolled,
                    highlightedValue: result?.highestRoll ?? rolled.max() ?? 1,
                    highlightAllMatches: result?.isCritical == true,
                    playCue: false
                )
            }
        }
    }

    private func handleActionRoll(results: [Int]) {
        let debugOverride = displayedProjection.flatMap { projection in
            viewModel.debugActionDiceOverride(rawPool: projection.rawDicePool)
        }
        let resolvedDice = debugOverride ?? results
        let rollResult = viewModel.performAction(for: action,
                                                 with: character,
                                                 interactableID: interactableID,
                                                 usingDice: resolvedDice,
                                                 chosenOptionalModifierIDs: Array(chosenModifierIDs))
        result = rollResult
        resistanceVerdictToken = nil
        recentResistanceVerdict = nil
        applyResolvedDice(
            rollResult.actualDiceRolled,
            highlightedValue: rollResult.highestRoll,
            highlightAllMatches: rollResult.isCritical == true
        )
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            showOutcome = true
        }
    }

    private func handleResistanceRoll(results: [Int]) {
        let resolvedResistance = activeResistance
        let debugOverride = viewModel.debugResistanceDiceOverride()
        let resolvedDice = debugOverride ?? results
        let resistanceOutcome = viewModel.resistPendingConsequence(usingDice: resolvedDice)

        if let resistanceOutcome, let resolvedResistance {
            applyResolvedDice(resistanceOutcome.diceRolled, highlightedValue: resistanceOutcome.highestRoll)
            recentResistanceVerdict = ResistanceVerdictState(
                attribute: resolvedResistance.attribute,
                title: resolvedResistance.title,
                sequenceLabel: resolvedResistance.sequenceTotal > 1
                    ? "Fallout \(resolvedResistance.sequenceIndex) of \(resolvedResistance.sequenceTotal)"
                    : "Fallout",
                highestRoll: resistanceOutcome.highestRoll,
                stressCost: resistanceOutcome.stressCost,
                resolutionSummary: resistanceResolutionSummary(for: resolvedResistance)
            )
            scheduleResistanceVerdictClear()
        } else {
            clearTrayHighlights()
            recentResistanceVerdict = nil
        }

        resistanceRollArmed = false
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            showOutcome = true
        }
    }

    private func stopShaking(results: [Int]) {
        AudioManager.shared.play(sound: "sfx_dice_land.wav")
        showVignette = false
        isRolling = false

        if resistanceRollArmed {
            handleResistanceRoll(results: results)
        } else {
            handleActionRoll(results: results)
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

    private func resistanceAccent(for attribute: ResistanceAttribute) -> Color {
        switch attribute {
        case .insight:
            return Color(red: 0.45, green: 0.70, blue: 0.72)
        case .prowess:
            return Theme.dangerLight
        case .resolve:
            return Theme.goldBright
        }
    }

    private var displayedConsequenceEntries: [String] {
        if let pending = viewModel.gameState.pendingResolution {
            return pending.resolvedDescriptions
        }
        let text = result?.consequences ?? ""
        return text
            .split(separator: "\n")
            .map(String.init)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private var canDismiss: Bool {
        viewModel.gameState.pendingResolution?.isAwaitingDecision != true && recentResistanceVerdict == nil
    }

    private var activeResistance: PendingResistanceState? {
        viewModel.gameState.pendingResolution?.pendingResistance
    }

    private var isAwaitingDecision: Bool {
        viewModel.gameState.pendingResolution?.isAwaitingDecision == true
    }

    private var upcomingResistanceQueue: [PendingResistanceState] {
        viewModel.pendingResistanceQueuePreview()
    }

    private var selectedModifierInfos: [SelectableModifierInfo] {
        availableOptionalModifiers.filter { chosenModifierIDs.contains($0.id) }
    }

    private var hasLoadedBoosts: Bool {
        !selectedModifierInfos.isEmpty
    }

    private var resistanceDiceCount: Int {
        let pool = viewModel.pendingResistanceDicePool() ?? 0
        return pool > 0 ? pool : 2
    }

    private var trayAccentColor: Color {
        if resistanceRollArmed, let activeResistance {
            return resistanceAccent(for: activeResistance.attribute)
        }
        if let recentResistanceVerdict {
            return resistanceAccent(for: recentResistanceVerdict.attribute)
        }
        if let result {
            return outcomeColor(for: result).opacity(0.55)
        }
        if hasLoadedBoosts {
            return Theme.gold.opacity(0.52)
        }
        return Theme.parchmentDeep.opacity(0.28)
    }

    private var resistanceInstructionText: String {
        let pool = viewModel.pendingResistanceDicePool() ?? 0
        if pool > 0 {
            return "Roll \(pool)d6 in the tray. Pay 6 minus the highest die in Stress."
        }
        return "Roll 2d6 in the tray, keep the lower die, and pay 6 minus that result in Stress."
    }

    private func armResistanceRoll() {
        guard activeResistance != nil else { return }
        resistanceRollArmed = true
        recentResistanceVerdict = nil
        resistanceVerdictToken = nil
        diceValues = Array(repeating: 1, count: max(resistanceDiceCount, 1))
        clearTrayHighlights()
    }

    private func cancelResistanceRoll() {
        resistanceRollArmed = false
        clearTrayHighlights()
        if let rolled = result?.actualDiceRolled {
            diceValues = rolled
            applyResolvedDice(
                rolled,
                highlightedValue: result?.highestRoll ?? rolled.max() ?? 1,
                highlightAllMatches: result?.isCritical == true
            )
        }
    }

    private func acceptActiveResistance() {
        resistanceRollArmed = false
        _ = viewModel.acceptPendingResistance()
    }

    private var isDisplayedActionBanned: Bool {
        displayedProjection?.isActionBanned == true
    }

    private func isHindranceNote(_ note: String) -> Bool {
        let lowered = note.lowercased()
        return lowered.contains("banned")
            || lowered.contains("cannot")
            || lowered.contains("taking lowest")
            || lowered.contains("0 rating")
            || lowered.contains("-")
    }

    private func cleanedProjectionNote(_ note: String) -> String {
        note
            .trimmingCharacters(in: CharacterSet(charactersIn: "()"))
            .replacingOccurrences(of: "  ", with: " ")
    }

    private var favorableProjectionNotes: [String] {
        guard let displayedProjection else { return [] }
        return displayedProjection.notes
            .filter { !isHindranceNote($0) }
            .map(cleanedProjectionNote)
    }

    private var hindranceProjectionNotes: [String] {
        guard let displayedProjection else { return [] }
        return displayedProjection.notes
            .filter(isHindranceNote)
            .map(cleanedProjectionNote)
    }

    private var blockedReasonText: String {
        hindranceProjectionNotes.first ?? "This action is currently unavailable."
    }

    private func boostStatusLabel(for info: SelectableModifierInfo) -> String {
        let trimmed = info.remainingUses.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmed.lowercased()
        if lowered.contains("cost") {
            return trimmed
        }
        if trimmed == "∞" {
            return "Reusable"
        }
        if let count = Int(trimmed) {
            return "\(count) use\(count == 1 ? "" : "s")"
        }
        return trimmed
    }

    @ViewBuilder
    private var titleSection: some View {
        if let result = result, showOutcome {
            VStack(spacing: 6) {
                Text(character.name)
                    .font(Theme.displayFont(size: 14))
                    .foregroundColor(Theme.parchmentDark)

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
                    Text("Impact: \(eff.rawValue.capitalized)")
                        .font(Theme.systemFont(size: 12))
                        .foregroundColor(Theme.inkFaded)
                }
            }
        } else {
            VStack(spacing: 8) {
                Text(character.name)
                    .font(Theme.displayFont(size: 14))
                    .foregroundColor(Theme.parchmentDark)

                Text("Attempting")
                    .font(Theme.systemFont(size: 12, weight: .semibold))
                    .foregroundColor(Theme.inkFaded)
                    .textCase(.uppercase)
                    .tracking(0.8)

                Text(action.name)
                    .font(Theme.displayFont(size: 26))
                    .foregroundColor(Theme.parchment)

                Text("\(action.actionType) \(character.actions[action.actionType] ?? 0)")
                    .font(Theme.systemFont(size: 12))
                    .foregroundColor(Theme.inkFaded)
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("rollForecastScreen")
        }
    }

    @ViewBuilder
    private var scrollSectionContent: some View {
        if result != nil, showOutcome {
            VStack(spacing: 14) {
                if recentResistanceVerdict == nil, isAwaitingDecision {
                    ResolutionDecisionCard(
                        viewModel: viewModel,
                        guidanceStore: guidanceStore,
                        onOpenReference: { showingQuickReference = true },
                        resistanceRollArmed: resistanceRollArmed,
                        upcomingResistanceQueue: upcomingResistanceQueue,
                        onPrepareResistanceRoll: armResistanceRoll,
                        onCancelResistanceRoll: cancelResistanceRoll,
                        onAcceptResistance: acceptActiveResistance
                    )
                } else if let recentResistanceVerdict {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Fallout Settling")
                            .font(Theme.systemFont(size: 11, weight: .semibold))
                            .foregroundColor(resistanceAccent(for: recentResistanceVerdict.attribute))
                            .textCase(.uppercase)
                            .tracking(0.7)

                        Text("The tray is resolving the resisted fallout before the next choice appears.")
                            .font(Theme.bodyFont(size: 14))
                            .foregroundColor(Theme.parchmentDark)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.leatherLight.opacity(0.48), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.parchmentDeep.opacity(0.18), lineWidth: 1)
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Aftermath")
                        .font(Theme.systemFont(size: 11, weight: .semibold))
                        .foregroundColor(Theme.inkFaded)
                        .textCase(.uppercase)
                        .tracking(0.7)

                    ResolutionAftermathView(
                        entries: displayedConsequenceEntries,
                        isDecisionPending: isAwaitingDecision || recentResistanceVerdict != nil
                    )
                }
            }
        } else if let proj = displayedProjection {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Forecast")
                                .font(Theme.systemFont(size: 11, weight: .semibold))
                                .foregroundColor(Theme.inkFaded)
                                .textCase(.uppercase)
                                .tracking(0.7)

                            Text(proj.isActionBanned ? "This action is currently blocked." : "Commit to the roll with the current risk and impact.")
                                .font(Theme.bodyFont(size: 14))
                                .foregroundColor(Theme.parchmentDark)
                        }

                        Spacer(minLength: 8)

                        InlineExplainerAffordance(label: "Risk / impact") {
                            showingQuickReference = true
                        }
                    }

                    HStack(alignment: .center, spacing: 12) {
                        Text(proj.isActionBanned ? "0d6" : "\(proj.finalDiceCount)d6")
                            .font(Theme.displayFont(size: 38))
                            .foregroundColor(proj.isActionBanned ? Theme.dangerLight : Theme.parchment)

                        Spacer(minLength: 12)

                        HStack(spacing: 8) {
                            DualLabelForecastChip(
                                title: "Risk",
                                value: proj.finalPosition.rawValue.capitalized,
                                accent: Theme.positionColor(proj.finalPosition)
                            )
                            .accessibilityIdentifier("forecastRiskChip")

                            DualLabelForecastChip(
                                title: "Impact",
                                value: proj.finalEffect.rawValue.capitalized,
                                accent: Theme.parchment
                            )
                            .accessibilityIdentifier("forecastImpactChip")
                        }
                    }

                    if proj.isActionBanned {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Blocked Right Now")
                                .font(Theme.systemFont(size: 11, weight: .semibold))
                                .foregroundColor(Theme.danger)
                                .textCase(.uppercase)
                                .tracking(0.6)

                            Text(blockedReasonText)
                                .font(Theme.bodyFont(size: 14))
                                .foregroundColor(Theme.parchmentDark)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.danger.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Theme.danger.opacity(0.24), lineWidth: 1)
                        )
                    }
                }
                .padding(14)
                .background(Theme.leatherLight.opacity(0.55), in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.parchmentDeep.opacity(0.2), lineWidth: 1)
                )
                .opacity(isRolling ? 0.7 : 1)

                if guidanceStore.shouldShow(.rollForecast) {
                    GuidanceHintCard(
                        hintID: .rollForecast,
                        title: "Read The Forecast Before You Commit",
                        message: "Risk tells you how hard the fallout can hit. Impact tells you how much a success is expected to accomplish.",
                        onDismiss: { guidanceStore.dismiss(.rollForecast) },
                        onOpenReference: { showingQuickReference = true }
                    )
                }

                if !availableOptionalModifiers.isEmpty && !isDisplayedActionBanned {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Optional Boosts")
                            .font(Theme.systemFont(size: 11, weight: .semibold))
                            .foregroundColor(Theme.gold)
                            .textCase(.uppercase)
                            .tracking(0.7)

                        ForEach(availableOptionalModifiers) { info in
                            OptionalBoostCard(
                                title: info.description,
                                detail: info.detailedEffect,
                                status: boostStatusLabel(for: info),
                                isSelected: chosenModifierIDs.contains(info.id),
                                onTap: { toggleModifier(info) }
                            )
                        }
                    }
                    .opacity(isRolling ? 0.68 : 1)
                }

                if !favorableProjectionNotes.isEmpty || !hindranceProjectionNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Why This Forecast Changed")
                            .font(Theme.systemFont(size: 11, weight: .semibold))
                            .foregroundColor(Theme.inkFaded)
                            .textCase(.uppercase)
                            .tracking(0.7)

                        if !favorableProjectionNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Helpful Factors")
                                    .font(Theme.systemFont(size: 11, weight: .semibold))
                                    .foregroundColor(Theme.success)
                                ForEach(favorableProjectionNotes, id: \.self) { note in
                                    Text(note)
                                        .font(Theme.bodyFont(size: 13))
                                        .foregroundColor(Theme.parchmentDark)
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.success.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                        }

                        if !hindranceProjectionNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Hindrances")
                                    .font(Theme.systemFont(size: 11, weight: .semibold))
                                    .foregroundColor(Theme.dangerLight)
                                ForEach(hindranceProjectionNotes, id: \.self) { note in
                                    Text(note)
                                        .font(Theme.bodyFont(size: 13))
                                        .foregroundColor(Theme.parchmentDark)
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.danger.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .opacity(isRolling ? 0.68 : 1)
                }
            }
        }
    }

    @ViewBuilder
    private var stageHeaderContent: some View {
        if let recentResistanceVerdict {
            ResistanceVerdictCard(verdict: recentResistanceVerdict)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        } else if resistanceRollArmed, let activeResistance {
            VStack(alignment: .leading, spacing: 5) {
                Text("Resistance Roll")
                    .font(Theme.systemFont(size: 11, weight: .semibold))
                    .foregroundColor(resistanceAccent(for: activeResistance.attribute))
                    .textCase(.uppercase)
                    .tracking(0.7)

                Text(resistanceInstructionText)
                    .font(Theme.bodyFont(size: 14))
                    .foregroundColor(Theme.parchmentDark)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else if result != nil, isAwaitingDecision {
            Text("Resolve the fallout above. If you resist, the tray will arm here.")
                .font(Theme.bodyFont(size: 13, italic: true))
                .foregroundColor(Theme.inkFaded)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var trayView: some View {
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
                .stroke(
                    trayAccentColor.opacity(0.35),
                    lineWidth: (resistanceRollArmed || recentResistanceVerdict != nil) ? 1.8 : 1
                )

            RoundedRectangle(cornerRadius: 13)
                .fill(Theme.bg.opacity(0.82))
                .padding(8)

            SceneKitDiceView(
                controller: diceController,
                diceCount: diceValues.count,
                pushedDice: pushedDiceCount
            )
            .clipShape(RoundedRectangle(cornerRadius: 11))
            .padding(10)

            RoundedRectangle(cornerRadius: 11)
                .stroke(
                    trayAccentColor.opacity((resistanceRollArmed || recentResistanceVerdict != nil) ? 0.8 : 0.55),
                    lineWidth: (resistanceRollArmed || recentResistanceVerdict != nil) ? 1.6 : 1.2
                )
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
                        colors: [trayAccentColor.opacity(0.65), Theme.ink.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: (resistanceRollArmed || recentResistanceVerdict != nil) ? 1.4 : 1
                )
                .padding(8)
        }
        .frame(height: 248)
        .shadow(color: .black.opacity(0.35), radius: 10, y: 6)
    }

    @ViewBuilder
    private var stageFooterContent: some View {
        if result == nil {
            if let projection = displayedProjection,
               !projection.isActionBanned,
               let debugDice = viewModel.debugActionDiceOverride(rawPool: projection.rawDicePool) {
                Text("Debug fixed roll: \(debugDice.map(String.init).joined(separator: ", "))")
                    .font(Theme.systemFont(size: 11))
                    .foregroundColor(Theme.goldDim)
            }

            let canRoll = !isDisplayedActionBanned && !isRolling && diceController.isViewportReady && !diceValues.isEmpty
            Button {
                guard canRoll else { return }
                isRolling = true
                startShaking()
                diceController.rollDice()
            } label: {
                HStack(spacing: 8) {
                    if isDisplayedActionBanned {
                        Image(systemName: "lock.fill")
                    }
                    Text(isDisplayedActionBanned ? "Action Banned" : "Roll the Dice")
                }
                .font(Theme.displayFont(size: 18))
                .foregroundColor(isDisplayedActionBanned ? Theme.parchmentDark : Theme.ink)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: isDisplayedActionBanned
                            ? [Theme.inkFaded.opacity(0.55), Theme.inkFaded.opacity(0.35)]
                            : [Theme.gold, Theme.goldDim],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(
                    color: isDisplayedActionBanned ? .clear : Theme.gold.opacity(0.3),
                    radius: 12,
                    y: 4
                )
            }
            .disabled(!canRoll)
            .opacity(canRoll ? 1 : 0.55)
            .accessibilityIdentifier("rollDiceButton")
        } else if resistanceRollArmed {
            let canRollResistance = !isRolling && diceController.isViewportReady && !diceValues.isEmpty

            if let debugResistance = viewModel.debugResistanceDiceOverride() {
                Text("Debug resistance roll: \(debugResistance.map(String.init).joined(separator: ", "))")
                    .font(Theme.systemFont(size: 11))
                    .foregroundColor(Theme.goldDim)
            }

            Button {
                guard canRollResistance else { return }
                isRolling = true
                startShaking()
                diceController.rollDice()
            } label: {
                Text("Roll Resistance")
                    .font(Theme.displayFont(size: 18))
                    .foregroundColor(Theme.ink)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [trayAccentColor, trayAccentColor.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(
                        color: trayAccentColor.opacity(0.3),
                        radius: 12,
                        y: 4
                    )
            }
            .disabled(!canRollResistance)
            .opacity(canRollResistance ? 1 : 0.55)
            .accessibilityIdentifier("rollResistanceButton")
        } else if recentResistanceVerdict != nil {
            Text("The fallout settles...")
                .font(Theme.systemFont(size: 12, weight: .semibold))
                .foregroundColor(Theme.parchmentDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        } else if isAwaitingDecision {
            Text("Choose how to resolve the fallout above.")
                .font(Theme.systemFont(size: 12, weight: .semibold))
                .foregroundColor(Theme.parchmentDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
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

    private var pinnedRollStage: some View {
        VStack(spacing: 14) {
            stageHeaderContent
            trayView
            stageFooterContent
        }
        .padding(.horizontal, 30)
        .padding(.top, 14)
        .padding(.bottom, 16)
        .background(
            LinearGradient(
                colors: [Theme.bg.opacity(0.28), Theme.bgWarm.opacity(0.98)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .top) {
            Theme.InkDivider()
                .opacity(0.55)
        }
    }

    var body: some View {
        ZStack {
            Theme.dramaticBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    HStack {
                        Spacer()

                        Button {
                            guard canDismiss else { return }
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(canDismiss ? Theme.parchmentDark : Theme.inkFaded)
                        }
                        .buttonStyle(.plain)
                        .disabled(!canDismiss)
                        .accessibilityIdentifier("closeDiceRollViewButton")
                    }

                    titleSection
                    scrollSectionContent
                }
                .padding(30)
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("diceRollView")
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            pinnedRollStage
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
            let diceCount = context.baseProjection.isActionBanned ? 0 : max(context.baseProjection.finalDiceCount, 1)
            self.diceValues = Array(repeating: 1, count: diceCount)
            diceController.onDiceSettled = { results in
                self.stopShaking(results: results)
            }
        }
        .onChange(of: viewModel.gameState.pendingResolution?.pendingResistance?.summary) { _ in
            resistanceRollArmed = false
            if !isAwaitingDecision {
                resistanceVerdictToken = nil
                recentResistanceVerdict = nil
            }
        }
        .onChange(of: viewModel.gameState.pendingResolution?.pendingChoice?.options.count) { _ in
            resistanceRollArmed = false
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
        .sheet(isPresented: $showingQuickReference) {
            QuickReferenceSheetView()
                .presentationDetents([.medium, .large])
        }
    }
}
