import Foundation

struct ResolvedDiceRoll {
    let actualDiceRolled: [Int]
    let highestRoll: Int
    let isCritical: Bool
}

struct RollRulesEngine {
    static let pushYourselfModifierID = UUID(uuidString: "0F2B2A84-7027-4B8A-ABEB-0CEB6A46E50D")!
    static let devilsBargainModifierID = UUID(uuidString: "7159DB20-98EC-4DFE-945B-02A8B25D07D7")!
    private let basePushStressCost = 2

    func makePushYourselfModifier() -> Modifier {
        Modifier(
            id: Self.pushYourselfModifierID,
            bonusDice: 1,
            uses: 1,
            isOptionalToApply: true,
            description: "Push Yourself"
        )
    }

    func makeDevilsBargainModifier(title: String) -> Modifier {
        Modifier(
            id: Self.devilsBargainModifierID,
            bonusDice: 1,
            uses: -1,
            isOptionalToApply: true,
            description: title
        )
    }

    func calculateProjection(
        for action: ActionOption,
        with character: Character,
        interactableTags tags: [String] = [],
        environmentModifiers: [Modifier] = [],
        harmFamilies: [String: HarmFamily]
    ) -> RollProjectionDetails {
        var diceCount = character.actions[action.actionType] ?? 0
        var position = action.position
        var effect = action.effect
        let baseDice = diceCount
        let basePosition = position
        let baseEffect = effect
        var notes: [String] = []
        var isActionBanned = false

        for harm in character.harm.lesser {
            apply(harm: harm, tier: \.lesser, actionType: action.actionType, tags: tags, harmFamilies: harmFamilies, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes, isActionBanned: &isActionBanned)
        }
        for harm in character.harm.moderate {
            apply(harm: harm, tier: \.moderate, actionType: action.actionType, tags: tags, harmFamilies: harmFamilies, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes, isActionBanned: &isActionBanned)
        }
        for harm in character.harm.severe {
            apply(harm: harm, tier: \.severe, actionType: action.actionType, tags: tags, harmFamilies: harmFamilies, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes, isActionBanned: &isActionBanned)
        }

        if !isActionBanned {
            for modifier in character.modifiers + environmentModifiers {
                guard modifier.uses != 0 else { continue }
                guard applies(modifier: modifier, to: action.actionType, tags: tags) else { continue }

                if modifier.bonusDice != 0 {
                    diceCount += modifier.bonusDice
                    var note = "(\(formattedDiceDelta(modifier.bonusDice)) \(modifier.description)"
                    if modifier.uses > 0 {
                        note += " (\(modifier.uses) use\(modifier.uses == 1 ? "" : "s") left)"
                    }
                    if modifier.uses == 1 {
                        note += " - will be consumed"
                    }
                    note += ")"
                    notes.append(note)
                }

                if modifier.improvePosition {
                    position = position.improved()
                    var note = "(Improved Position from \(modifier.description)"
                    if modifier.uses > 0 {
                        note += " (\(modifier.uses) use\(modifier.uses == 1 ? "" : "s") left)"
                    }
                    if modifier.uses == 1 {
                        note += " - will be consumed"
                    }
                    note += ")"
                    notes.append(note)
                }

                if modifier.improveEffect {
                    effect = effect.increased()
                    var note = "(+1 Effect from \(modifier.description)"
                    if modifier.uses > 0 {
                        note += " (\(modifier.uses) use\(modifier.uses == 1 ? "" : "s") left)"
                    }
                    if modifier.uses == 1 {
                        note += " - will be consumed"
                    }
                    note += ")"
                    notes.append(note)
                }
            }
        }

        if action.isGroupAction {
            notes.append("Group Action: everyone here can join; best result counts. The tray is your lead roll.")
        }

        let rawDicePool = isActionBanned ? 0 : diceCount
        diceCount = isActionBanned ? 0 : max(diceCount, 0)

        if baseDice == 0 && !isActionBanned {
            notes.append("\(character.name) has 0 rating in \(action.actionType): Rolling 2d6, taking lowest.")
        }

        let displayDice = isActionBanned ? 0 : ((baseDice == 0) ? 2 : diceCount)

        return RollProjectionDetails(
            baseDiceCount: baseDice,
            finalDiceCount: displayDice,
            rawDicePool: rawDicePool,
            basePosition: basePosition,
            finalPosition: position,
            baseEffect: baseEffect,
            finalEffect: effect,
            notes: notes,
            isActionBanned: isActionBanned
        )
    }

