import Foundation

struct ResolvedDiceRoll {
    let actualDiceRolled: [Int]
    let highestRoll: Int
    let isCritical: Bool
}

struct RollRulesEngine {
    private let basePushStressCost = 2

    func calculateProjection(
        for action: ActionOption,
        with character: Character,
        interactableTags tags: [String] = [],
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
            for modifier in character.modifiers {
                guard modifier.uses != 0 else { continue }
                guard applies(modifier: modifier, to: action.actionType, tags: tags) else { continue }

                if modifier.bonusDice != 0 {
                    diceCount += modifier.bonusDice
                    var note = "(+\(modifier.bonusDice)d \(modifier.description)"
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
            notes.append("Group Action: party rolls together; best result counts. Leader takes 1 Stress per failed ally.")
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
        harmFamilies: [String: HarmFamily]
    ) -> (baseProjection: RollProjectionDetails, optionalModifiers: [SelectableModifierInfo]) {
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

        let treasureModifiers = character.treasures.map(\.grantedModifier)
        var modifiersByID: [UUID: Modifier] = [:]
        for modifier in character.modifiers + treasureModifiers {
            modifiersByID[modifier.id] = modifier
        }

        if !isActionBanned {
            for modifier in modifiersByID.values {
                guard modifier.uses != 0 else { continue }
                guard !modifier.isOptionalToApply else { continue }
                guard applies(modifier: modifier, to: action.actionType, tags: tags) else { continue }

                if modifier.bonusDice != 0 {
                    diceCount += modifier.bonusDice
                    notes.append("(+\(modifier.bonusDice)d \(modifier.description))")
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
            for modifier in modifiersByID.values {
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
                let pushModifier = Modifier(bonusDice: 1, uses: 1, isOptionalToApply: true, description: "Push Yourself")
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
        }

        return (projection, optionalInfos)
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
