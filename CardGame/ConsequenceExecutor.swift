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

    init(debugLogging: Bool, runtime: ScenarioRuntime = ScenarioRuntime()) {
        self.debugLogging = debugLogging
        self.runtime = runtime
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
                resolution.pendingChoice = PendingChoiceState(
                    prompt: consequence.description,
                    options: options
                )
                resolution.requiresAcknowledgement = true
                return ProcessingResult(description: resolution.resolvedText, pendingResolution: resolution)
            }

            if let resistanceRule = resistanceRule(for: consequence) {
                resolution.pendingResistance = PendingResistanceState(
                    consequence: consequence,
                    prompt: consequence.description,
                    attribute: resistanceRule.attribute
                )
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
            if let amount = consequence.amount,
               amount > 0,
               let charIndex = gameState.party.firstIndex(where: { $0.id == actingCharacter.id }) {
                gameState.party[charIndex].stress += amount
                append("Gained \(amount) Stress.", to: &resolution)
                if let overflow = checkStressOverflow(for: charIndex, gameState: &gameState) {
                    append(overflow, to: &resolution)
                }
            }
        case .sufferHarm:
            if let level = consequence.level,
               let familyID = consequence.familyId {
                let harmDescription = applyHarm(
                    familyId: familyID,
                    level: level,
                    toCharacter: actingCharacter.id,
                    gameState: &gameState
                )
                if !narrativeUsed {
                    append(harmDescription, to: &resolution)
                }
            }
        case .healHarm:
            let healDescription = healHarm(forCharacter: actingCharacter.id, gameState: &gameState)
            if !narrativeUsed {
                append(healDescription, to: &resolution)
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
                } else if let clockTemplate = ContentLoader.shared.clockTemplates.first(where: { $0.name == clockName }) {
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
               let interactable = consequence.newInteractable,
               runtime.addInteractable(interactable, inNodeID: nodeID, in: &gameState) {
                if !narrativeUsed {
                    append("Something new appears.", to: &resolution)
                }
            }
        case .addInteractableHere:
            if let interactable = consequence.newInteractable,
               runtime.addInteractableHere(interactable, forCharacterID: partyMemberID, in: &gameState) {
                if !narrativeUsed {
                    append("Something new appears.", to: &resolution)
                }
            }
        case .gainTreasure:
            if let treasureID = consequence.treasureId {
                if let treasure = ContentLoader.shared.treasureTemplates.first(where: { $0.id == treasureID }) {
                    if let charIndex = gameState.party.firstIndex(where: { $0.id == actingCharacter.id }) {
                        gameState.party[charIndex].treasures.append(treasure)
                        gameState.party[charIndex].modifiers.append(treasure.grantedModifier)
                        if !narrativeUsed {
                            append("Gained Treasure: \(treasure.name)!", to: &resolution)
                        }
                    }
                } else {
                    print("Treasure with ID \(treasureID) not found in ContentLoader.shared.treasureTemplates.")
                }
            }
        case .modifyDice:
            if let amount = consequence.amount,
               let charIndex = gameState.party.firstIndex(where: { $0.id == actingCharacter.id }) {
                let duration = consequence.duration ?? "next roll"
                let uses = duration == "next roll" ? 1 : 99
                let modifier = Modifier(
                    bonusDice: amount,
                    uses: uses,
                    description: "Bonus from consequence"
                )
                gameState.party[charIndex].modifiers.append(modifier)
                if !narrativeUsed {
                    append("Gain +\(amount)d for \(duration).", to: &resolution)
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
        gameState: GameState
    ) -> EventResolution {
        guard let event = ContentLoader.shared.eventDict[eventID] else {
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

    private func append(_ text: String?, to resolution: inout PendingConsequenceResolution) {
        guard let text, !text.isEmpty else { return }
        resolution.resolvedDescriptions.append(text)
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
        guard let rule = consequence.effectiveResistanceRule else { return nil }

        switch consequence.kind {
        case .sufferHarm:
            return (consequence.level != nil && consequence.familyId != nil) ? rule : nil
        case .gainStress, .tickClock:
            let amount = consequence.amount ?? 0
            return amount > 0 ? rule : nil
        default:
            return nil
        }
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
        case .gainStress:
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