    func getRollContext(
        for action: ActionOption,
        with character: Character,
        interactableTags tags: [String] = [],
        environmentModifiers: [Modifier] = [],
        harmFamilies: [String: HarmFamily]
    ) -> (baseProjection: RollProjectionDetails, optionalModifiers: [SelectableModifierInfo]) {
        let initialProjection = projectionAfterHarms(
            for: action,
            with: character,
            interactableTags: tags,
            harmFamilies: harmFamilies
        )
        var diceCount = initialProjection.rawDicePool
        var position = initialProjection.finalPosition
        var effect = initialProjection.finalEffect
        let baseDice = initialProjection.baseDiceCount
        let basePosition = initialProjection.basePosition
        let baseEffect = initialProjection.baseEffect
        var notes = initialProjection.notes
        let isActionBanned = initialProjection.isActionBanned
        let availableModifiers = uniqueModifiers(for: character, environmentModifiers: environmentModifiers)

        if !isActionBanned {
            for modifier in availableModifiers {
                guard modifier.uses != 0 else { continue }
                guard !modifier.isOptionalToApply else { continue }
                guard applies(modifier: modifier, to: action.actionType, tags: tags) else { continue }

                if modifier.bonusDice != 0 {
                    diceCount += modifier.bonusDice
                    notes.append("(\(formattedDiceDelta(modifier.bonusDice)) \(modifier.description))")
                }
                if modifier.improvePosition {
                    position = position.improved()
                    notes.append("(Improved Position from \(modifier.description))")
                }
                if modifier.improveEffect {
                    effect = effect.increased()
                    notes.append("(+1 Effect from \(modifier.description))")
                }
            }
        }

        let rawDicePool = isActionBanned ? 0 : diceCount
        diceCount = isActionBanned ? 0 : max(diceCount, 0)
        if baseDice == 0 && !isActionBanned {
            notes.append("\(character.name) has 0 rating in \(action.actionType): Rolling 2d6, taking lowest.")
        }

        let displayDice = isActionBanned ? 0 : ((baseDice == 0) ? 2 : diceCount)
        let projection = RollProjectionDetails(
            baseDiceCount: baseDice,
            finalDiceCount: displayDice,
            rawDicePool: rawDicePool,
            basePosition: basePosition,
            finalPosition: position,
            baseEffect: baseEffect,
            finalEffect: effect,
            notes: notes,
            isActionBanned: isActionBanned
        )

        var optionalInfos: [SelectableModifierInfo] = []
        if !isActionBanned {
            for modifier in uniqueModifiers(for: character) {
                guard modifier.isOptionalToApply else { continue }
                guard modifier.uses != 0 else { continue }
                guard applies(modifier: modifier, to: action.actionType, tags: tags) else { continue }

                var effects: [String] = []
                if modifier.bonusDice != 0 {
                    effects.append("+\(modifier.bonusDice)d")
                }
                if modifier.improvePosition {
                    effects.append("Improves Position")
                }
                if modifier.improveEffect {
                    effects.append("+1 Effect")
                }

                optionalInfos.append(
                    SelectableModifierInfo(
                        id: modifier.id,
                        description: modifier.description,
                        detailedEffect: effects.joined(separator: ", "),
                        remainingUses: modifier.uses > 0 ? "\(modifier.uses)" : "∞",
                        modifierData: modifier
                    )
                )
            }

            let pushCost = pushStressCost(for: character, interactableTags: tags, harmFamilies: harmFamilies)
            if character.stress + pushCost <= 9 {
                let pushModifier = makePushYourselfModifier()
                optionalInfos.append(
                    SelectableModifierInfo(
                        id: pushModifier.id,
                        description: "Push Yourself",
                        detailedEffect: "+1d",
                        remainingUses: "Costs \(pushCost) Stress",
                        modifierData: pushModifier
                    )
                )
            }

            if let bargain = action.devilsBargain {
                optionalInfos.append(
                    SelectableModifierInfo(
                        id: Self.devilsBargainModifierID,
                        description: bargain.title,
                        detailedEffect: "+1d",
                        remainingUses: bargain.description,
                        modifierData: makeDevilsBargainModifier(title: bargain.title)
                    )
                )
            }

            optionalInfos.sort { lhs, rhs in
                if lhs.id == Self.pushYourselfModifierID { return true }
                if rhs.id == Self.pushYourselfModifierID { return false }
                if lhs.id == Self.devilsBargainModifierID { return true }
                if rhs.id == Self.devilsBargainModifierID { return false }
                return lhs.description.localizedCaseInsensitiveCompare(rhs.description) == .orderedAscending
            }
        }

        return (projection, optionalInfos)
    }

    func materiallyAffectingAutomaticModifierIDs(
        for action: ActionOption,
        with character: Character,
        interactableTags tags: [String] = [],
        harmFamilies: [String: HarmFamily]
    ) -> Set<UUID> {
        var workingProjection = projectionAfterHarms(
            for: action,
            with: character,
            interactableTags: tags,
            harmFamilies: harmFamilies
        )
        guard !workingProjection.isActionBanned else { return [] }

        var affectingIDs: Set<UUID> = []
        for modifier in uniqueModifiers(for: character) {
            guard modifier.uses > 0 else { continue }
            guard !modifier.isOptionalToApply else { continue }
            guard applies(modifier: modifier, to: action.actionType, tags: tags) else { continue }

            let nextProjection = calculateEffectiveProjection(
                baseProjection: workingProjection,
                applying: [modifier]
            )

            if nextProjection.rawDicePool != workingProjection.rawDicePool ||
                nextProjection.finalPosition != workingProjection.finalPosition ||
                nextProjection.finalEffect != workingProjection.finalEffect {
                affectingIDs.insert(modifier.id)
            }

            workingProjection = nextProjection
        }

        return affectingIDs
    }

