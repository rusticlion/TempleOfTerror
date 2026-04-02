import Foundation

struct ConsequenceExecutor {
    struct ProcessingResult {
        let description: String
        let pendingResolution: PendingConsequenceResolution?
    }

    struct ResistanceRollOutcome {
        let attribute: ResistanceAttribute
        let diceRolled: [Int]
        let highestRoll: Int
        let stressCost: Int
    }

    let debugLogging: Bool
    let runtime: ScenarioRuntime
    let content: ContentLoader

    init(
        debugLogging: Bool,
        runtime: ScenarioRuntime
    ) {
        self.debugLogging = debugLogging
        self.runtime = runtime
        self.content = runtime.content
    }

    private enum EventResolutionStatus {
        case executed
        case skipped
        case missing
    }

    private struct EventResolution {
        let status: EventResolutionStatus
        let description: String?
        let consequences: [Consequence]
    }

    private struct QueuedFrame {
        let context: ConsequenceContext
        let consequences: [Consequence]
    }

    func process(
        _ consequences: [Consequence],
        context: ConsequenceContext,
        source: ResolutionSource = .freeAction,
        rollPresentation: PendingRollPresentation? = nil,
        gameState: inout GameState
    ) -> ProcessingResult {
        var resolution = PendingConsequenceResolution(
            source: source,
            frames: [ConsequenceResolutionFrame(context: context, remainingConsequences: consequences)],
            resolvedDescriptions: [],
            pendingChoice: nil,
            pendingResistance: nil,
            rollPresentation: rollPresentation,
            requiresAcknowledgement: false
        )
        return advance(&resolution, gameState: &gameState)
    }

    func resume(
        _ pendingResolution: PendingConsequenceResolution,
        gameState: inout GameState
    ) -> ProcessingResult {
        var resolution = pendingResolution
        return advance(&resolution, gameState: &gameState)
    }

    func previewUpcomingResistances(
        in pendingResolution: PendingConsequenceResolution,
        gameState: GameState,
        limit: Int = 3
    ) -> [PendingResistanceState] {
        guard limit > 0 else { return [] }

        var previews: [PendingResistanceState] = []
        for frame in pendingResolution.frames {
            guard let character = frame.context.character(in: gameState) else { continue }

            for consequence in frame.remainingConsequences {
                if consequence.kind == .createChoice {
                    let availableOptions = availableChoiceOptions(
                        from: consequence,
                        context: frame.context,
                        gameState: gameState
                    )
                    if !availableOptions.isEmpty {
                        return previews
                    }
                    continue
                }

                guard areConditionsMet(
                    conditions: consequence.conditions,
                    forCharacter: character,
                    finalEffect: frame.context.finalEffect,
                    finalPosition: frame.context.finalPosition,
                    gameState: gameState
                ) else {
                    continue
                }

                if let preview = makePendingResistanceState(
                    for: consequence,
                    context: frame.context,
                    gameState: gameState
                ) {
                    previews.append(preview)
                    if previews.count >= limit {
                        return previews
                    }
                }
            }
        }

        return previews
    }

    func chooseOption(
        at index: Int,
        in pendingResolution: PendingConsequenceResolution,
        gameState: inout GameState
    ) -> ProcessingResult {
        var resolution = pendingResolution
        guard let pendingChoice = resolution.pendingChoice,
              pendingChoice.options.indices.contains(index) else {
            return ProcessingResult(description: resolution.resolvedText, pendingResolution: resolution)
        }

        append(pendingChoice.prompt, to: &resolution)
        append("Chose: \(pendingChoice.options[index].title).", to: &resolution)
        resolution.pendingChoice = nil
        if !resolution.frames.isEmpty {
            resolution.frames[0].remainingConsequences =
                pendingChoice.options[index].consequences + resolution.frames[0].remainingConsequences
        }
        return advance(&resolution, gameState: &gameState)
    }

    func acceptResistance(
        in pendingResolution: PendingConsequenceResolution,
        gameState: inout GameState
    ) -> ProcessingResult {
        var resolution = pendingResolution
        guard let pendingResistance = resolution.pendingResistance,
              let context = resolution.activeContext,
              let character = context.character(in: gameState) else {
            return ProcessingResult(description: resolution.resolvedText, pendingResolution: resolution)
        }

        resolution.pendingResistance = nil
        resolution.resolvedResistanceCount += 1
        apply(
            pendingResistance.consequence,
            context: context,
            actingCharacter: character,
            includeNarrative: true,
            resolution: &resolution,
            gameState: &gameState
        )
        return advance(&resolution, gameState: &gameState)
    }

    func resist(
        in pendingResolution: PendingConsequenceResolution,
        usingDice diceResults: [Int]? = nil,
        gameState: inout GameState
    ) -> (ProcessingResult, ResistanceRollOutcome)? {
        var resolution = pendingResolution
        guard let pendingResistance = resolution.pendingResistance,
              let context = resolution.activeContext,
              let character = context.character(in: gameState) else {
            return nil
        }

        let rollOutcome = resolveResistanceRoll(
            attribute: pendingResistance.attribute,
            for: character,
            usingDice: diceResults
        )
        resolution.pendingResistance = nil
        resolution.resolvedResistanceCount += 1

        append(pendingResistance.prompt, to: &resolution)
        append(
            "Resisted with \(pendingResistance.attribute.title) (rolled \(rollOutcome.highestRoll), +\(rollOutcome.stressCost) Stress).",
            to: &resolution
        )

        if let charIndex = gameState.party.firstIndex(where: { $0.id == context.characterID }) {
            gameState.party[charIndex].stress += rollOutcome.stressCost
            if let overflow = checkStressOverflow(for: charIndex, gameState: &gameState) {
                append(overflow, to: &resolution)
            }
        }

        if let mitigatedConsequence = mitigatedConsequence(
            from: pendingResistance.consequence,
            using: pendingResistance.attribute
        ),
           let refreshedCharacter = context.character(in: gameState) {
            apply(
                mitigatedConsequence,
                context: context,
                actingCharacter: refreshedCharacter,
                includeNarrative: false,
                resolution: &resolution,
                gameState: &gameState
            )
        } else {
            append("The consequence was avoided.", to: &resolution)
        }

        let result = advance(&resolution, gameState: &gameState)
        return (result, rollOutcome)
    }

    private func advance(
        _ resolution: inout PendingConsequenceResolution,
        gameState: inout GameState
    ) -> ProcessingResult {
        resolution.pendingChoice = nil
        resolution.pendingResistance = nil

        while !resolution.frames.isEmpty {
            if resolution.frames[0].remainingConsequences.isEmpty {
                resolution.frames.removeFirst()
                continue
            }

            let consequence = resolution.frames[0].remainingConsequences.removeFirst()
            let context = resolution.frames[0].context

            guard let character = context.character(in: gameState) else {
                continue
            }

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

            if consequence.kind == .createChoice,
               let options = consequence.choiceOptions,
               !options.isEmpty {
                let availableOptions = availableChoiceOptions(
                    from: consequence,
                    context: context,
                    gameState: gameState
                )
                guard !availableOptions.isEmpty else {
                    append(consequence.description, to: &resolution)
                    append("No options are currently available.", to: &resolution)
                    continue
                }
                resolution.pendingChoice = PendingChoiceState(
                    prompt: consequence.description,
                    options: availableOptions
                )
                resolution.requiresAcknowledgement = true
                return ProcessingResult(description: resolution.resolvedText, pendingResolution: resolution)
            }

            if let pendingResistance = makePendingResistanceState(
                for: consequence,
                context: context,
                gameState: gameState,
                sequenceIndex: resolution.resolvedResistanceCount + 1,
                sequenceTotal: resolution.resolvedResistanceCount + 1 + countUpcomingVisibleResistances(
                    in: resolution,
                    gameState: gameState
                )
            ) {
                resolution.pendingResistance = pendingResistance
                resolution.requiresAcknowledgement = true
                return ProcessingResult(description: resolution.resolvedText, pendingResolution: resolution)
            }

            apply(
                consequence,
                context: context,
                actingCharacter: character,
                includeNarrative: true,
                resolution: &resolution,
                gameState: &gameState
            )
        }

        if resolution.requiresAcknowledgement {
            return ProcessingResult(description: resolution.resolvedText, pendingResolution: resolution)
        }
        return ProcessingResult(description: resolution.resolvedText, pendingResolution: nil)
    }

