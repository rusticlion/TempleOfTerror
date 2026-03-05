import SwiftUI

struct RollProjectionDetails {
    var baseDiceCount: Int
    var finalDiceCount: Int
    var rawDicePool: Int
    var basePosition: RollPosition
    var finalPosition: RollPosition
    var baseEffect: RollEffect
    var finalEffect: RollEffect
    var notes: [String]
}

/// Lightweight info about a selectable modifier for the DiceRollView.
struct SelectableModifierInfo: Identifiable {
    let id: UUID
    let description: String
    let detailedEffect: String
    let remainingUses: String
    let modifierData: Modifier
}

@MainActor
enum PartyMovementMode {
    case grouped
    case solo
}

class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var partyMovementMode: PartyMovementMode = .grouped
    @Published var debugFixedDiceEnabled: Bool = false
    @Published var debugFixedDiceValues: [Int] = [6]

    /// Enable verbose logging when processing consequences.
    static var debugConsequences = true
    private let rollRules = RollRulesEngine()
    private let runtime: ScenarioRuntime
    private let saveStore: SaveGameStore

    private func makeConsequenceExecutor() -> ConsequenceExecutor {
        ConsequenceExecutor(debugLogging: Self.debugConsequences, runtime: runtime)
    }

    private func syncAmbientAudio(for node: MapNode?) {
        guard let node else { return }
        AudioManager.shared.play(sound: "ambient_\(node.soundProfile).wav", loop: true)
    }

    /// Whether a saved game exists on disk.
    static var saveExists: Bool {
        SaveGameStore().saveExists()
    }


    // Retrieve the node a specific character is currently in
    func node(for characterID: UUID?) -> MapNode? {
        runtime.node(for: characterID, in: gameState)
    }


    /// Initialize a blank view model intended for loading a game.
    init(runtime: ScenarioRuntime = ScenarioRuntime(), saveStore: SaveGameStore = SaveGameStore()) {
        self.gameState = GameState()
        self.runtime = runtime
        self.saveStore = saveStore
    }

    /// Initialize and immediately start a new game with the given scenario.
    init(startNewWithScenario scenario: String,
         partyPlan: PartyBuildPlan? = nil,
         runtime: ScenarioRuntime = ScenarioRuntime(),
         saveStore: SaveGameStore = SaveGameStore()) {
        self.gameState = GameState()
        self.runtime = runtime
        self.saveStore = saveStore
        startNewRun(scenario: scenario, partyPlan: partyPlan)
    }

    /// Persist the current game state to disk.
    func saveGame() {
        do {
            print("Attempting to save game to: \(saveStore.saveURL.path)")
            try saveStore.save(gameState)
        } catch {
            print("Failed to save game: \(error)")
        }
    }

    /// Attempt to load a saved game from disk. Returns `true` on success.
    func loadGame() -> Bool {
        guard saveStore.saveExists() else { return false }
        do {
            let loaded = try saveStore.load()
            self.gameState = runtime.prepareLoadedState(loaded)
            if let anyID = gameState.characterLocations.first?.value {
                syncAmbientAudio(for: gameState.dungeon?.nodes[anyID.uuidString])
            }
            return true
        } catch {
            print("Failed to load game: \(error)")
            return false
        }
    }

    // --- Core Logic Functions for the Sprint ---

    func calculateProjection(for action: ActionOption, with character: Character, interactableTags tags: [String] = []) -> RollProjectionDetails {
        rollRules.calculateProjection(for: action, with: character, interactableTags: tags)
    }

    func getRollContext(for action: ActionOption, with character: Character, interactableTags tags: [String] = []) -> (baseProjection: RollProjectionDetails, optionalModifiers: [SelectableModifierInfo]) {
        rollRules.getRollContext(for: action, with: character, interactableTags: tags)
    }

    func calculateEffectiveProjection(baseProjection: RollProjectionDetails, applying chosenModifierStructs: [Modifier]) -> RollProjectionDetails {
        rollRules.calculateEffectiveProjection(baseProjection: baseProjection, applying: chosenModifierStructs)
    }

    func clearPendingResolution() {
        gameState.pendingResolution = nil
        saveGame()
    }

    func pendingResolutionText() -> String {
        gameState.pendingResolution?.resolvedText ?? ""
    }

    private func appendToPendingResolutionLog(_ text: String) {
        guard !text.isEmpty, gameState.pendingResolution != nil else { return }
        gameState.pendingResolution?.resolvedDescriptions.append(text)
    }

    func pendingResolutionCharacter() -> Character? {
        guard let context = gameState.pendingResolution?.activeContext else { return nil }
        return context.character(in: gameState)
    }

    func pendingResistanceAttribute() -> ResistanceAttribute? {
        gameState.pendingResolution?.pendingResistance?.attribute
    }

    func pendingResistanceDicePool() -> Int? {
        guard let attribute = pendingResistanceAttribute(),
              let character = pendingResolutionCharacter() else { return nil }
        return attribute.dicePool(for: character)
    }

    @discardableResult
    func choosePendingChoice(at index: Int) -> String {
        guard let pendingResolution = gameState.pendingResolution else { return "" }
        let executor = makeConsequenceExecutor()
        let result = executor.chooseOption(at: index, in: pendingResolution, gameState: &gameState)
        gameState.pendingResolution = result.pendingResolution
        saveGame()
        return result.description
    }

    @discardableResult
    func acceptPendingResistance() -> String {
        guard let pendingResolution = gameState.pendingResolution else { return "" }
        let executor = makeConsequenceExecutor()
        let result = executor.acceptResistance(in: pendingResolution, gameState: &gameState)
        gameState.pendingResolution = result.pendingResolution
        saveGame()
        return result.description
    }

    @discardableResult
    func resistPendingConsequence(usingDice diceResults: [Int]? = nil) -> ConsequenceExecutor.ResistanceRollOutcome? {
        guard let pendingResolution = gameState.pendingResolution else { return nil }
        let executor = makeConsequenceExecutor()
        let resolvedDice = diceResults ?? debugResistanceDiceOverride()
        guard let (result, rollOutcome) = executor.resist(
            in: pendingResolution,
            usingDice: resolvedDice,
            gameState: &gameState
        ) else {
            return nil
        }
        gameState.pendingResolution = result.pendingResolution
        saveGame()
        return rollOutcome
    }

    /// Executes a free action that does not require a roll, applying its success
    /// consequences immediately.
    func performFreeAction(for action: ActionOption, with character: Character, interactableID: String?) -> String {
        let consequences = action.outcomes[.success] ?? []
        let context = ConsequenceContext(characterID: character.id,
                                         interactableID: interactableID,
                                         finalEffect: action.effect,
                                         finalPosition: action.position,
                                         isCritical: false)
        let description = processConsequences(consequences, context: context, source: .freeAction, rollPresentation: nil)
        saveGame()
        return description
    }

    /// The main dice roll function, now returns the result for the UI.
    func performAction(for action: ActionOption,
                       with character: Character,
                       interactableID: String?,
                       usingDice diceResults: [Int]? = nil,
                       chosenOptionalModifierIDs: [UUID] = []) -> DiceRollResult {
        if action.isGroupAction {
            return performGroupAction(for: action, leader: character, interactableID: interactableID)
        }
        guard let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) else {
            return DiceRollResult(highestRoll: 0,
                                  outcome: "Error",
                                  consequences: "Character not found.",
                                  actualDiceRolled: nil,
                                  isCritical: nil,
                                  finalEffect: nil,
                                  isAwaitingDecision: false)
        }

        var tags: [String] = []
        if let id = interactableID,
           let nodeID = gameState.characterLocations[character.id.uuidString],
           let interactable = gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.first(where: { $0.id == id }) {
            tags = interactable.tags
        }

        let context = getRollContext(for: action, with: character, interactableTags: tags)
        var workingProjection = context.baseProjection

        var appliedOptionalMods: [Modifier] = []
        var consumedMessages: [String] = []

        let pushModifierIDs = Set(
            context.optionalModifiers
                .filter { $0.description == "Push Yourself" }
                .map(\.id)
        )
        let mutableChosenIDs = chosenOptionalModifierIDs.filter { !pushModifierIDs.contains($0) }
        let contextModifiersByID = Dictionary(uniqueKeysWithValues: context.optionalModifiers.map { ($0.id, $0.modifierData) })

        if chosenOptionalModifierIDs.contains(where: { pushModifierIDs.contains($0) }) {
            let pushCost = rollRules.pushStressCost(for: gameState.party[charIndex], interactableTags: tags)
            if gameState.party[charIndex].stress + pushCost <= 9 {
                appliedOptionalMods.append(Modifier(bonusDice: 1, uses: 1, isOptionalToApply: true, description: "Push Yourself"))
                gameState.party[charIndex].stress += pushCost
                _ = checkStressOverflow(for: charIndex)
            }
        }

        // Consume any chosen modifiers with limited uses
        var modsToKeep: [Modifier] = []
        var consumedModIDs: [UUID] = []
        for var mod in gameState.party[charIndex].modifiers {
            if mutableChosenIDs.contains(mod.id) {
                appliedOptionalMods.append(mod) // Add to projection calculation
                if mod.uses > 0 {
                    mod.uses -= 1
                    if mod.uses == 0 {
                        consumedModIDs.append(mod.id)
                        let name = mod.description.replacingOccurrences(of: "from ", with: "")
                        consumedMessages.append("Used up \(name).")
                        // Don't add it to modsToKeep
                        continue
                    }
                }
            }
            modsToKeep.append(mod)
        }
        gameState.party[charIndex].modifiers = modsToKeep

        for modifierID in mutableChosenIDs where !appliedOptionalMods.contains(where: { $0.id == modifierID }) {
            if let contextModifier = contextModifiersByID[modifierID] {
                appliedOptionalMods.append(contextModifier)
            }
        }

        // If a consumed modifier came from a treasure, remove the treasure
        gameState.party[charIndex].treasures.removeAll { treasure in
            consumedModIDs.contains(treasure.grantedModifier.id)
        }

        workingProjection = calculateEffectiveProjection(baseProjection: workingProjection, applying: appliedOptionalMods)
        var finalEffect = workingProjection.finalEffect
        let finalPosition = workingProjection.finalPosition
        let resolvedRoll = rollRules.resolveRoll(using: diceResults, rawPool: workingProjection.rawDicePool)
        let outcome = rollRules.outcome(for: resolvedRoll.highestRoll)
        let highestRoll = resolvedRoll.highestRoll
        let isCritical = resolvedRoll.isCritical
        let actualDiceRolled = resolvedRoll.actualDiceRolled
        let consequencesToApply = action.outcomes[outcome.outcome] ?? []
        var consequencesDescription = ""

        if isCritical && highestRoll >= 4 {
            finalEffect = finalEffect.increased()
        }

        let eligible = consequencesToApply.filter { cons in
            areConditionsMet(conditions: cons.conditions,
                             forCharacter: character,
                             finalEffect: finalEffect,
                             finalPosition: finalPosition)
        }
        let consequenceProcessingContext = ConsequenceContext(characterID: character.id,
                                         interactableID: interactableID,
                                         finalEffect: finalEffect,
                                         finalPosition: finalPosition,
                                         isCritical: isCritical)
        let rollPresentation = PendingRollPresentation(
            characterID: character.id,
            actionName: action.name,
            highestRoll: highestRoll,
            outcome: outcome.label,
            actualDiceRolled: actualDiceRolled,
            isCritical: isCritical,
            finalEffect: finalEffect
        )
        consequencesDescription = processConsequences(
            eligible,
            context: consequenceProcessingContext,
            source: .roll,
            rollPresentation: rollPresentation
        )

        if isCritical && highestRoll >= 4 {
            let critMsg = "Critical Success! Effect increased to \(finalEffect.rawValue.capitalized)."
            if consequencesDescription.isEmpty {
                consequencesDescription = critMsg
            } else {
                consequencesDescription += "\n" + critMsg
            }
            appendToPendingResolutionLog(critMsg)
        }
        if !consumedMessages.isEmpty {
            AudioManager.shared.play(sound: "sfx_modifier_consume.wav")
            let consumedText = consumedMessages.joined(separator: "\n")
            if consequencesDescription.isEmpty {
                consequencesDescription = consumedText
            } else {
                consequencesDescription += "\n" + consumedText
            }
            appendToPendingResolutionLog(consumedText)
        }
        saveGame()

        return DiceRollResult(highestRoll: highestRoll,
                              outcome: outcome.label,
                              consequences: consequencesDescription,
                              actualDiceRolled: actualDiceRolled,
                              isCritical: isCritical,
                              finalEffect: finalEffect,
                              isAwaitingDecision: gameState.pendingResolution?.isAwaitingDecision == true)
    }

    private func performGroupAction(for action: ActionOption, leader: Character, interactableID: String?) -> DiceRollResult {
        guard partyMovementMode == .grouped, !isPartyActuallySplit() else {
            return DiceRollResult(highestRoll: 0,
                                  outcome: "Cannot",
                                  consequences: "Party must be together for a group action.",
                                  actualDiceRolled: nil,
                                  isCritical: nil,
                                  finalEffect: nil,
                                  isAwaitingDecision: false)
        }

        var bestRoll = 0
        var failures = 0

        for member in gameState.party where !member.isDefeated {
            let dicePool = max(member.actions[action.actionType] ?? 0, 1)
            var highest = 0
            for _ in 0..<dicePool { highest = max(highest, Int.random(in: 1...6)) }
            bestRoll = max(bestRoll, highest)
            if highest <= 3 { failures += 1 }
        }

        let outcome = rollRules.outcome(for: bestRoll)
        let consequences = action.outcomes[outcome.outcome] ?? []

        let context = ConsequenceContext(characterID: leader.id,
                                         interactableID: interactableID,
                                         finalEffect: action.effect,
                                         finalPosition: action.position,
                                         isCritical: false)
        let rollPresentation = PendingRollPresentation(
            characterID: leader.id,
            actionName: action.name,
            highestRoll: bestRoll,
            outcome: outcome.label,
            actualDiceRolled: nil,
            isCritical: false,
            finalEffect: nil
        )
        var description = processConsequences(
            consequences,
            context: context,
            source: .roll,
            rollPresentation: rollPresentation
        )

        if let leaderIndex = gameState.party.firstIndex(where: { $0.id == leader.id }) {
            gameState.party[leaderIndex].stress += failures
            if let overflow = checkStressOverflow(for: leaderIndex) {
                if !description.isEmpty { description += "\n" }
                description += overflow
                appendToPendingResolutionLog(overflow)
            }
            if failures > 0 {
                if !description.isEmpty { description += "\n" }
                let failureText = "Leader takes \(failures) Stress from allies' slips."
                description += failureText
                appendToPendingResolutionLog(failureText)
            }
        }

        saveGame()
        return DiceRollResult(highestRoll: bestRoll,
                              outcome: outcome.label,
                              consequences: description,
                              actualDiceRolled: nil,
                              isCritical: nil,
                              finalEffect: nil,
                              isAwaitingDecision: gameState.pendingResolution?.isAwaitingDecision == true)
    }

    private func processConsequences(
        _ consequences: [Consequence],
        context: ConsequenceContext,
        source: ResolutionSource,
        rollPresentation: PendingRollPresentation?
    ) -> String {
        let executor = makeConsequenceExecutor()
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

    private func areConditionsMet(
        conditions: [GameCondition]?,
        forCharacter character: Character,
        finalEffect: RollEffect,
        finalPosition: RollPosition
    ) -> Bool {
        let executor = makeConsequenceExecutor()
        return executor.areConditionsMet(
            conditions: conditions,
            forCharacter: character,
            finalEffect: finalEffect,
            finalPosition: finalPosition,
            gameState: gameState
        )
    }

    private func checkStressOverflow(for index: Int) -> String? {
        let executor = makeConsequenceExecutor()
        return executor.checkStressOverflow(for: index, gameState: &gameState)
    }

    func pushYourself(forCharacter character: Character) {
        if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
            let pushCost = rollRules.pushStressCost(for: gameState.party[charIndex], interactableTags: [])
            gameState.party[charIndex].stress += pushCost
            _ = checkStressOverflow(for: charIndex)
        }
    }

    /// Starts a brand new run, resetting the game state. The scenario id
    /// corresponds to a folder within `Content/Scenarios`.
    func startNewRun(scenario: String = "tomb", partyPlan: PartyBuildPlan? = nil) {
        self.gameState = runtime.newGameState(scenario: scenario, partyPlan: partyPlan)
        if let startingNodeID = gameState.dungeon?.startingNodeID {
            syncAmbientAudio(for: gameState.dungeon?.nodes[startingNodeID.uuidString])
        }
        saveGame()
    }

    func restartCurrentScenario() {
        startNewRun(scenario: gameState.scenarioName, partyPlan: gameState.launchPartyPlan)
    }

    /// Check if any party member possesses a treasure with the given tag.
    func partyHasTreasureTag(_ tag: String) -> Bool {
        for member in gameState.party where !member.isDefeated {
            for treasure in member.treasures {
                if treasure.tags.contains(tag) { return true }
            }
        }
        return false
    }


    /// Move one or all party members depending on the current movement mode.
    func move(characterID: UUID, to connection: NodeConnection) {
        let outcome = runtime.move(
            characterID: characterID,
            to: connection,
            movingGroupedParty: partyMovementMode == .grouped,
            in: &gameState
        )
        guard outcome.didMove else { return }
        if let node = outcome.enteredNode {
            syncAmbientAudio(for: node)
        }
        saveGame()
    }

    func getNodeName(for characterID: UUID?) -> String? {
        runtime.nodeName(for: characterID, in: gameState)
    }

    func isPartyActuallySplit() -> Bool {
        runtime.isPartyActuallySplit(in: gameState)
    }

    /// Whether all party members currently share the same node.
    func canRegroup() -> Bool {
        runtime.canRegroup(in: gameState)
    }

    func toggleMovementMode() {
        if partyMovementMode == .grouped {
            partyMovementMode = .solo
        } else {
            if canRegroup() {
                partyMovementMode = .grouped
            }
        }
    }

    var debugFixedDiceSummary: String {
        debugFixedDiceValues.map(String.init).joined(separator: ",")
    }

    @discardableResult
    func setDebugFixedDice(from rawValue: String) -> Bool {
        guard let parsed = Self.parseDebugDiceValues(from: rawValue) else {
            return false
        }
        debugFixedDiceValues = parsed
        return true
    }

    func debugActionDiceOverride(rawPool: Int) -> [Int]? {
        guard debugFixedDiceEnabled else { return nil }
        let diceCount = rawPool <= 0 ? 2 : rawPool
        return expandedDebugDiceValues(forCount: max(diceCount, 1))
    }

    func debugResistanceDiceOverride() -> [Int]? {
        guard debugFixedDiceEnabled else { return nil }
        let pool = pendingResistanceDicePool() ?? 0
        let diceCount = pool > 0 ? pool : 2
        return expandedDebugDiceValues(forCount: max(diceCount, 1))
    }

    @discardableResult
    func debugJumpParty(to nodeID: UUID) -> Bool {
        guard let node = gameState.dungeon?.nodes[nodeID.uuidString] else { return false }
        for member in gameState.party where !member.isDefeated {
            gameState.characterLocations[member.id.uuidString] = nodeID
        }
        gameState.dungeon?.nodes[nodeID.uuidString]?.isDiscovered = true
        gameState.currentNodeID = nodeID
        syncAmbientAudio(for: node)
        saveGame()
        return true
    }

    @discardableResult
    func debugJump(characterID: UUID, to nodeID: UUID) -> Bool {
        guard let node = gameState.dungeon?.nodes[nodeID.uuidString] else { return false }
        gameState.characterLocations[characterID.uuidString] = nodeID
        gameState.dungeon?.nodes[nodeID.uuidString]?.isDiscovered = true
        gameState.currentNodeID = nodeID
        syncAmbientAudio(for: node)
        saveGame()
        return true
    }

    func debugSetFlag(_ flagID: String, isSet: Bool) {
        let trimmed = flagID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if isSet {
            gameState.scenarioFlags[trimmed] = true
        } else {
            gameState.scenarioFlags.removeValue(forKey: trimmed)
        }
        saveGame()
    }

    func debugSetCounter(_ counterID: String, value: Int) {
        let trimmed = counterID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        gameState.scenarioCounters[trimmed] = value
        saveGame()
    }

    func debugAdjustCounter(_ counterID: String, by amount: Int) {
        let trimmed = counterID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        gameState.scenarioCounters[trimmed, default: 0] += amount
        saveGame()
    }

    @discardableResult
    func debugGrantTreasure(_ treasureID: String, to characterID: UUID) -> Bool {
        guard let characterIndex = gameState.party.firstIndex(where: { $0.id == characterID }),
              let treasure = ContentLoader.shared.treasureTemplates.first(where: { $0.id == treasureID }) else {
            return false
        }

        if gameState.party[characterIndex].treasures.contains(where: { $0.id == treasureID }) {
            return false
        }

        gameState.party[characterIndex].treasures.append(treasure)
        if !gameState.party[characterIndex].modifiers.contains(where: { $0.id == treasure.grantedModifier.id }) {
            gameState.party[characterIndex].modifiers.append(treasure.grantedModifier)
        }
        saveGame()
        return true
    }

    @discardableResult
    func debugGrantModifier(
        to characterID: UUID,
        bonusDice: Int = 0,
        improvePosition: Bool = false,
        improveEffect: Bool = false,
        uses: Int = 1,
        description: String
    ) -> Bool {
        guard let characterIndex = gameState.party.firstIndex(where: { $0.id == characterID }) else {
            return false
        }

        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedDescription.isEmpty else {
            return false
        }

        let modifier = Modifier(
            bonusDice: bonusDice,
            improvePosition: improvePosition,
            improveEffect: improveEffect,
            uses: max(uses, 0),
            isOptionalToApply: true,
            description: trimmedDescription
        )
        gameState.party[characterIndex].modifiers.append(modifier)
        saveGame()
        return true
    }

    private static func parseDebugDiceValues(from rawValue: String) -> [Int]? {
        let parts = rawValue
            .split(whereSeparator: { $0 == "," || $0 == " " || $0 == "\n" || $0 == "\t" })
            .map(String.init)

        let values = parts.compactMap(Int.init)
        guard !values.isEmpty else { return nil }
        guard values.allSatisfy({ (1...6).contains($0) }) else { return nil }
        return values
    }

    private func expandedDebugDiceValues(forCount count: Int) -> [Int] {
        let sanitizedValues = debugFixedDiceValues.filter { (1...6).contains($0) }
        let baseValues = sanitizedValues.isEmpty ? [6] : sanitizedValues
        if baseValues.count >= count {
            return Array(baseValues.prefix(count))
        }

        var expanded = baseValues
        while expanded.count < count {
            expanded.append(baseValues[(expanded.count - baseValues.count) % baseValues.count])
        }
        return expanded
    }
}