    func calculateEffectiveProjection(baseProjection: RollProjectionDetails, applying chosenModifierStructs: [Modifier]) -> RollProjectionDetails {
        var result = baseProjection
        if result.isActionBanned {
            result.rawDicePool = 0
            result.finalDiceCount = 0
            return result
        }
        for modifier in chosenModifierStructs {
            if modifier.bonusDice != 0 {
                result.rawDicePool += modifier.bonusDice
                result.notes.append("(+\(modifier.bonusDice)d from \(modifier.description))")
            }
            if modifier.improvePosition {
                result.finalPosition = result.finalPosition.improved()
                result.notes.append("(Improved Position from \(modifier.description))")
            }
            if modifier.improveEffect {
                result.finalEffect = result.finalEffect.increased()
                result.notes.append("(+1 Effect from \(modifier.description))")
            }
        }

        if baseProjection.baseDiceCount == 0 {
            result.finalDiceCount = result.rawDicePool > 0 ? result.rawDicePool : 2
        } else {
            result.finalDiceCount = max(result.rawDicePool, 0)
        }

        return result
    }

    func pushStressCost(
        for character: Character,
        interactableTags tags: [String],
        harmFamilies: [String: HarmFamily]
    ) -> Int {
        var additionalCost = 0
        additionalCost += additionalStressCost(from: character.harm.lesser, tier: \.lesser, interactableTags: tags, harmFamilies: harmFamilies)
        additionalCost += additionalStressCost(from: character.harm.moderate, tier: \.moderate, interactableTags: tags, harmFamilies: harmFamilies)
        additionalCost += additionalStressCost(from: character.harm.severe, tier: \.severe, interactableTags: tags, harmFamilies: harmFamilies)
        return max(0, basePushStressCost + additionalCost)
    }

    func resolveRoll(using providedResults: [Int]?, rawPool: Int) -> ResolvedDiceRoll {
        let usesZeroRatingRule = rawPool <= 0
        let dicePool = usesZeroRatingRule ? 2 : rawPool

        if let providedResults {
            if usesZeroRatingRule {
                if providedResults.count >= 2 {
                    let highestRoll = min(providedResults[0], providedResults[1])
                    let isCritical = providedResults[0] == 6 && providedResults[1] == 6
                    return ResolvedDiceRoll(actualDiceRolled: providedResults, highestRoll: highestRoll, isCritical: isCritical)
                }
                return ResolvedDiceRoll(actualDiceRolled: providedResults, highestRoll: providedResults.min() ?? 0, isCritical: false)
            }

            let highestRoll = providedResults.max() ?? 0
            let isCritical = providedResults.filter { $0 == 6 }.count > 1
            return ResolvedDiceRoll(actualDiceRolled: providedResults, highestRoll: highestRoll, isCritical: isCritical)
        }

        if usesZeroRatingRule {
            let dieOne = Int.random(in: 1...6)
            let dieTwo = Int.random(in: 1...6)
            return ResolvedDiceRoll(
                actualDiceRolled: [dieOne, dieTwo],
                highestRoll: min(dieOne, dieTwo),
                isCritical: dieOne == 6 && dieTwo == 6
            )
        }

        var rolled: [Int] = []
        for _ in 0..<dicePool {
            rolled.append(Int.random(in: 1...6))
        }
        let highestRoll = rolled.max() ?? 0
        let isCritical = rolled.filter { $0 == 6 }.count > 1
        return ResolvedDiceRoll(actualDiceRolled: rolled, highestRoll: highestRoll, isCritical: isCritical)
    }

    func outcome(for highestRoll: Int) -> (label: String, outcome: RollOutcome) {
        switch highestRoll {
        case 6:
            return ("Full Success!", .success)
        case 4...5:
            return ("Partial Success...", .partial)
        default:
            return ("Failure.", .failure)
        }
    }

    private func additionalStressCost(
        from harms: [(familyId: String, description: String)],
        tier: KeyPath<HarmFamily, HarmTier>,
        interactableTags tags: [String],
        harmFamilies: [String: HarmFamily]
    ) -> Int {
        var total = 0

        for harm in harms {
            guard let family = harmFamilies[harm.familyId] else { continue }
            guard let penalty = family[keyPath: tier].penalty else { continue }
            guard case .increaseStressCost(let amount, let requiredTag) = penalty else { continue }
            if let requiredTag, !tags.contains(requiredTag) {
                continue
            }
            total += amount
        }

        return total
    }

