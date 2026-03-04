import Foundation

struct ConsequenceExecutor {
    let debugLogging: Bool

    private enum EventResolutionStatus {
        case executed
        case skipped
        case missing
    }

    private struct EventResolution {
        let status: EventResolutionStatus
        let description: String?
    }

    func process(
        _ consequences: [Consequence],
        context: ConsequenceContext,
        gameState: inout GameState
    ) -> String {
        var descriptions: [String] = []
        let character = context.character
        let interactableID = context.interactableID
        let partyMemberID = character.id

        for consequence in consequences {
            if debugLogging {
                print("[Consequences] Evaluating \(consequence.kind) for \(character.name)")
            }

            if !areConditionsMet(
                conditions: consequence.conditions,
                forCharacter: character,
                finalEffect: context.finalEffect,
                finalPosition: context.finalPosition,
                gameState: gameState
            ) {
                if debugLogging {
                    print("[Consequences] Skipping \(consequence.kind) due to unmet conditions")
                }
                continue
            }

            let defersNarrative = consequence.kind == .triggerEvent
            var narrativeUsed = false
            if !defersNarrative, let narrative = consequence.description {
                descriptions.append(narrative)
                narrativeUsed = true
            }

            switch consequence.kind {
            case .gainStress:
                if let amount = consequence.amount,
                   let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                    gameState.party[charIndex].stress += amount
                    descriptions.append("Gained \(amount) Stress.")
                    if let overflow = checkStressOverflow(for: charIndex, gameState: &gameState) {
                        descriptions.append(overflow)
                    }
                }
            case .sufferHarm:
                if let level = consequence.level,
                   let familyID = consequence.familyId {
                    let harmDescription = applyHarm(
                        familyId: familyID,
                        level: level,
                        toCharacter: character.id,
                        gameState: &gameState
                    )
                    if !narrativeUsed {
                        descriptions.append(harmDescription)
                    }
                }
            case .healHarm:
                let healDescription = healHarm(forCharacter: character.id, gameState: &gameState)
                if !narrativeUsed {
                    descriptions.append(healDescription)
                }
            case .tickClock:
                if let clockName = consequence.clockName,
                   let amount = consequence.amount {
                    if let clockIndex = gameState.activeClocks.firstIndex(where: { $0.name == clockName }) {
                        let clockID = gameState.activeClocks[clockIndex].id
                        updateClock(id: clockID, ticks: amount, actingCharacter: context.character, gameState: &gameState)
                        if !narrativeUsed {
                            descriptions.append("The '\(clockName)' clock progresses by \(amount).")
                        }
                    } else if let clockTemplate = ContentLoader.shared.clockTemplates.first(where: { $0.name == clockName }) {
                        var newClock = clockTemplate
                        newClock.progress = amount
                        gameState.activeClocks.append(newClock)
                        if !narrativeUsed {
                            descriptions.append("A new situation develops: '\(clockName)' [\(newClock.progress)/\(newClock.segments)].")
                        }
                    } else {
                        print("WARNING: Attempted to tick a clock named '\(clockName)' that does not exist in the scenario's clock registry.")
                    }
                }
            case .unlockConnection:
                if let fromNodeID = consequence.fromNodeID,
                   let toNodeID = consequence.toNodeID,
                   let connectionIndex = gameState.dungeon?.nodes[fromNodeID.uuidString]?.connections.firstIndex(where: { $0.toNodeID == toNodeID }) {
                    gameState.dungeon?.nodes[fromNodeID.uuidString]?.connections[connectionIndex].isUnlocked = true
                    if !narrativeUsed {
                        descriptions.append("A path has opened!")
                    }
                }
            case .removeInteractable:
                if let interactableID = consequence.interactableId,
                   let nodeID = gameState.characterLocations[partyMemberID.uuidString],
                   var node = gameState.dungeon?.nodes[nodeID.uuidString] {
                    let before = node.interactables.count
                    node.interactables.removeAll(where: { $0.id == interactableID })
                    gameState.dungeon?.nodes[nodeID.uuidString] = node
                    if debugLogging {
                        let removed = before - node.interactables.count
                        print("[Consequences] removeInteractable: removed \(removed) with id \(interactableID)")
                    }
                    if !narrativeUsed {
                        descriptions.append("The way is clear.")
                    }
                }
            case .removeSelfInteractable:
                if let nodeID = gameState.characterLocations[partyMemberID.uuidString],
                   let interactableStringID = interactableID,
                   var node = gameState.dungeon?.nodes[nodeID.uuidString] {
                    node.interactables.removeAll(where: { $0.id == interactableStringID })
                    gameState.dungeon?.nodes[nodeID.uuidString] = node
                    if debugLogging {
                        print("[Consequences] removeSelfInteractable id \(interactableStringID)")
                    }
                    if !narrativeUsed {
                        descriptions.append("The way is clear.")
                    }
                }
            case .removeAction:
                if let nodeID = gameState.characterLocations[partyMemberID.uuidString],
                   let actionName = consequence.actionName {
                    let targetID = consequence.interactableId ?? interactableID
                    if let targetID,
                       let targetIndex = gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.firstIndex(where: { $0.id == targetID }) {
                        gameState.dungeon?.nodes[nodeID.uuidString]?.interactables[targetIndex].availableActions.removeAll(where: { $0.name == actionName })
                        if !narrativeUsed {
                            descriptions.append("'\(actionName)' can no longer be taken.")
                        }
                    }
                }
            case .addAction:
                if let nodeID = gameState.characterLocations[partyMemberID.uuidString],
                   let action = consequence.newAction {
                    let targetID = consequence.interactableId ?? interactableID
                    if let targetID,
                       let targetIndex = gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.firstIndex(where: { $0.id == targetID }) {
                        gameState.dungeon?.nodes[nodeID.uuidString]?.interactables[targetIndex].availableActions.append(action)
                        if !narrativeUsed {
                            descriptions.append("'\(action.name)' is now available.")
                        }
                    }
                }
            case .addInteractable:
                if let nodeID = consequence.inNodeID,
                   let interactable = consequence.newInteractable {
                    gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.append(interactable)
                    if !narrativeUsed {
                        descriptions.append("Something new appears.")
                    }
                }
            case .addInteractableHere:
                if let interactable = consequence.newInteractable,
                   let nodeID = gameState.characterLocations[partyMemberID.uuidString] {
                    gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.append(interactable)
                    if !narrativeUsed {
                        descriptions.append("Something new appears.")
                    }
                }
            case .gainTreasure:
                if let treasureID = consequence.treasureId {
                    if let treasure = ContentLoader.shared.treasureTemplates.first(where: { $0.id == treasureID }) {
                        if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                            gameState.party[charIndex].treasures.append(treasure)
                            gameState.party[charIndex].modifiers.append(treasure.grantedModifier)
                            if !narrativeUsed {
                                descriptions.append("Gained Treasure: \(treasure.name)!")
                            }
                        }
                    } else {
                        print("Treasure with ID \(treasureID) not found in ContentLoader.shared.treasureTemplates.")
                    }
                }
            case .modifyDice:
                if let amount = consequence.amount,
                   let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                    let duration = consequence.duration ?? "next roll"
                    let uses = duration == "next roll" ? 1 : 99
                    let modifier = Modifier(
                        bonusDice: amount,
                        uses: uses,
                        description: "Bonus from consequence"
                    )
                    gameState.party[charIndex].modifiers.append(modifier)
                    if !narrativeUsed {
                        descriptions.append("Gain +\(amount)d for \(duration).")
                    }
                }
            case .createChoice:
                if let option = consequence.choiceOptions?.first {
                    descriptions.append("Auto-selecting: \(option.title)")
                    let subDescription = process(option.consequences, context: context, gameState: &gameState)
                    if !subDescription.isEmpty {
                        descriptions.append(subDescription)
                    }
                }
            case .triggerEvent:
                if let eventID = consequence.eventId {
                    let resolution = resolveTriggeredEvent(
                        eventID,
                        context: context,
                        includeEventDescription: consequence.description == nil,
                        gameState: &gameState
                    )
                    if resolution.status == .executed,
                       let narrative = consequence.description {
                        descriptions.append(narrative)
                    }
                    if let eventDescription = resolution.description,
                       !eventDescription.isEmpty {
                        descriptions.append(eventDescription)
                    } else if resolution.status == .missing,
                              consequence.description == nil {
                        descriptions.append("Event triggered: \(eventID)")
                    }
                }
            case .triggerConsequences:
                if let extraConsequences = consequence.triggered {
                    let subDescription = process(extraConsequences, context: context, gameState: &gameState)
                    if !subDescription.isEmpty {
                        descriptions.append(subDescription)
                    }
                }
            case .setScenarioFlag:
                if let flagID = consequence.flagId {
                    gameState.scenarioFlags[flagID] = true
                }
            case .clearScenarioFlag:
                if let flagID = consequence.flagId {
                    gameState.scenarioFlags.removeValue(forKey: flagID)
                }
            case .incrementScenarioCounter:
                if let counterID = consequence.counterId {
                    gameState.scenarioCounters[counterID, default: 0] += consequence.amount ?? 1
                }
            case .setScenarioCounter:
                if let counterID = consequence.counterId {
                    gameState.scenarioCounters[counterID] = consequence.amount ?? 0
                }
            case .endRun:
                gameState.status = .gameOver
                gameState.runOutcome = consequence.endingOutcome
                gameState.runOutcomeText = consequence.endingText
            }
        }

        return descriptions.joined(separator: "\n")
    }

    func areConditionsMet(
        conditions: [GameCondition]?,
        forCharacter character: Character,
        finalEffect: RollEffect,
        finalPosition: RollPosition,
        gameState: GameState
    ) -> Bool {
        guard let conditions, !conditions.isEmpty else { return true }

        for condition in conditions {
            var conditionMet = false
            switch condition.type {
            case .requiresMinEffectLevel:
                if let requiredEffect = condition.effectParam {
                    conditionMet = finalEffect.isBetterThanOrEqualTo(requiredEffect)
                }
            case .requiresExactEffectLevel:
                conditionMet = condition.effectParam == finalEffect
            case .requiresMinPositionLevel:
                if let requiredPosition = condition.positionParam {
                    conditionMet = finalPosition.isWorseThanOrEqualTo(requiredPosition)
                }
            case .requiresExactPositionLevel:
                conditionMet = condition.positionParam == finalPosition
            case .characterHasTreasureId:
                if let treasureID = condition.stringParam {
                    conditionMet = character.treasures.contains(where: { $0.id == treasureID })
                }
            case .partyHasTreasureWithTag:
                if let tag = condition.stringParam {
                    conditionMet = partyHasTreasureTag(tag, gameState: gameState)
                }
            case .clockProgress:
                if let name = condition.stringParam,
                   let minimum = condition.intParam,
                   let clock = gameState.activeClocks.first(where: { $0.name == name }) {
                    var meetsRange = clock.progress >= minimum
                    if let maximum = condition.intParamMax {
                        meetsRange = meetsRange && clock.progress <= maximum
                    }
                    conditionMet = meetsRange
                }
            case .scenarioFlagSet:
                if let flagID = condition.stringParam {
                    conditionMet = gameState.scenarioFlags[flagID] == true
                }
            case .scenarioCounter:
                if let counterID = condition.stringParam {
                    let value = gameState.scenarioCounters[counterID] ?? 0
                    if let minimum = condition.intParam {
                        conditionMet = value >= minimum
                    } else {
                        conditionMet = true
                    }
                    if let maximum = condition.intParamMax {
                        conditionMet = conditionMet && value <= maximum
                    }
                }
            }

            if !conditionMet {
                return false
            }
        }

        return true
    }

    func checkStressOverflow(for index: Int, gameState: inout GameState) -> String? {
        guard gameState.party.indices.contains(index) else { return nil }
        if gameState.party[index].stress > 9 {
            return handleStressOverflow(for: index, gameState: &gameState)
        }
        return nil
    }

    func applyHarm(
        familyId: String,
        level: HarmLevel,
        toCharacter characterID: UUID,
        gameState: inout GameState
    ) -> String {
        guard let charIndex = gameState.party.firstIndex(where: { $0.id == characterID }) else { return "" }
        guard let harmFamily = HarmLibrary.families[familyId] else { return "" }

        var currentLevel = level

        while true {
            switch currentLevel {
            case .lesser:
                if gameState.party[charIndex].harm.lesser.count < HarmState.lesserSlots {
                    let harm = harmFamily.lesser
                    gameState.party[charIndex].harm.lesser.append((familyId, harm.description))
                    return "Suffered Lesser Harm: \(harm.description)."
                }
                currentLevel = .moderate
            case .moderate:
                if gameState.party[charIndex].harm.moderate.count < HarmState.moderateSlots {
                    let harm = harmFamily.moderate
                    gameState.party[charIndex].harm.moderate.append((familyId, harm.description))
                    return "Suffered Moderate Harm: \(harm.description)."
                }
                currentLevel = .severe
            case .severe:
                if gameState.party[charIndex].harm.severe.count < HarmState.severeSlots {
                    let harm = harmFamily.severe
                    gameState.party[charIndex].harm.severe.append((familyId, harm.description))
                    return "Suffered SEVERE Harm: \(harm.description)."
                }

                gameState.party[charIndex].isDefeated = true
                gameState.characterLocations.removeValue(forKey: characterID.uuidString)
                let fatalDescription = harmFamily.fatal.description

                if gameState.party.allSatisfy(\.isDefeated) {
                    gameState.status = .gameOver
                }

                return "Suffered FATAL Harm: \(fatalDescription)."
            }
        }
    }

    func healHarm(forCharacter characterID: UUID, gameState: inout GameState) -> String {
        guard let index = gameState.party.firstIndex(where: { $0.id == characterID }) else { return "" }
        var messages: [String] = []

        let originalSevere = gameState.party[index].harm.severe
        let originalModerate = gameState.party[index].harm.moderate
        let originalLesser = gameState.party[index].harm.lesser

        gameState.party[index].harm.severe = []
        gameState.party[index].harm.moderate = []
        gameState.party[index].harm.lesser = []

        for entry in originalSevere {
            if let family = HarmLibrary.families[entry.familyId] {
                gameState.party[index].harm.moderate.append((entry.familyId, family.moderate.description))
            } else {
                gameState.party[index].harm.moderate.append(entry)
            }
            messages.append("Severe harm '\(entry.description)' downgraded to Moderate.")
        }

        for entry in originalModerate {
            if let family = HarmLibrary.families[entry.familyId] {
                gameState.party[index].harm.lesser.append((entry.familyId, family.lesser.description))
            } else {
                gameState.party[index].harm.lesser.append(entry)
            }
            messages.append("Moderate harm '\(entry.description)' downgraded to Lesser.")
        }

        for entry in originalLesser {
            messages.append("Lesser harm '\(entry.description)' healed.")
        }

        return messages.joined(separator: "\n")
    }

    private func updateClock(
        id: UUID,
        ticks: Int,
        actingCharacter: Character?,
        gameState: inout GameState
    ) {
        guard let index = gameState.activeClocks.firstIndex(where: { $0.id == id }) else { return }

        var clock = gameState.activeClocks[index]
        clock.progress = min(clock.segments, clock.progress + ticks)

        if let tickConsequences = clock.onTickConsequences,
           let character = actingCharacter ?? gameState.party.first {
            let context = ConsequenceContext(
                character: character,
                interactableID: nil,
                finalEffect: .standard,
                finalPosition: .controlled,
                isCritical: false
            )
            _ = process(tickConsequences, context: context, gameState: &gameState)
        }

        if clock.progress >= clock.segments,
           let completeConsequences = clock.onCompleteConsequences,
           let character = actingCharacter ?? gameState.party.first {
            let context = ConsequenceContext(
                character: character,
                interactableID: nil,
                finalEffect: .standard,
                finalPosition: .controlled,
                isCritical: false
            )
            _ = process(completeConsequences, context: context, gameState: &gameState)
        }

        gameState.activeClocks[index] = clock
    }

    private func handleStressOverflow(for index: Int, gameState: inout GameState) -> String {
        let characterID = gameState.party[index].id
        gameState.party[index].stress = 0
        let overflowHarmFamilyID = ContentLoader.shared.scenarioManifest?.stressOverflowHarmFamilyID ?? "mental_fraying"
        let harmDescription = applyHarm(
            familyId: overflowHarmFamilyID,
            level: .lesser,
            toCharacter: characterID,
            gameState: &gameState
        )
        return "Stress Overload!\n" + harmDescription
    }

    private func partyHasTreasureTag(_ tag: String, gameState: GameState) -> Bool {
        for member in gameState.party where !member.isDefeated {
            for treasure in member.treasures where treasure.tags.contains(tag) {
                return true
            }
        }
        return false
    }

    private func resolveTriggeredEvent(
        _ eventID: String,
        context: ConsequenceContext,
        includeEventDescription: Bool,
        gameState: inout GameState
    ) -> EventResolution {
        guard let event = ContentLoader.shared.eventDict[eventID] else {
            if debugLogging {
                print("[Consequences] Missing authored event '\(eventID)'")
            }
            return EventResolution(status: .missing, description: nil)
        }

        if !areConditionsMet(
            conditions: event.conditions,
            forCharacter: context.character,
            finalEffect: context.finalEffect,
            finalPosition: context.finalPosition,
            gameState: gameState
        ) {
            if debugLogging {
                print("[Consequences] Skipping event '\(eventID)' due to unmet conditions")
            }
            return EventResolution(status: .skipped, description: nil)
        }

        var descriptions: [String] = []
        if includeEventDescription,
           let description = event.description {
            descriptions.append(description)
        }

        let subDescription = process(event.consequences, context: context, gameState: &gameState)
        if !subDescription.isEmpty {
            descriptions.append(subDescription)
        }

        return EventResolution(
            status: .executed,
            description: descriptions.isEmpty ? nil : descriptions.joined(separator: "\n")
        )
    }
}