    private func apply(
        _ consequence: Consequence,
        context: ConsequenceContext,
        actingCharacter: Character,
        includeNarrative: Bool,
        resolution: inout PendingConsequenceResolution,
        gameState: inout GameState
    ) {
        let interactableID = context.interactableID
        let partyMemberID = actingCharacter.id
        let defersNarrative = consequence.kind == .triggerEvent
        var narrativeUsed = false

        if includeNarrative, !defersNarrative, let narrative = consequence.description {
            append(narrative, to: &resolution)
            narrativeUsed = true
        }

        switch consequence.kind {
        case .gainStress:
            if let amount = consequence.amount {
                for targetID in scopedCharacterIDs(
                    for: consequence,
                    context: context,
                    actingCharacterID: actingCharacter.id,
                    gameState: gameState
                ) {
                    guard let charIndex = gameState.party.firstIndex(where: { $0.id == targetID }) else { continue }
                    if let stressText = applyStressDelta(amount, toCharacterAt: charIndex, gameState: &gameState) {
                        append(
                            formattedScopedMessage(
                                stressText,
                                forCharacterID: targetID,
                                consequence: consequence,
                                actingCharacterID: actingCharacter.id,
                                gameState: gameState
                            ),
                            to: &resolution
                        )
                    }
                }
            }
        case .adjustStress:
            if let amount = consequence.amount {
                for targetID in scopedCharacterIDs(
                    for: consequence,
                    context: context,
                    actingCharacterID: actingCharacter.id,
                    gameState: gameState
                ) {
                    guard let charIndex = gameState.party.firstIndex(where: { $0.id == targetID }) else { continue }
                    if let stressText = applyStressDelta(amount, toCharacterAt: charIndex, gameState: &gameState) {
                        append(
                            formattedScopedMessage(
                                stressText,
                                forCharacterID: targetID,
                                consequence: consequence,
                                actingCharacterID: actingCharacter.id,
                                gameState: gameState
                            ),
                            to: &resolution
                        )
                    }
                }
            }
        case .sufferHarm:
            if let level = consequence.level,
               let familyID = consequence.familyId {
                for targetID in scopedCharacterIDs(
                    for: consequence,
                    context: context,
                    actingCharacterID: actingCharacter.id,
                    gameState: gameState
                ) {
                    let harmDescription = applyHarm(
                        familyId: familyID,
                        level: level,
                        toCharacter: targetID,
                        gameState: &gameState
                    )
                    if !narrativeUsed {
                        append(
                            formattedScopedMessage(
                                harmDescription,
                                forCharacterID: targetID,
                                consequence: consequence,
                                actingCharacterID: actingCharacter.id,
                                gameState: gameState
                            ),
                            to: &resolution
                        )
                    }
                }
            }
        case .healHarm:
            for targetID in scopedCharacterIDs(
                for: consequence,
                context: context,
                actingCharacterID: actingCharacter.id,
                gameState: gameState
            ) {
                let healDescription = healHarm(forCharacter: targetID, gameState: &gameState)
                if !narrativeUsed {
                    append(
                        formattedScopedMessage(
                            healDescription,
                            forCharacterID: targetID,
                            consequence: consequence,
                            actingCharacterID: actingCharacter.id,
                            gameState: gameState
                        ),
                        to: &resolution
                    )
                }
            }
        case .tickClock:
            if let clockName = consequence.clockName,
               let amount = consequence.amount {
                if let clockIndex = gameState.activeClocks.firstIndex(where: { $0.name == clockName }) {
                    let clockID = gameState.activeClocks[clockIndex].id
                    let queuedFrames = updateClock(
                        id: clockID,
                        ticks: amount,
                        actingCharacterID: actingCharacter.id,
                        gameState: &gameState
                    )
                    if !narrativeUsed {
                        append("The '\(clockName)' clock progresses by \(amount).", to: &resolution)
                    }
                    prepend(queuedFrames, to: &resolution)
                } else if let clockTemplate = content.clockTemplates.first(where: { $0.name == clockName }) {
                    var newClock = clockTemplate
                    newClock.progress = amount
                    gameState.activeClocks.append(newClock)
                    if !narrativeUsed {
                        append(
                            "A new situation develops: '\(clockName)' [\(newClock.progress)/\(newClock.segments)].",
                            to: &resolution
                        )
                    }
                } else {
                    print("WARNING: Attempted to tick a clock named '\(clockName)' that does not exist in the scenario's clock registry.")
                }
            }
        case .unlockConnection:
            if let fromNodeID = consequence.fromNodeID,
               let toNodeID = consequence.toNodeID,
               runtime.unlockConnection(fromNodeID: fromNodeID, toNodeID: toNodeID, in: &gameState) {
                if !narrativeUsed {
                    append("A path has opened!", to: &resolution)
                }
            }
        case .lockConnection:
            if let fromNodeID = consequence.fromNodeID,
               let toNodeID = consequence.toNodeID,
               runtime.lockConnection(fromNodeID: fromNodeID, toNodeID: toNodeID, in: &gameState) {
                if !narrativeUsed {
                    append("A path slams shut.", to: &resolution)
                }
            }
        case .moveActingCharacterToNode:
            if let toNodeID = consequence.toNodeID {
                let targetIDs = scopedCharacterIDs(
                    for: consequence,
                    context: context,
                    actingCharacterID: actingCharacter.id,
                    gameState: gameState
                ).filter { runtime.currentNodeID(for: $0, in: gameState) != toNodeID }

                guard !targetIDs.isEmpty,
                      let destination = runtime.moveCharacters(
                        ids: targetIDs,
                        toNodeID: toNodeID,
                        focusCharacterID: actingCharacter.id,
                        in: &gameState
                      ) else {
                    break
                }

                if !narrativeUsed {
                    append(movementMessage(for: consequence, destination: destination.name), to: &resolution)
                }

                let entryConsequences = runtime.entryConsequences(for: toNodeID, in: &gameState)
                if !entryConsequences.isEmpty {
                    let hookContext = ConsequenceContext(
                        characterID: actingCharacter.id,
                        interactableID: nil,
                        finalEffect: .standard,
                        finalPosition: .risky,
                        isCritical: false,
                        scopeNodeID: toNodeID
                    )
                    enqueueAfterCurrentFrame(
                        QueuedFrame(context: hookContext, consequences: entryConsequences),
                        to: &resolution
                    )
                }
            }
        case .removeInteractable:
            if let interactableID = consequence.interactableId,
               let nodeID = runtime.currentNodeID(for: partyMemberID, in: gameState),
               let removed = runtime.removeInteractable(id: interactableID, fromNodeID: nodeID, in: &gameState) {
                if debugLogging {
                    print("[Consequences] removeInteractable: removed \(removed) with id \(interactableID)")
                }
                if !narrativeUsed {
                    append("The way is clear.", to: &resolution)
                }
            }
        case .removeSelfInteractable:
            if let nodeID = runtime.currentNodeID(for: partyMemberID, in: gameState),
               let interactableStringID = interactableID,
               runtime.removeInteractable(id: interactableStringID, fromNodeID: nodeID, in: &gameState) != nil {
                if debugLogging {
                    print("[Consequences] removeSelfInteractable id \(interactableStringID)")
                }
                if !narrativeUsed {
                    append("The way is clear.", to: &resolution)
                }
            }
        case .removeAction:
            if let nodeID = runtime.currentNodeID(for: partyMemberID, in: gameState),
               let actionName = consequence.actionName {
                let targetID: String?
                if let explicitID = consequence.interactableId, explicitID != "self" {
                    targetID = explicitID
                } else {
                    targetID = interactableID
                }
                if let targetID,
                   runtime.removeAction(named: actionName, fromInteractable: targetID, inNodeID: nodeID, in: &gameState) {
                    if !narrativeUsed {
                        append("'\(actionName)' can no longer be taken.", to: &resolution)
                    }
                }
            }
        case .addAction:
            if let nodeID = runtime.currentNodeID(for: partyMemberID, in: gameState),
               let action = consequence.newAction {
                let targetID: String?
                if let explicitID = consequence.interactableId, explicitID != "self" {
                    targetID = explicitID
                } else {
                    targetID = interactableID
                }
                if let targetID,
                   runtime.addAction(action, toInteractable: targetID, inNodeID: nodeID, in: &gameState) {
                    if !narrativeUsed {
                        append("'\(action.name)' is now available.", to: &resolution)
                    }
                }
            }
        case .addInteractable:
            if let nodeID = consequence.inNodeID,
               let interactable = resolveSpawnInteractable(from: consequence),
               runtime.addInteractable(interactable, inNodeID: nodeID, in: &gameState) {
                if !narrativeUsed {
                    append("Something new appears.", to: &resolution)
                }
            }
        case .addInteractableHere:
            if let interactable = resolveSpawnInteractable(from: consequence),
               runtime.addInteractableHere(interactable, forCharacterID: partyMemberID, in: &gameState) {
                if !narrativeUsed {
                    append("Something new appears.", to: &resolution)
                }
            }
        case .gainTreasure:
            if let treasureID = consequence.treasureId {
                if let treasure = content.treasureTemplates.first(where: { $0.id == treasureID }) {
                    if let charIndex = gameState.party.firstIndex(where: { $0.id == actingCharacter.id }) {
                        gameState.party[charIndex].treasures.append(treasure)
                        gameState.party[charIndex].modifiers.append(treasure.grantedModifier)
                        if !narrativeUsed {
                            append("Gained Treasure: \(treasure.name)!", to: &resolution)
                        }
                    }
                } else {
                    print("Treasure with ID \(treasureID) not found in active scenario treasure templates.")
                }
            }
        case .removeTreasure:
            if let treasureID = consequence.treasureId,
               let removedTreasure = removeTreasure(
                   id: treasureID,
                   fromCharacter: actingCharacter.id,
                   gameState: &gameState
               ),
               !narrativeUsed {
                append("Spent Treasure: \(removedTreasure.name).", to: &resolution)
            }
        case .removeTreasureWithTag:
            if let tag = consequence.tag,
               let removedTreasure = removeFirstTreasure(
                   withTag: tag,
                   fromCharacter: actingCharacter.id,
                   gameState: &gameState
               ),
               !narrativeUsed {
                append("Spent Treasure: \(removedTreasure.name).", to: &resolution)
            }
        case .grantModifier:
            if let modifier = consequence.modifier {
                for targetID in scopedCharacterIDs(
                    for: consequence,
                    context: context,
                    actingCharacterID: actingCharacter.id,
                    gameState: gameState
                ) {
                    guard grantModifier(
                        modifier,
                        toCharacter: targetID,
                        gameState: &gameState
                    ) else {
                        continue
                    }

                    if !narrativeUsed {
                        append(
                            formattedScopedMessage(
                                "Gain modifier: \(modifier.longDescription).",
                                forCharacterID: targetID,
                                consequence: consequence,
                                actingCharacterID: actingCharacter.id,
                                gameState: gameState
                            ),
                            to: &resolution
                        )
                    }
                }
            }
        case .removeModifier:
            if let sourceKey = consequence.sourceKey {
                for targetID in scopedCharacterIDs(
                    for: consequence,
                    context: context,
                    actingCharacterID: actingCharacter.id,
                    gameState: gameState
                ) {
                    guard removeModifier(
                        sourceKey: sourceKey,
                        fromCharacter: targetID,
                        gameState: &gameState
                    ) else {
                        continue
                    }

                    if !narrativeUsed {
                        append(
                            formattedScopedMessage(
                                "Lose modifier: \(sourceKey).",
                                forCharacterID: targetID,
                                consequence: consequence,
                                actingCharacterID: actingCharacter.id,
                                gameState: gameState
                            ),
                            to: &resolution
                        )
                    }
                }
            }
        case .modifyDice:
            if let amount = consequence.amount {
                let duration = consequence.duration ?? "next roll"
                let uses = duration == "next roll" ? 1 : 99
                for targetID in scopedCharacterIDs(
                    for: consequence,
                    context: context,
                    actingCharacterID: actingCharacter.id,
                    gameState: gameState
                ) {
                    guard let charIndex = gameState.party.firstIndex(where: { $0.id == targetID }) else { continue }
                    let modifier = Modifier(
                        bonusDice: amount,
                        uses: uses,
                        description: "Bonus from consequence"
                    )
                    gameState.party[charIndex].modifiers.append(modifier)
                    if !narrativeUsed {
                        append(
                            formattedScopedMessage(
                                "Gain +\(amount)d for \(duration).",
                                forCharacterID: targetID,
                                consequence: consequence,
                                actingCharacterID: actingCharacter.id,
                                gameState: gameState
                            ),
                            to: &resolution
                        )
                    }
                }
            }
        case .createChoice:
            break
        case .triggerEvent:
            if let eventID = consequence.eventId {
                let eventResolution = resolveTriggeredEvent(
                    eventID,
                    context: context,
                    includeEventDescription: consequence.description == nil,
                    gameState: gameState
                )
                if eventResolution.status == .executed,
                   let narrative = consequence.description {
                    append(narrative, to: &resolution)
                }
                if let eventDescription = eventResolution.description,
                   !eventDescription.isEmpty {
                    append(eventDescription, to: &resolution)
                } else if eventResolution.status == .missing,
                          consequence.description == nil {
                    append("Event triggered: \(eventID)", to: &resolution)
                }
                if !eventResolution.consequences.isEmpty {
                    prepend([QueuedFrame(context: context, consequences: eventResolution.consequences)], to: &resolution)
                }
            }
        case .triggerConsequences:
            if let extraConsequences = consequence.triggered,
               !extraConsequences.isEmpty {
                prepend([QueuedFrame(context: context, consequences: extraConsequences)], to: &resolution)
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
        case .addCharacterTag:
            if let tag = consequence.tag {
                for targetID in scopedCharacterIDs(
                    for: consequence,
                    context: context,
                    actingCharacterID: actingCharacter.id,
                    gameState: gameState
                ) {
                    guard addCharacterStateTag(tag, toCharacter: targetID, gameState: &gameState) else { continue }
                    if !narrativeUsed {
                        append(
                            formattedScopedMessage(
                                "Gained tag: \(tag).",
                                forCharacterID: targetID,
                                consequence: consequence,
                                actingCharacterID: actingCharacter.id,
                                gameState: gameState
                            ),
                            to: &resolution
                        )
                    }
                }
            }
        case .removeCharacterTag:
            if let tag = consequence.tag {
                for targetID in scopedCharacterIDs(
                    for: consequence,
                    context: context,
                    actingCharacterID: actingCharacter.id,
                    gameState: gameState
                ) {
                    guard removeCharacterStateTag(tag, fromCharacter: targetID, gameState: &gameState) else { continue }
                    if !narrativeUsed {
                        append(
                            formattedScopedMessage(
                                "Lost tag: \(tag).",
                                forCharacterID: targetID,
                                consequence: consequence,
                                actingCharacterID: actingCharacter.id,
                                gameState: gameState
                            ),
                            to: &resolution
                        )
                    }
                }
            }
        case .endRun:
            gameState.status = .gameOver
            gameState.runOutcome = consequence.endingOutcome
            gameState.runOutcomeText = consequence.endingText
        }
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
            case .characterHasTreasureWithTag:
                if let tag = condition.stringParam {
                    conditionMet = character.treasures.contains(where: { $0.tags.contains(tag) })
                }
            case .characterHasTag:
                if let tag = condition.stringParam {
                    conditionMet = character.hasTag(tag)
                }
            case .characterLacksTag:
                if let tag = condition.stringParam {
                    conditionMet = !character.hasTag(tag)
                }
            case .partyHasTreasureWithTag:
                if let tag = condition.stringParam {
                    conditionMet = partyHasTreasureTag(tag, gameState: gameState)
                }
            case .partyHasMemberWithTag:
                if let tag = condition.stringParam {
                    conditionMet = partyHasMemberWithTag(tag, gameState: gameState)
                }
            case .partyIsSplit:
                conditionMet = partyIsSplit(gameState: gameState)
            case .characterIsAlone:
                conditionMet = characterIsAlone(character.id, gameState: gameState)
            case .anotherPartyMemberHere:
                conditionMet = anotherPartyMemberHere(character.id, gameState: gameState)
            case .partyMemberHereWithTag:
                if let tag = condition.stringParam {
                    conditionMet = partyMemberHere(withTag: tag, relativeTo: character.id, gameState: gameState)
                }
            case .partyMemberElsewhereWithTag:
                if let tag = condition.stringParam {
                    conditionMet = partyMemberElsewhere(withTag: tag, relativeTo: character.id, gameState: gameState)
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
        guard let harmFamily = content.harmFamilyDict[familyId] else { return "" }

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
            if let family = content.harmFamilyDict[entry.familyId] {
                gameState.party[index].harm.moderate.append((entry.familyId, family.moderate.description))
            } else {
                gameState.party[index].harm.moderate.append(entry)
            }
            messages.append("Severe harm '\(entry.description)' downgraded to Moderate.")
        }

        for entry in originalModerate {
            if let family = content.harmFamilyDict[entry.familyId] {
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
        actingCharacterID: UUID,
        gameState: inout GameState
    ) -> [QueuedFrame] {
        guard let index = gameState.activeClocks.firstIndex(where: { $0.id == id }) else { return [] }

        var clock = gameState.activeClocks[index]
        clock.progress = min(clock.segments, clock.progress + ticks)

        var queuedFrames: [QueuedFrame] = []
        let callbackContext = ConsequenceContext(
            characterID: actingCharacterID,
            interactableID: nil,
            finalEffect: .standard,
            finalPosition: .controlled,
            isCritical: false
        )

        if let tickConsequences = clock.onTickConsequences, !tickConsequences.isEmpty {
            queuedFrames.append(QueuedFrame(context: callbackContext, consequences: tickConsequences))
        }

        if clock.progress >= clock.segments,
           let completeConsequences = clock.onCompleteConsequences,
           !completeConsequences.isEmpty {
            queuedFrames.append(QueuedFrame(context: callbackContext, consequences: completeConsequences))
        }

        gameState.activeClocks[index] = clock
        return queuedFrames
    }

    private func handleStressOverflow(for index: Int, gameState: inout GameState) -> String {
        let characterID = gameState.party[index].id
        gameState.party[index].stress = 0
        let overflowHarmFamilyID = content.scenarioManifest?.stressOverflowHarmFamilyID ?? "mental_fraying"
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

    private func partyHasMemberWithTag(_ tag: String, gameState: GameState) -> Bool {
        gameState.party.contains { !$0.isDefeated && $0.hasTag(tag) }
    }

    private func partyIsSplit(gameState: GameState) -> Bool {
        let occupiedNodes = Set(
            gameState.party
                .filter { !$0.isDefeated }
                .compactMap { gameState.characterLocations[$0.id.uuidString] }
        )
        return occupiedNodes.count > 1
    }

    private func characterIsAlone(_ characterID: UUID, gameState: GameState) -> Bool {
        guard runtime.currentNodeID(for: characterID, in: gameState) != nil else { return false }
        return !anotherPartyMemberHere(characterID, gameState: gameState)
    }

    private func anotherPartyMemberHere(_ characterID: UUID, gameState: GameState) -> Bool {
        guard let nodeID = runtime.currentNodeID(for: characterID, in: gameState) else { return false }
        return gameState.party.contains { member in
            !member.isDefeated &&
            member.id != characterID &&
            gameState.characterLocations[member.id.uuidString] == nodeID
        }
    }

    private func partyMemberHere(
        withTag tag: String,
        relativeTo characterID: UUID,
        gameState: GameState
    ) -> Bool {
        guard let nodeID = runtime.currentNodeID(for: characterID, in: gameState) else { return false }
        return gameState.party.contains { member in
            !member.isDefeated &&
            member.id != characterID &&
            gameState.characterLocations[member.id.uuidString] == nodeID &&
            member.hasTag(tag)
        }
    }

    private func partyMemberElsewhere(
        withTag tag: String,
        relativeTo characterID: UUID,
        gameState: GameState
    ) -> Bool {
        guard let nodeID = runtime.currentNodeID(for: characterID, in: gameState) else { return false }
        return gameState.party.contains { member in
            guard !member.isDefeated,
                  member.id != characterID,
                  let memberNodeID = gameState.characterLocations[member.id.uuidString] else {
                return false
            }
            return memberNodeID != nodeID && member.hasTag(tag)
        }
    }

    private func addCharacterStateTag(
        _ tag: String,
        toCharacter characterID: UUID,
        gameState: inout GameState
    ) -> Bool {
        guard let index = gameState.party.firstIndex(where: { $0.id == characterID }) else { return false }
        return gameState.party[index].addStateTag(tag)
    }

    private func removeCharacterStateTag(
        _ tag: String,
        fromCharacter characterID: UUID,
        gameState: inout GameState
    ) -> Bool {
        guard let index = gameState.party.firstIndex(where: { $0.id == characterID }) else { return false }
        return gameState.party[index].removeStateTag(tag)
    }

    private func applyStressDelta(
        _ delta: Int,
        toCharacterAt index: Int,
        gameState: inout GameState
    ) -> String? {
        guard gameState.party.indices.contains(index), delta != 0 else { return nil }

        let previousStress = gameState.party[index].stress
        let updatedStress = max(0, previousStress + delta)
        let appliedDelta = updatedStress - previousStress
        gameState.party[index].stress = updatedStress

        var messages: [String] = []
        if appliedDelta > 0 {
            messages.append("Gained \(appliedDelta) Stress.")
        } else if appliedDelta < 0 {
            messages.append("Recovered \(abs(appliedDelta)) Stress.")
        }

        if delta > 0,
            gameState.party[index].stress > 9,
            gameState.party[index].stress > previousStress,
           let overflow = checkStressOverflow(for: index, gameState: &gameState) {
            messages.append(overflow)
        }

        return messages.joined(separator: "\n")
    }

    private func removeTreasure(
        id treasureID: String,
        fromCharacter characterID: UUID,
        gameState: inout GameState
    ) -> Treasure? {
        guard let charIndex = gameState.party.firstIndex(where: { $0.id == characterID }),
              let treasureIndex = gameState.party[charIndex].treasures.firstIndex(where: { $0.id == treasureID }) else {
            return nil
        }

        let removedTreasure = gameState.party[charIndex].treasures.remove(at: treasureIndex)
        gameState.party[charIndex].modifiers.removeAll { $0.id == removedTreasure.grantedModifier.id }
        return removedTreasure
    }

    private func removeFirstTreasure(
        withTag tag: String,
        fromCharacter characterID: UUID,
        gameState: inout GameState
    ) -> Treasure? {
        guard let charIndex = gameState.party.firstIndex(where: { $0.id == characterID }),
              let treasureIndex = gameState.party[charIndex].treasures.firstIndex(where: { $0.tags.contains(tag) }) else {
            return nil
        }

        let removedTreasure = gameState.party[charIndex].treasures.remove(at: treasureIndex)
        gameState.party[charIndex].modifiers.removeAll { $0.id == removedTreasure.grantedModifier.id }
        return removedTreasure
    }

    private func grantModifier(
        _ modifier: Modifier,
        toCharacter characterID: UUID,
        gameState: inout GameState
    ) -> Bool {
        guard let charIndex = gameState.party.firstIndex(where: { $0.id == characterID }) else {
            return false
        }

        var grantedModifier = modifier
        grantedModifier.id = UUID()

        if let sourceKey = grantedModifier.sourceKey?.trimmingCharacters(in: .whitespacesAndNewlines),
           !sourceKey.isEmpty {
            grantedModifier.sourceKey = sourceKey
            gameState.party[charIndex].modifiers.removeAll { $0.sourceKey == sourceKey }
        }

        gameState.party[charIndex].modifiers.append(grantedModifier)
        return true
    }

    private func removeModifier(
        sourceKey: String,
        fromCharacter characterID: UUID,
        gameState: inout GameState
    ) -> Bool {
        guard let charIndex = gameState.party.firstIndex(where: { $0.id == characterID }) else {
            return false
        }

        let trimmedSourceKey = sourceKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSourceKey.isEmpty else { return false }

        let beforeCount = gameState.party[charIndex].modifiers.count
        gameState.party[charIndex].modifiers.removeAll { $0.sourceKey == trimmedSourceKey }
        return gameState.party[charIndex].modifiers.count != beforeCount
    }

    private func scopedCharacterIDs(
        for consequence: Consequence,
        context: ConsequenceContext,
        actingCharacterID: UUID,
        gameState: GameState
    ) -> [UUID] {
        switch consequence.effectiveTargetScope {
        case .actingCharacter:
            return gameState.party.contains(where: { $0.id == actingCharacterID && !$0.isDefeated }) ? [actingCharacterID] : []
        case .allHere:
            guard let nodeID = context.scopeNodeID ?? runtime.currentNodeID(for: actingCharacterID, in: gameState) else { return [] }
            return gameState.party.compactMap { member in
                guard !member.isDefeated,
                      gameState.characterLocations[member.id.uuidString] == nodeID else {
                    return nil
                }
                return member.id
            }
        case .othersHere:
            guard let nodeID = context.scopeNodeID ?? runtime.currentNodeID(for: actingCharacterID, in: gameState) else { return [] }
            return gameState.party.compactMap { member in
                guard !member.isDefeated,
                      member.id != actingCharacterID,
                      gameState.characterLocations[member.id.uuidString] == nodeID else {
                    return nil
                }
                return member.id
            }
        case .allParty:
            return gameState.party.compactMap { member in
                guard !member.isDefeated else { return nil }
                return member.id
            }
        }
    }

    private func formattedScopedMessage(
        _ message: String,
        forCharacterID targetID: UUID,
        consequence: Consequence,
        actingCharacterID: UUID,
        gameState: GameState
    ) -> String {
        let requiresNamePrefix =
            consequence.effectiveTargetScope != .actingCharacter || targetID != actingCharacterID
        guard requiresNamePrefix,
              let name = gameState.party.first(where: { $0.id == targetID })?.name else {
            return message
        }

        return message
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in
                line.isEmpty ? "\(name):" : "\(name): \(line)"
            }
            .joined(separator: "\n")
    }

    private func movementMessage(for consequence: Consequence, destination: String) -> String {
        switch consequence.effectiveTargetScope {
        case .actingCharacter:
            return "Moved to \(destination)."
        case .allHere:
            return "Moved everyone here to \(destination)."
        case .othersHere:
            return "Moved others here to \(destination)."
        case .allParty:
            return "Moved the whole party to \(destination)."
        }
    }

    private func resolveSpawnInteractable(from consequence: Consequence) -> Interactable? {
        if let interactable = consequence.newInteractable {
            return interactable
        }

        if let templateID = consequence.interactableTemplateID {
            if let template = runtime.resolveInteractableTemplate(id: templateID) {
                return template
            }
            print("WARNING: Attempted to spawn missing interactable template '\(templateID)'.")
        }

        return nil
    }

    private func resolveTriggeredEvent(
        _ eventID: String,
        context: ConsequenceContext,
        includeEventDescription: Bool,
        gameState: GameState
    ) -> EventResolution {
        guard let event = content.eventDict[eventID] else {
            if debugLogging {
                print("[Consequences] Missing authored event '\(eventID)'")
            }
            return EventResolution(status: .missing, description: nil, consequences: [])
        }

        guard let character = context.character(in: gameState) else {
            return EventResolution(status: .skipped, description: nil, consequences: [])
        }

        if !areConditionsMet(
            conditions: event.conditions,
            forCharacter: character,
            finalEffect: context.finalEffect,
            finalPosition: context.finalPosition,
            gameState: gameState
        ) {
            if debugLogging {
                print("[Consequences] Skipping event '\(eventID)' due to unmet conditions")
            }
            return EventResolution(status: .skipped, description: nil, consequences: [])
        }

        return EventResolution(
            status: .executed,
            description: includeEventDescription ? event.description : nil,
            consequences: event.consequences
        )
    }

    private func prepend(
        _ queuedFrames: [QueuedFrame],
        to resolution: inout PendingConsequenceResolution
    ) {
        for frame in queuedFrames.reversed() {
            resolution.frames.insert(
                ConsequenceResolutionFrame(
                    context: frame.context,
                    remainingConsequences: frame.consequences
                ),
                at: 0
            )
        }
    }

    private func enqueueAfterCurrentFrame(
        _ queuedFrame: QueuedFrame,
        to resolution: inout PendingConsequenceResolution
    ) {
        let insertionIndex = min(1, resolution.frames.count)
        resolution.frames.insert(
            ConsequenceResolutionFrame(
                context: queuedFrame.context,
                remainingConsequences: queuedFrame.consequences
            ),
            at: insertionIndex
        )
    }

    private func append(_ text: String?, to resolution: inout PendingConsequenceResolution) {
        guard let text, !text.isEmpty else { return }
        resolution.resolvedDescriptions.append(text)
    }

    private func availableChoiceOptions(
        from consequence: Consequence,
        context: ConsequenceContext,
        gameState: GameState
    ) -> [ChoiceOption] {
        guard consequence.kind == .createChoice,
              let character = context.character(in: gameState),
              let options = consequence.choiceOptions else {
            return []
        }

        return options.filter { option in
            areConditionsMet(
                conditions: option.conditions,
                forCharacter: character,
                finalEffect: context.finalEffect,
                finalPosition: context.finalPosition,
                gameState: gameState
            )
        }
    }

    private func resolveResistanceRoll(
        attribute: ResistanceAttribute,
        for character: Character,
        usingDice diceResults: [Int]?
    ) -> ResistanceRollOutcome {
        let pool = attribute.dicePool(for: character)
        let diceRolled: [Int]
        let highestRoll: Int

        if pool > 0 {
            if let diceResults, !diceResults.isEmpty {
                diceRolled = diceResults
            } else {
                diceRolled = (0..<pool).map { _ in Int.random(in: 1...6) }
            }
            highestRoll = diceRolled.max() ?? 1
        } else {
            let fallbackRolls = diceResults?.prefix(2) ?? []
            if fallbackRolls.count == 2 {
                diceRolled = Array(fallbackRolls)
            } else {
                diceRolled = [Int.random(in: 1...6), Int.random(in: 1...6)]
            }
            highestRoll = diceRolled.min() ?? 1
        }

        return ResistanceRollOutcome(
            attribute: attribute,
            diceRolled: diceRolled,
            highestRoll: highestRoll,
            stressCost: max(0, 6 - highestRoll)
        )
    }

    private func resistanceRule(for consequence: Consequence) -> ResistanceRule? {
        if let explicitRule = consequence.resistance {
            switch consequence.kind {
            case .createChoice:
                return nil
            case .sufferHarm:
                return (consequence.level != nil && consequence.familyId != nil) ? explicitRule : nil
            case .gainStress, .adjustStress, .tickClock, .incrementScenarioCounter:
                return (consequence.amount ?? 0) > 0 ? explicitRule : nil
            default:
                return explicitRule
            }
        }

        switch consequence.kind {
        case .sufferHarm:
            return (consequence.level != nil && consequence.familyId != nil)
                ? ResistanceRule(attribute: .prowess, amount: 1)
                : nil
        case .gainStress, .adjustStress:
            let amount = consequence.amount ?? 0
            return amount > 0 ? ResistanceRule(attribute: .resolve, amount: 2) : nil
        case .tickClock:
            let amount = consequence.amount ?? 0
            return amount > 0 ? ResistanceRule(attribute: .insight, amount: 2) : nil
        default:
            return nil
        }
    }

    private func makePendingResistanceState(
        for consequence: Consequence,
        context: ConsequenceContext,
        gameState: GameState,
        sequenceIndex: Int = 1,
        sequenceTotal: Int = 1
    ) -> PendingResistanceState? {
        guard let resistanceRule = resistanceRule(for: consequence) else { return nil }

        let trimmedPrompt = consequence.description?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let prompt = (trimmedPrompt?.isEmpty == false) ? trimmedPrompt : nil

        return PendingResistanceState(
            consequence: consequence,
            prompt: prompt,
            attribute: resistanceRule.attribute,
            title: falloutTitle(for: consequence, gameState: gameState),
            summary: falloutSummary(for: consequence, gameState: gameState, futureTense: true),
            resistPreview: resistancePreview(
                for: consequence,
                attribute: resistanceRule.attribute,
                gameState: gameState
            ),
            sequenceIndex: sequenceIndex,
            sequenceTotal: sequenceTotal
        )
    }

    private func countUpcomingVisibleResistances(
        in pendingResolution: PendingConsequenceResolution,
        gameState: GameState
    ) -> Int {
        var count = 0

        for frame in pendingResolution.frames {
            guard let character = frame.context.character(in: gameState) else { continue }

            for consequence in frame.remainingConsequences {
                if consequence.kind == .createChoice {
                    let availableOptions = availableChoiceOptions(
                        from: consequence,
                        context: frame.context,
                        gameState: gameState
                    )
                    if !availableOptions.isEmpty {
                        return count
                    }
                    continue
                }

                guard areConditionsMet(
                    conditions: consequence.conditions,
                    forCharacter: character,
                    finalEffect: frame.context.finalEffect,
                    finalPosition: frame.context.finalPosition,
                    gameState: gameState
                ) else {
                    continue
                }

                if resistanceRule(for: consequence) != nil {
                    count += 1
                }
            }
        }

        return count
    }

    private func falloutTitle(for consequence: Consequence, gameState: GameState) -> String {
        switch consequence.kind {
        case .sufferHarm:
            if let level = consequence.level {
                return "\(level.rawValue.capitalized) Harm"
            }
            return "Harm"
        case .gainStress, .adjustStress:
            let amount = consequence.amount ?? 0
            if amount > 0 {
                return "+\(amount) Stress"
            } else if amount < 0 {
                return "Recover \(abs(amount)) Stress"
            }
            return "Stress"
        case .tickClock:
            let amount = consequence.amount ?? 0
            if let clockName = consequence.clockName, amount > 0 {
                return "\(clockName) +\(amount)"
            }
            return amount > 0 ? "Clock +\(amount)" : "Clock"
        case .moveActingCharacterToNode:
            return "Forced Move"
        case .lockConnection:
            return "Route Cut Off"
        case .unlockConnection:
            return "Route Opens"
        case .removeTreasure:
            if let treasureID = consequence.treasureId {
                return "Lose \(treasureName(for: treasureID, gameState: gameState))"
            }
            return "Lose Treasure"
        case .removeTreasureWithTag:
            if let tag = consequence.tag {
                return "Lose \(readableIdentifier(tag)) Treasure"
            }
            return "Lose Tagged Treasure"
        case .removeModifier:
            return "Lose Modifier"
        case .grantModifier:
            return "Modifier Applied"
        case .modifyDice:
            let amount = consequence.amount ?? 0
            if amount > 0 {
                return "+\(amount)d"
            } else if amount < 0 {
                return "\(amount)d"
            }
            return "Dice Shift"
        case .setScenarioFlag:
            return consequence.flagId.map { "\(readableIdentifier($0)) Set" } ?? "Flag Set"
        case .clearScenarioFlag:
            return consequence.flagId.map { "\(readableIdentifier($0)) Cleared" } ?? "Flag Cleared"
        case .incrementScenarioCounter:
            if let counterID = consequence.counterId {
                return "\(readableIdentifier(counterID)) +\(consequence.amount ?? 1)"
            }
            return "Counter Advances"
        case .setScenarioCounter:
            if let counterID = consequence.counterId {
                return "\(readableIdentifier(counterID)) = \(consequence.amount ?? 0)"
            }
            return "Counter Set"
        case .addCharacterTag:
            return consequence.tag.map { "Gain \(readableIdentifier($0))" } ?? "Gain Tag"
        case .removeCharacterTag:
            return consequence.tag.map { "Lose \(readableIdentifier($0))" } ?? "Lose Tag"
        case .endRun:
            return "Run Ends"
        case .triggerEvent, .triggerConsequences:
            return "Triggered Fallout"
        default:
            if let description = trimmedDescription(for: consequence) {
                return description
            }
            return "Consequence"
        }
    }

    private func falloutSummary(
        for consequence: Consequence,
        gameState: GameState,
        futureTense: Bool
    ) -> String {
        switch consequence.kind {
        case .sufferHarm:
            let levelText = consequence.level?.rawValue.capitalized ?? "Unknown"
            let harmText = harmDescription(for: consequence, gameState: gameState)
            if consequence.effectiveTargetScope != .actingCharacter {
                return "\(falloutSubject(for: consequence, futureTense: futureTense)) suffer \(levelText) Harm: \(harmText)."
            }
            if futureTense {
                return "You would suffer \(levelText) Harm: \(harmText)."
            }
            return "\(levelText) Harm: \(harmText)."
        case .gainStress, .adjustStress:
            let amount = consequence.amount ?? 0
            if amount > 0 {
                if consequence.effectiveTargetScope != .actingCharacter {
                    return "\(falloutSubject(for: consequence, futureTense: futureTense)) take \(amount) Stress."
                }
                if futureTense {
                    return "You would take \(amount) Stress."
                }
                return "+\(amount) Stress."
            } else if amount < 0 {
                if consequence.effectiveTargetScope != .actingCharacter {
                    return "\(falloutSubject(for: consequence, futureTense: futureTense)) recover \(abs(amount)) Stress."
                }
                if futureTense {
                    return "You would recover \(abs(amount)) Stress."
                }
                return "Recover \(abs(amount)) Stress."
            }
            return futureTense ? "Your Stress would change." : "Stress changes."
        case .tickClock:
            let clockName = consequence.clockName ?? "A clock"
            let amount = consequence.amount ?? 0
            if futureTense {
                return "\(clockName) advances by \(amount)."
            }
            return "\(clockName) +\(amount)."
        case .moveActingCharacterToNode:
            let destination = destinationName(for: consequence, gameState: gameState)
            if consequence.effectiveTargetScope != .actingCharacter {
                return "\(falloutSubject(for: consequence, futureTense: futureTense)) be forced to \(destination)."
            }
            return futureTense ? "You would be forced to \(destination)." : "Forced to \(destination)."
        case .lockConnection:
            let route = routeDescription(for: consequence, gameState: gameState)
            return futureTense ? "\(route) would close." : "\(route) closes."
        case .unlockConnection:
            let route = routeDescription(for: consequence, gameState: gameState)
            return futureTense ? "\(route) would open." : "\(route) opens."
        case .removeTreasure:
            if let treasureID = consequence.treasureId {
                let name = treasureName(for: treasureID, gameState: gameState)
                return futureTense ? "You would lose \(name)." : "Lose \(name)."
            }
            return futureTense ? "You would lose a treasure." : "Lose a treasure."
        case .removeTreasureWithTag:
            if let tag = consequence.tag {
                return futureTense
                    ? "You would lose a \(readableIdentifier(tag)) treasure."
                    : "Lose a \(readableIdentifier(tag)) treasure."
            }
            return futureTense ? "You would lose a tagged treasure." : "Lose a tagged treasure."
        case .removeModifier:
            let modifierName = consequence.sourceKey.map(readableIdentifier) ?? "a modifier"
            if consequence.effectiveTargetScope != .actingCharacter {
                return "\(falloutSubject(for: consequence, futureTense: futureTense)) lose \(modifierName)."
            }
            return futureTense ? "You would lose \(modifierName)." : "Lose \(modifierName)."
        case .grantModifier:
            let modifierText = consequence.modifier?.longDescription ?? "a modifier"
            if consequence.effectiveTargetScope != .actingCharacter {
                return "\(falloutSubject(for: consequence, futureTense: futureTense)) gain \(modifierText)."
            }
            return futureTense ? "You would gain \(modifierText)." : "Gain \(modifierText)."
        case .modifyDice:
            let amount = consequence.amount ?? 0
            let duration = consequence.duration ?? "next roll"
            let diceText = amount > 0 ? "+\(amount)d" : "\(amount)d"
            if consequence.effectiveTargetScope != .actingCharacter {
                return "\(falloutSubject(for: consequence, futureTense: futureTense)) roll with \(diceText) for \(duration)."
            }
            return futureTense
                ? "Your roll would shift by \(diceText) for \(duration)."
                : "Roll shifts by \(diceText) for \(duration)."
        case .setScenarioFlag:
            let flagName = consequence.flagId.map(readableIdentifier) ?? "a flag"
            return futureTense ? "\(flagName) would be set." : "\(flagName) is set."
        case .clearScenarioFlag:
            let flagName = consequence.flagId.map(readableIdentifier) ?? "a flag"
            return futureTense ? "\(flagName) would be cleared." : "\(flagName) is cleared."
        case .incrementScenarioCounter:
            let counterName = consequence.counterId.map(readableIdentifier) ?? "A counter"
            let amount = consequence.amount ?? 1
            if amount >= 0 {
                return futureTense ? "\(counterName) increases by \(amount)." : "\(counterName) +\(amount)."
            }
            return futureTense ? "\(counterName) decreases by \(abs(amount))." : "\(counterName) \(amount)."
        case .setScenarioCounter:
            let counterName = consequence.counterId.map(readableIdentifier) ?? "A counter"
            let amount = consequence.amount ?? 0
            return futureTense ? "\(counterName) would be set to \(amount)." : "\(counterName) = \(amount)."
        case .addCharacterTag:
            let tagName = consequence.tag.map(readableIdentifier) ?? "a tag"
            if consequence.effectiveTargetScope != .actingCharacter {
                return "\(falloutSubject(for: consequence, futureTense: futureTense)) gain \(tagName)."
            }
            return futureTense ? "You would gain \(tagName)." : "Gain \(tagName)."
        case .removeCharacterTag:
            let tagName = consequence.tag.map(readableIdentifier) ?? "a tag"
            if consequence.effectiveTargetScope != .actingCharacter {
                return "\(falloutSubject(for: consequence, futureTense: futureTense)) lose \(tagName)."
            }
            return futureTense ? "You would lose \(tagName)." : "Lose \(tagName)."
        case .endRun:
            return futureTense ? "The expedition would end." : "The expedition ends."
        case .triggerEvent, .triggerConsequences:
            if let description = trimmedDescription(for: consequence) {
                return description
            }
            return futureTense ? "Additional fallout would trigger." : "Additional fallout triggers."
        default:
            if let description = trimmedDescription(for: consequence) {
                return description
            }
            return futureTense ? "This consequence would apply." : "This consequence applies."
        }
    }

    private func resistancePreview(
        for consequence: Consequence,
        attribute: ResistanceAttribute,
        gameState: GameState
    ) -> String {
        guard let mitigated = mitigatedConsequence(from: consequence, using: attribute) else {
            switch consequence.kind {
            case .moveActingCharacterToNode:
                return "Resist: hold your ground."
            case .lockConnection:
                return "Resist: keep the route open."
            case .removeTreasure:
                if let treasureID = consequence.treasureId {
                    return "Resist: keep \(treasureName(for: treasureID, gameState: gameState))."
                }
                return "Resist: keep your treasure."
            case .removeTreasureWithTag:
                return "Resist: keep that treasure."
            case .removeModifier:
                return "Resist: keep this modifier."
            case .modifyDice:
                let amount = consequence.amount ?? 0
                if amount < 0 {
                    return "Resist: avoid the dice penalty."
                }
                return "Resist: avoid this."
            case .setScenarioFlag, .clearScenarioFlag, .incrementScenarioCounter, .setScenarioCounter,
                 .triggerEvent, .triggerConsequences:
                return "Resist: stop this escalation."
            case .addCharacterTag:
                if let tag = consequence.tag {
                    return "Resist: avoid gaining \(readableIdentifier(tag))."
                }
                return "Resist: avoid this mark."
            case .removeCharacterTag:
                if let tag = consequence.tag {
                    return "Resist: keep \(readableIdentifier(tag))."
                }
                return "Resist: keep this edge."
            case .endRun:
                return "Resist: keep the expedition alive."
            default:
                return "Resist: avoid this."
            }
        }

        switch mitigated.kind {
        case .sufferHarm:
            if let level = mitigated.level {
                if mitigated.effectiveTargetScope != .actingCharacter {
                    return "Resist: reduce \(resistanceTarget(for: mitigated)) to \(level.rawValue.capitalized) Harm."
                }
                return "Resist: reduce to \(level.rawValue.capitalized) Harm."
            }
            return "Resist: reduce this Harm."
        case .gainStress, .adjustStress:
            let amount = mitigated.amount ?? 0
            if amount > 0 {
                if mitigated.effectiveTargetScope != .actingCharacter {
                    return "Resist: reduce \(resistanceTarget(for: mitigated)) to +\(amount) Stress."
                }
                return "Resist: reduce to +\(amount) Stress."
            }
            return "Resist: avoid this."
        case .tickClock:
            let amount = mitigated.amount ?? 0
            if let clockName = mitigated.clockName {
                return "Resist: reduce to \(clockName) +\(amount)."
            }
            return "Resist: reduce this clock by \(amount)."
        case .modifyDice:
            let amount = mitigated.amount ?? 0
            if amount > 0 {
                return "Resist: reduce to +\(amount)d."
            } else if amount < 0 {
                return "Resist: reduce to \(amount)d."
            }
            return "Resist: avoid this."
        case .incrementScenarioCounter:
            let amount = mitigated.amount ?? 0
            if let counterID = mitigated.counterId {
                return "Resist: reduce to \(readableIdentifier(counterID)) +\(amount)."
            }
            return "Resist: reduce this increase to +\(amount)."
        default:
            return "Resist: avoid this."
        }
    }

    private func harmDescription(for consequence: Consequence, gameState: GameState) -> String {
        guard let familyID = consequence.familyId else { return "Unknown Harm" }
        guard let family = content.harmFamilyDict[familyID] else { return familyID }

        switch consequence.level {
        case .lesser:
            return family.lesser.description
        case .moderate:
            return family.moderate.description
        case .severe:
            return family.severe.description
        case .none:
            return family.lesser.description
        }
    }

    private func falloutSubject(for consequence: Consequence, futureTense: Bool) -> String {
        switch consequence.effectiveTargetScope {
        case .actingCharacter:
            return futureTense ? "You would" : "You"
        case .allHere:
            return futureTense ? "Everyone here would" : "Everyone here"
        case .othersHere:
            return futureTense ? "Others here would" : "Others here"
        case .allParty:
            return futureTense ? "The whole party would" : "The whole party"
        }
    }

    private func resistanceTarget(for consequence: Consequence) -> String {
        switch consequence.effectiveTargetScope {
        case .actingCharacter:
            return "this"
        case .allHere:
            return "everyone here"
        case .othersHere:
            return "others here"
        case .allParty:
            return "the whole party"
        }
    }

    private func trimmedDescription(for consequence: Consequence) -> String? {
        let trimmed = consequence.description?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }

    private func destinationName(for consequence: Consequence, gameState: GameState) -> String {
        guard let nodeID = consequence.toNodeID,
              let name = gameState.dungeon?.nodes[nodeID.uuidString]?.name else {
            return "another room"
        }
        return name
    }

    private func routeDescription(for consequence: Consequence, gameState: GameState) -> String {
        guard let fromNodeID = consequence.fromNodeID,
              let toNodeID = consequence.toNodeID else {
            return "A route"
        }

        let fromName = gameState.dungeon?.nodes[fromNodeID.uuidString]?.name ?? "one room"
        let toName = gameState.dungeon?.nodes[toNodeID.uuidString]?.name ?? "another room"
        return "The route between \(fromName) and \(toName)"
    }

    private func treasureName(for treasureID: String, gameState: GameState) -> String {
        for member in gameState.party {
            if let treasure = member.treasures.first(where: { $0.id == treasureID }) {
                return treasure.name
            }
        }

        if let template = content.treasureTemplates.first(where: { $0.id == treasureID }) {
            return template.name
        }

        return readableIdentifier(treasureID)
    }

    private func readableIdentifier(_ identifier: String) -> String {
        identifier
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }

    private func mitigatedConsequence(
        from consequence: Consequence,
        using attribute: ResistanceAttribute
    ) -> Consequence? {
        let rule = consequence.effectiveResistanceRule

        switch consequence.kind {
        case .sufferHarm:
            guard let level = consequence.level else { return nil }
            let reduction = max(rule?.amount ?? 1, 1)
            guard let reducedLevel = downgraded(level: level, by: reduction) else {
                return nil
            }
            var adjusted = consequence
            adjusted.level = reducedLevel
            adjusted.resistance = nil
            return adjusted
        case .gainStress, .adjustStress:
            let reduction = max(rule?.amount ?? 2, 0)
            let newAmount = max(0, (consequence.amount ?? 0) - reduction)
            guard newAmount > 0 else { return nil }
            var adjusted = consequence
            adjusted.amount = newAmount
            adjusted.resistance = nil
            return adjusted
        case .tickClock:
            let reduction = max(rule?.amount ?? 2, 0)
            let newAmount = max(0, (consequence.amount ?? 0) - reduction)
            guard newAmount > 0 else { return nil }
            var adjusted = consequence
            adjusted.amount = newAmount
            adjusted.resistance = nil
            return adjusted
        case .incrementScenarioCounter:
            let reduction = max(rule?.amount ?? 1, 0)
            let newAmount = max(0, (consequence.amount ?? 0) - reduction)
            guard newAmount > 0 else { return nil }
            var adjusted = consequence
            adjusted.amount = newAmount
            adjusted.resistance = nil
            return adjusted
        case .modifyDice:
            let reduction = max(rule?.amount ?? 1, 0)
            let amount = consequence.amount ?? 0
            let newAmount: Int
            if amount < 0 {
                newAmount = min(0, amount + reduction)
            } else {
                newAmount = max(0, amount - reduction)
            }
            guard newAmount != 0 else { return nil }
            var adjusted = consequence
            adjusted.amount = newAmount
            adjusted.resistance = nil
            return adjusted
        default:
            _ = attribute
            return nil
        }
    }

    private func downgraded(level: HarmLevel, by reduction: Int) -> HarmLevel? {
        guard reduction > 0 else { return level }

        let levels: [HarmLevel] = [.lesser, .moderate, .severe]
        guard let currentIndex = levels.firstIndex(of: level) else { return nil }
        let targetIndex = currentIndex - reduction
        guard targetIndex >= 0 else { return nil }
        return levels[targetIndex]
    }
}

struct PendingResolutionDriver {
    private let executor: ConsequenceExecutor

    init(
        runtime: ScenarioRuntime,
        debugLogging: Bool
    ) {
        self.executor = ConsequenceExecutor(
            debugLogging: debugLogging,
            runtime: runtime
        )
    }

    func previewUpcomingResistances(
        in gameState: GameState,
        limit: Int = 3
    ) -> [PendingResistanceState] {
        guard let pendingResolution = gameState.pendingResolution else { return [] }
        return executor.previewUpcomingResistances(
            in: pendingResolution,
            gameState: gameState,
            limit: limit
        )
    }

    @discardableResult
    func choosePendingChoice(
        at index: Int,
        in gameState: inout GameState
    ) -> String {
        guard let pendingResolution = gameState.pendingResolution else { return "" }
        let result = executor.chooseOption(
            at: index,
            in: pendingResolution,
            gameState: &gameState
        )
        gameState.pendingResolution = result.pendingResolution
        return result.description
    }

    @discardableResult
    func acceptPendingResistance(
        in gameState: inout GameState
    ) -> String {
        guard let pendingResolution = gameState.pendingResolution else { return "" }
        let result = executor.acceptResistance(
            in: pendingResolution,
            gameState: &gameState
        )
        gameState.pendingResolution = result.pendingResolution
        return result.description
    }

    @discardableResult
    func resistPendingConsequence(
        usingDice diceResults: [Int]? = nil,
        in gameState: inout GameState
    ) -> ConsequenceExecutor.ResistanceRollOutcome? {
        guard let pendingResolution = gameState.pendingResolution else { return nil }
        guard let (result, rollOutcome) = executor.resist(
            in: pendingResolution,
            usingDice: diceResults,
            gameState: &gameState
        ) else {
            return nil
        }
        gameState.pendingResolution = result.pendingResolution
        return rollOutcome
    }

    @discardableResult
    func processConsequences(
        _ consequences: [Consequence],
        context: ConsequenceContext,
        source: ResolutionSource,
        rollPresentation: PendingRollPresentation?,
        in gameState: inout GameState
    ) -> String {
        let result = executor.process(
            consequences,
            context: context,
            source: source,
            rollPresentation: rollPresentation,
            gameState: &gameState
        )
        gameState.pendingResolution = result.pendingResolution
        return result.description
    }

    func areConditionsMet(
        conditions: [GameCondition]?,
        forCharacter character: Character,
        finalEffect: RollEffect,
        finalPosition: RollPosition,
        in gameState: GameState
    ) -> Bool {
        executor.areConditionsMet(
            conditions: conditions,
            forCharacter: character,
            finalEffect: finalEffect,
            finalPosition: finalPosition,
            gameState: gameState
        )
    }

    func checkStressOverflow(
        for index: Int,
        in gameState: inout GameState
    ) -> String? {
        executor.checkStressOverflow(for: index, gameState: &gameState)
    }
}