    private func projectionAfterHarms(
        for action: ActionOption,
        with character: Character,
        interactableTags tags: [String],
        harmFamilies: [String: HarmFamily]
    ) -> RollProjectionDetails {
        var diceCount = character.actions[action.actionType] ?? 0
        var position = action.position
        var effect = action.effect
        let baseDice = diceCount
        let basePosition = position
        let baseEffect = effect
        var notes: [String] = []
        var isActionBanned = false

        for harm in character.harm.lesser {
            apply(harm: harm, tier: \.lesser, actionType: action.actionType, tags: tags, harmFamilies: harmFamilies, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes, isActionBanned: &isActionBanned)
        }
        for harm in character.harm.moderate {
            apply(harm: harm, tier: \.moderate, actionType: action.actionType, tags: tags, harmFamilies: harmFamilies, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes, isActionBanned: &isActionBanned)
        }
        for harm in character.harm.severe {
            apply(harm: harm, tier: \.severe, actionType: action.actionType, tags: tags, harmFamilies: harmFamilies, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes, isActionBanned: &isActionBanned)
        }

        let rawDicePool = isActionBanned ? 0 : diceCount
        let finalDiceCount: Int
        if isActionBanned {
            finalDiceCount = 0
        } else if baseDice == 0 {
            finalDiceCount = 2
        } else {
            finalDiceCount = max(diceCount, 0)
        }

        return RollProjectionDetails(
            baseDiceCount: baseDice,
            finalDiceCount: finalDiceCount,
            rawDicePool: rawDicePool,
            basePosition: basePosition,
            finalPosition: position,
            baseEffect: baseEffect,
            finalEffect: effect,
            notes: notes,
            isActionBanned: isActionBanned
        )
    }

    private func uniqueModifiers(
        for character: Character,
        environmentModifiers: [Modifier] = []
    ) -> [Modifier] {
        var seenIDs: Set<UUID> = []
        var result: [Modifier] = []

        for modifier in character.modifiers + character.treasures.map(\.grantedModifier) + environmentModifiers {
            if seenIDs.insert(modifier.id).inserted {
                result.append(modifier)
            }
        }

        return result
    }

    private func formattedDiceDelta(_ amount: Int) -> String {
        amount > 0 ? "+\(amount)d" : "\(amount)d"
    }

    private func apply(
        harm: (familyId: String, description: String),
        tier: KeyPath<HarmFamily, HarmTier>,
        actionType: String,
        tags: [String],
        harmFamilies: [String: HarmFamily],
        diceCount: inout Int,
        position: inout RollPosition,
        effect: inout RollEffect,
        notes: inout [String],
        isActionBanned: inout Bool
    ) {
        if let penalty = harmFamilies[harm.familyId]?[keyPath: tier].penalty {
            apply(penalty: penalty, description: harm.description, to: actionType, tags: tags, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes, isActionBanned: &isActionBanned)
        }
        if !isActionBanned, let boon = harmFamilies[harm.familyId]?[keyPath: tier].boon {
            apply(boon: boon, description: harm.description, to: actionType, tags: tags, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes)
        }
    }

    private func applies(modifier: Modifier, to actionType: String, tags: [String]) -> Bool {
        if let actions = modifier.applicableActions {
            guard actions.contains(actionType) else { return false }
        } else if let specificAction = modifier.applicableToAction, specificAction != actionType {
            return false
        }

        if let requiredTag = modifier.requiredTag, !tags.contains(requiredTag) {
            return false
        }

        return true
    }

    private func apply(
        penalty: Penalty,
        description: String,
        to actionType: String,
        tags: [String],
        diceCount: inout Int,
        position: inout RollPosition,
        effect: inout RollEffect,
        notes: inout [String],
        isActionBanned: inout Bool
    ) {
        switch penalty {
        case .reduceEffect(let requiredTag):
            if let requiredTag, !tags.contains(requiredTag) {
                break
            }
            effect = effect.decreased()
            notes.append("(-1 Effect from \(description))")
        case .actionPenalty(let penalizedAction, let requiredTag) where penalizedAction == actionType:
            if let requiredTag, !tags.contains(requiredTag) {
                break
            }
            diceCount -= 1
            notes.append("(-1d from \(description))")
        case .banAction(let bannedAction, let requiredTag) where bannedAction == actionType:
            if let requiredTag, !tags.contains(requiredTag) {
                break
            }
            isActionBanned = true
            diceCount = 0
            notes.append("(Action banned by \(description))")
        case .actionPositionPenalty(let penalizedAction, let requiredTag) where penalizedAction == actionType:
            if let requiredTag, !tags.contains(requiredTag) {
                break
            }
            position = position.decreased()
            notes.append("(-Position from \(description))")
        case .actionEffectPenalty(let penalizedAction, let requiredTag) where penalizedAction == actionType:
            if let requiredTag, !tags.contains(requiredTag) {
                break
            }
            effect = effect.decreased()
            notes.append("(-Effect from \(description))")
        default:
            break
        }
    }

    private func apply(
        boon: Modifier,
        description: String,
        to actionType: String,
        tags: [String],
        diceCount: inout Int,
        position: inout RollPosition,
        effect: inout RollEffect,
        notes: inout [String]
    ) {
        guard applies(modifier: boon, to: actionType, tags: tags) else { return }

        if boon.bonusDice != 0 {
            diceCount += boon.bonusDice
            notes.append("(+\(boon.bonusDice)d from \(description))")
        }
        if boon.improvePosition {
            position = position.improved()
            notes.append("(Improved Position from \(description))")
        }
        if boon.improveEffect {
            effect = effect.increased()
            notes.append("(+1 Effect from \(description))")
        }
    }
}

struct ActionResolver {
    private struct PreparedRollError: Error {
        let message: String
    }

    private struct PreparedRollState {
        let currentCharacter: Character
        let interactableTags: [String]
        let projection: RollProjectionDetails
        let consumedMessages: [String]
        let bargainConsequences: [Consequence]
    }

    private let runtime: ScenarioRuntime
    private let rollRules: RollRulesEngine
    private let pendingResolutionDriver: PendingResolutionDriver

    private var harmFamilies: [String: HarmFamily] {
        runtime.content.harmFamilyDict
    }

    init(
        runtime: ScenarioRuntime,
        rollRules: RollRulesEngine,
        debugLogging: Bool
    ) {
        self.runtime = runtime
        self.rollRules = rollRules
        self.pendingResolutionDriver = PendingResolutionDriver(
            runtime: runtime,
            debugLogging: debugLogging
        )
    }

    @discardableResult
    func performFreeAction(
        for action: ActionOption,
        with character: Character,
        interactableID: String?,
        in gameState: inout GameState
    ) -> String {
        guard let currentCharacter = currentCharacter(for: character.id, in: gameState) else {
            return "Character not found."
        }

        let tags = interactableTags(
            for: currentCharacter.id,
            interactableID: interactableID,
            in: gameState
        )
        let projection = rollRules.calculateProjection(
            for: action,
            with: currentCharacter,
            interactableTags: tags,
            harmFamilies: harmFamilies
        )
        let consequences = action.outcomes[.success] ?? []
        let context = ConsequenceContext(
            characterID: currentCharacter.id,
            interactableID: interactableID,
            finalEffect: projection.finalEffect,
            finalPosition: projection.finalPosition,
            isCritical: false
        )
        return pendingResolutionDriver.processConsequences(
            consequences,
            context: context,
            source: .freeAction,
            rollPresentation: nil,
            in: &gameState
        )
    }

    func performAction(
        for action: ActionOption,
        with character: Character,
        interactableID: String?,
        usingDice diceResults: [Int]? = nil,
        chosenOptionalModifierIDs: [UUID] = [],
        partyMovementMode: PartyMovementMode,
        groupRolls: [[Int]]? = nil,
        in gameState: inout GameState
    ) -> DiceRollResult {
        guard let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) else {
            return errorResult("Character not found.")
        }

        let preparedRollResult = prepareRollState(
            for: action,
            characterIndex: charIndex,
            interactableID: interactableID,
            chosenOptionalModifierIDs: chosenOptionalModifierIDs,
            in: &gameState
        )

        let prepared: PreparedRollState
        switch preparedRollResult {
        case .success(let preparedState):
            prepared = preparedState
        case .failure(let error):
            return cannotResult(error.message)
        }

        if action.isGroupAction {
            _ = partyMovementMode
            let providedGroupRolls = groupRolls ?? (diceResults.map { [$0] })
            return performGroupAction(
                for: action,
                leaderIndex: charIndex,
                leaderState: prepared,
                interactableID: interactableID,
                groupRolls: providedGroupRolls,
                in: &gameState
            )
        }

        var finalEffect = prepared.projection.finalEffect
        let finalPosition = prepared.projection.finalPosition
        let resolvedRoll = rollRules.resolveRoll(
            using: diceResults,
            rawPool: prepared.projection.rawDicePool
        )
        let outcome = rollRules.outcome(for: resolvedRoll.highestRoll)
        let highestRoll = resolvedRoll.highestRoll
        let isCritical = resolvedRoll.isCritical
        let actualDiceRolled = resolvedRoll.actualDiceRolled
        var consequencesDescription = ""

        if isCritical && highestRoll >= 4 {
            finalEffect = finalEffect.increased()
        }

        let eligibleConsequences = eligibleConsequences(
            for: action,
            baseOutcome: outcome.outcome,
            character: prepared.currentCharacter,
            finalEffect: finalEffect,
            finalPosition: finalPosition,
            isCritical: isCritical && highestRoll >= 4,
            gameState: gameState
        ) + prepared.bargainConsequences
        let consequenceContext = ConsequenceContext(
            characterID: prepared.currentCharacter.id,
            interactableID: interactableID,
            finalEffect: finalEffect,
            finalPosition: finalPosition,
            isCritical: isCritical
        )
        let rollPresentation = PendingRollPresentation(
            characterID: prepared.currentCharacter.id,
            actionName: action.name,
            highestRoll: highestRoll,
            outcome: outcome.label,
            actualDiceRolled: actualDiceRolled,
            isCritical: isCritical,
            finalEffect: finalEffect
        )
        consequencesDescription = pendingResolutionDriver.processConsequences(
            eligibleConsequences,
            context: consequenceContext,
            source: .roll,
            rollPresentation: rollPresentation,
            in: &gameState
        )

        if isCritical && highestRoll >= 4 {
            let criticalMessage = "Critical Success! Effect increased to \(finalEffect.rawValue.capitalized)."
            consequencesDescription = appendLine(
                criticalMessage,
                to: consequencesDescription
            )
            appendToPendingResolutionLog(criticalMessage, in: &gameState)
        }

        if !prepared.consumedMessages.isEmpty {
            AudioManager.shared.play(sound: "sfx_modifier_consume.wav")
            let consumedText = prepared.consumedMessages.joined(separator: "\n")
            consequencesDescription = appendLine(
                consumedText,
                to: consequencesDescription
            )
            appendToPendingResolutionLog(consumedText, in: &gameState)
        }

        return DiceRollResult(
            highestRoll: highestRoll,
            outcome: outcome.label,
            consequences: consequencesDescription,
            actualDiceRolled: actualDiceRolled,
            isCritical: isCritical,
            finalEffect: finalEffect,
            isAwaitingDecision: gameState.pendingResolution?.isAwaitingDecision == true
        )
    }

    func pushYourself(
        for character: Character,
        in gameState: inout GameState
    ) {
        guard let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) else { return }
        let pushCost = rollRules.pushStressCost(
            for: gameState.party[charIndex],
            interactableTags: [],
            harmFamilies: harmFamilies
        )
        gameState.party[charIndex].stress += pushCost
        _ = pendingResolutionDriver.checkStressOverflow(
            for: charIndex,
            in: &gameState
        )
    }

    private func performGroupAction(
        for action: ActionOption,
        leaderIndex: Int,
        leaderState: PreparedRollState,
        interactableID: String?,
        groupRolls: [[Int]]?,
        in gameState: inout GameState
    ) -> DiceRollResult {
        let participants = groupActionParticipants(
            for: leaderState.currentCharacter.id,
            action: action,
            interactableTags: leaderState.interactableTags,
            in: gameState
        )

        guard !participants.isEmpty else {
            return cannotResult("No one here can support that group action.")
        }

        var bestRoll = 0
        var supportingFailures = 0
        var isCritical = false
        var rollIndex = 0
        var leaderActualDice: [Int]? = nil
        var rollBreakdown: [String] = []
        var finalEffect = leaderState.projection.finalEffect
        let finalPosition = leaderState.projection.finalPosition

        for member in participants {
            let memberRolls = groupRolls?[safe: rollIndex]
            let memberRawPool: Int
            if member.id == leaderState.currentCharacter.id {
                memberRawPool = leaderState.projection.rawDicePool
            } else {
                memberRawPool = rollRules.getRollContext(
                    for: action,
                    with: member,
                    interactableTags: leaderState.interactableTags,
                    harmFamilies: harmFamilies
                ).baseProjection.rawDicePool
            }
            let resolvedRoll = rollRules.resolveRoll(
                using: memberRolls,
                rawPool: memberRawPool
            )
            rollIndex += 1

            if member.id == leaderState.currentCharacter.id {
                leaderActualDice = resolvedRoll.actualDiceRolled
            }

            bestRoll = max(bestRoll, resolvedRoll.highestRoll)
            isCritical = isCritical || resolvedRoll.isCritical
            rollBreakdown.append("\(member.name) \(resolvedRoll.highestRoll)")

            if member.id != leaderState.currentCharacter.id && resolvedRoll.highestRoll <= 3 {
                supportingFailures += 1
            }
        }

        if isCritical && bestRoll >= 4 {
            finalEffect = finalEffect.increased()
        }

        let outcome = rollRules.outcome(for: bestRoll)
        let consequences = eligibleConsequences(
            for: action,
            baseOutcome: outcome.outcome,
            character: leaderState.currentCharacter,
            finalEffect: finalEffect,
            finalPosition: finalPosition,
            isCritical: isCritical && bestRoll >= 4,
            gameState: gameState
        )
        let context = ConsequenceContext(
            characterID: leaderState.currentCharacter.id,
            interactableID: interactableID,
            finalEffect: finalEffect,
            finalPosition: finalPosition,
            isCritical: isCritical
        )
        let rollPresentation = PendingRollPresentation(
            characterID: leaderState.currentCharacter.id,
            actionName: action.name,
            highestRoll: bestRoll,
            outcome: outcome.label,
            actualDiceRolled: leaderActualDice,
            isCritical: isCritical,
            finalEffect: finalEffect
        )
        var description = pendingResolutionDriver.processConsequences(
            consequences,
            context: context,
            source: .roll,
            rollPresentation: rollPresentation,
            in: &gameState
        )

        if participants.count > 1 {
            let rollSummary = "Room team rolls: \(rollBreakdown.joined(separator: ", "))."
            description = appendLine(rollSummary, to: description)
            appendToPendingResolutionLog(rollSummary, in: &gameState)
        }

        if isCritical && bestRoll >= 4 {
            let criticalMessage = "Critical Success! Effect increased to \(finalEffect.rawValue.capitalized)."
            description = appendLine(criticalMessage, to: description)
            appendToPendingResolutionLog(criticalMessage, in: &gameState)
        }

        if supportingFailures > 0 {
            gameState.party[leaderIndex].stress += supportingFailures
            if let overflow = pendingResolutionDriver.checkStressOverflow(
                for: leaderIndex,
                in: &gameState
            ) {
                description = appendLine(overflow, to: description)
                appendToPendingResolutionLog(overflow, in: &gameState)
            }
            let failureText = "Leader takes \(supportingFailures) Stress from supporting slips."
            description = appendLine(failureText, to: description)
            appendToPendingResolutionLog(failureText, in: &gameState)
        }

        if !leaderState.consumedMessages.isEmpty {
            AudioManager.shared.play(sound: "sfx_modifier_consume.wav")
            let consumedText = leaderState.consumedMessages.joined(separator: "\n")
            description = appendLine(consumedText, to: description)
            appendToPendingResolutionLog(consumedText, in: &gameState)
        }

        return DiceRollResult(
            highestRoll: bestRoll,
            outcome: outcome.label,
            consequences: description,
            actualDiceRolled: leaderActualDice,
            isCritical: isCritical,
            finalEffect: finalEffect,
            isAwaitingDecision: gameState.pendingResolution?.isAwaitingDecision == true
        )
    }

    private func prepareRollState(
        for action: ActionOption,
        characterIndex: Int,
        interactableID: String?,
        chosenOptionalModifierIDs: [UUID],
        in gameState: inout GameState
    ) -> Result<PreparedRollState, PreparedRollError> {
        let currentCharacter = gameState.party[characterIndex]
        let tags = interactableTags(
            for: currentCharacter.id,
            interactableID: interactableID,
            in: gameState
        )
        let context = rollRules.getRollContext(
            for: action,
            with: currentCharacter,
            interactableTags: tags,
            environmentModifiers: activeNodeModifiers(for: currentCharacter.id, in: gameState),
            harmFamilies: harmFamilies
        )
        var workingProjection = context.baseProjection

        if workingProjection.isActionBanned {
            return .failure(
                PreparedRollError(message: workingProjection.notes.joined(separator: "\n"))
            )
        }

        var appliedOptionalMods: [Modifier] = []
        var consumedMessages: [String] = []

        let mutableChosenIDs = chosenOptionalModifierIDs.filter {
            $0 != RollRulesEngine.pushYourselfModifierID &&
            $0 != RollRulesEngine.devilsBargainModifierID
        }
        let contextModifiersByID = Dictionary(
            uniqueKeysWithValues: context.optionalModifiers.map { ($0.id, $0.modifierData) }
        )
        let automaticallyConsumedModifierIDs = rollRules.materiallyAffectingAutomaticModifierIDs(
            for: action,
            with: currentCharacter,
            interactableTags: tags,
            harmFamilies: harmFamilies
        )

        if chosenOptionalModifierIDs.contains(RollRulesEngine.pushYourselfModifierID),
           let pushModifier = applyPushYourselfDuringAction(
                toCharacterAt: characterIndex,
                interactableTags: tags,
                in: &gameState
           ) {
            appliedOptionalMods.append(pushModifier)
        }

        var bargainConsequences: [Consequence] = []
        if chosenOptionalModifierIDs.contains(RollRulesEngine.devilsBargainModifierID),
           let bargain = action.devilsBargain {
            appliedOptionalMods.append(
                rollRules.makeDevilsBargainModifier(title: bargain.title)
            )
            bargainConsequences = sanitizeBargainConsequences(bargain.consequences)
        }

        var modsToKeep: [Modifier] = []
        var consumedModIDs: [UUID] = []
        for var modifier in gameState.party[characterIndex].modifiers {
            let shouldConsumeOptional = mutableChosenIDs.contains(modifier.id)
            let shouldConsumeAutomatic =
                automaticallyConsumedModifierIDs.contains(modifier.id) &&
                !modifier.isOptionalToApply

            if shouldConsumeOptional {
                appliedOptionalMods.append(modifier)
            }

            if (shouldConsumeOptional || shouldConsumeAutomatic) && modifier.uses > 0 {
                modifier.uses -= 1
                if modifier.uses == 0 {
                    consumedModIDs.append(modifier.id)
                    let name = modifier.description.replacingOccurrences(of: "from ", with: "")
                    consumedMessages.append("Used up \(name).")
                    continue
                }
            }
            modsToKeep.append(modifier)
        }
        gameState.party[characterIndex].modifiers = modsToKeep

        for modifierID in mutableChosenIDs where !appliedOptionalMods.contains(where: { $0.id == modifierID }) {
            if let contextModifier = contextModifiersByID[modifierID] {
                appliedOptionalMods.append(contextModifier)
            }
        }

        gameState.party[characterIndex].treasures.removeAll { treasure in
            consumedModIDs.contains(treasure.grantedModifier.id)
        }

        workingProjection = rollRules.calculateEffectiveProjection(
            baseProjection: workingProjection,
            applying: appliedOptionalMods
        )

        return .success(
            PreparedRollState(
                currentCharacter: currentCharacter,
                interactableTags: tags,
                projection: workingProjection,
                consumedMessages: consumedMessages,
                bargainConsequences: bargainConsequences
            )
        )
    }

    private func eligibleConsequences(
        for action: ActionOption,
        baseOutcome: RollOutcome,
        character: Character,
        finalEffect: RollEffect,
        finalPosition: RollPosition,
        isCritical: Bool,
        gameState: GameState
    ) -> [Consequence] {
        var consequences = action.outcomes[baseOutcome] ?? []
        if isCritical {
            consequences += action.outcomes[.critical] ?? []
        }

        return consequences.filter { consequence in
            pendingResolutionDriver.areConditionsMet(
                conditions: consequence.conditions,
                forCharacter: character,
                finalEffect: finalEffect,
                finalPosition: finalPosition,
                in: gameState
            )
        }
    }

    private func activeNodeModifiers(
        for characterID: UUID,
        in gameState: GameState
    ) -> [Modifier] {
        runtime.activeNodeModifiers(for: characterID, in: gameState)
    }

    private func sanitizeBargainConsequences(_ consequences: [Consequence]) -> [Consequence] {
        consequences.map { consequence in
            var sanitized = consequence
            sanitized.resistance = nil
            return sanitized
        }
    }

    private func groupActionParticipants(
        for leaderID: UUID,
        action: ActionOption,
        interactableTags: [String],
        in gameState: GameState
    ) -> [Character] {
        guard let leaderNodeID = runtime.currentNodeID(for: leaderID, in: gameState) else {
            return []
        }

        return gameState.party.filter { member in
            guard !member.isDefeated else { return false }
            guard runtime.currentNodeID(for: member.id, in: gameState) == leaderNodeID else { return false }

            let projection = rollRules.getRollContext(
                for: action,
                with: member,
                interactableTags: interactableTags,
                environmentModifiers: activeNodeModifiers(for: member.id, in: gameState),
                harmFamilies: harmFamilies
            ).baseProjection
            return !projection.isActionBanned
        }
    }

    private func applyPushYourselfDuringAction(
        toCharacterAt index: Int,
        interactableTags: [String],
        in gameState: inout GameState
    ) -> Modifier? {
        let pushCost = rollRules.pushStressCost(
            for: gameState.party[index],
            interactableTags: interactableTags,
            harmFamilies: harmFamilies
        )
        guard gameState.party[index].stress + pushCost <= 9 else { return nil }

        gameState.party[index].stress += pushCost
        _ = pendingResolutionDriver.checkStressOverflow(
            for: index,
            in: &gameState
        )
        return rollRules.makePushYourselfModifier()
    }

    private func currentCharacter(
        for characterID: UUID,
        in gameState: GameState
    ) -> Character? {
        gameState.party.first(where: { $0.id == characterID })
    }

    private func interactableTags(
        for characterID: UUID,
        interactableID: String?,
        in gameState: GameState
    ) -> [String] {
        guard let interactableID,
              let nodeID = gameState.characterLocations[characterID.uuidString],
              let interactable = gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.first(where: { $0.id == interactableID }) else {
            return []
        }
        return interactable.tags
    }

    private func appendToPendingResolutionLog(
        _ text: String,
        in gameState: inout GameState
    ) {
        guard !text.isEmpty, gameState.pendingResolution != nil else { return }
        gameState.pendingResolution?.resolvedDescriptions.append(text)
    }

    private func appendLine(
        _ text: String,
        to existing: String
    ) -> String {
        guard !existing.isEmpty else { return text }
        return existing + "\n" + text
    }

    private func errorResult(_ message: String) -> DiceRollResult {
        DiceRollResult(
            highestRoll: 0,
            outcome: "Error",
            consequences: message,
            actualDiceRolled: nil,
            isCritical: nil,
            finalEffect: nil,
            isAwaitingDecision: false
        )
    }

    private func cannotResult(_ message: String) -> DiceRollResult {
        DiceRollResult(
            highestRoll: 0,
            outcome: "Cannot",
            consequences: message,
            actualDiceRolled: nil,
            isCritical: nil,
            finalEffect: nil,
            isAwaitingDecision: false
        )
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
