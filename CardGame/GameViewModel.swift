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

/// Context information used when processing a list of consequences.
struct ConsequenceContext {
    let character: Character
    let interactableID: String?
    let finalEffect: RollEffect
    let finalPosition: RollPosition
    let isCritical: Bool
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

    /// Enable verbose logging when processing consequences.
    static var debugConsequences = true
    private let rollRules = RollRulesEngine()

    private func makeConsequenceExecutor() -> ConsequenceExecutor {
        ConsequenceExecutor(debugLogging: Self.debugConsequences)
    }

    /// Location of the save file within the app's Documents directory.
    private static var saveURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("savegame.json")
    }

    /// Whether a saved game exists on disk.
    static var saveExists: Bool {
        FileManager.default.fileExists(atPath: saveURL.path)
    }


    // Retrieve the node a specific character is currently in
    func node(for characterID: UUID?) -> MapNode? {
        guard let id = characterID,
              let nodeID = gameState.characterLocations[id.uuidString],
              let map = gameState.dungeon else { return nil }
        return map.nodes[nodeID.uuidString]
    }


    /// Initialize a blank view model intended for loading a game.
    init() {
        self.gameState = GameState()
    }

    /// Initialize and immediately start a new game with the given scenario.
    init(startNewWithScenario scenario: String, partyPlan: PartyBuildPlan? = nil) {
        self.gameState = GameState()
        startNewRun(scenario: scenario, partyPlan: partyPlan)
    }

    /// Persist the current game state to disk.
    func saveGame() {
        do {
            print("Attempting to save game to: \(Self.saveURL.path)")
            try gameState.save(to: Self.saveURL)
        } catch {
            print("Failed to save game: \(error)")
        }
    }

    /// Attempt to load a saved game from disk. Returns `true` on success.
    func loadGame() -> Bool {
        guard Self.saveExists else { return false }
        do {
            let loaded = try GameState.load(from: Self.saveURL)
            self.gameState = loaded
            ContentLoader.shared = ContentLoader(scenario: loaded.scenarioName)
            if let anyID = loaded.characterLocations.first?.value,
               let node = loaded.dungeon?.nodes[anyID.uuidString] {
                AudioManager.shared.play(sound: "ambient_\(node.soundProfile).wav", loop: true)
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

    /// Executes a free action that does not require a roll, applying its success
    /// consequences immediately.
    func performFreeAction(for action: ActionOption, with character: Character, interactableID: String?) -> String {
        let consequences = action.outcomes[.success] ?? []
        let context = ConsequenceContext(character: character,
                                         interactableID: interactableID,
                                         finalEffect: action.effect,
                                         finalPosition: action.position,
                                         isCritical: false)
        let description = processConsequences(consequences, context: context)
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
                                  finalEffect: nil)
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
        let consequenceProcessingContext = ConsequenceContext(character: character,
                                         interactableID: interactableID,
                                         finalEffect: finalEffect,
                                         finalPosition: finalPosition,
                                         isCritical: isCritical)
        consequencesDescription = processConsequences(eligible, context: consequenceProcessingContext)

        if isCritical && highestRoll >= 4 {
            let critMsg = "Critical Success! Effect increased to \(finalEffect.rawValue.capitalized)."
            if consequencesDescription.isEmpty {
                consequencesDescription = critMsg
            } else {
                consequencesDescription += "\n" + critMsg
            }
        }
        if !consumedMessages.isEmpty {
            AudioManager.shared.play(sound: "sfx_modifier_consume.wav")
            if consequencesDescription.isEmpty {
                consequencesDescription = consumedMessages.joined(separator: "\n")
            } else {
                consequencesDescription += "\n" + consumedMessages.joined(separator: "\n")
            }
        }
        saveGame()

        return DiceRollResult(highestRoll: highestRoll,
                              outcome: outcome.label,
                              consequences: consequencesDescription,
                              actualDiceRolled: actualDiceRolled,
                              isCritical: isCritical,
                              finalEffect: finalEffect)
    }

    private func performGroupAction(for action: ActionOption, leader: Character, interactableID: String?) -> DiceRollResult {
        guard partyMovementMode == .grouped, !isPartyActuallySplit() else {
            return DiceRollResult(highestRoll: 0,
                                  outcome: "Cannot",
                                  consequences: "Party must be together for a group action.",
                                  actualDiceRolled: nil,
                                  isCritical: nil,
                                  finalEffect: nil)
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

        let context = ConsequenceContext(character: leader,
                                         interactableID: interactableID,
                                         finalEffect: action.effect,
                                         finalPosition: action.position,
                                         isCritical: false)
        var description = processConsequences(consequences, context: context)

        if let leaderIndex = gameState.party.firstIndex(where: { $0.id == leader.id }) {
            gameState.party[leaderIndex].stress += failures
            if let overflow = checkStressOverflow(for: leaderIndex) {
                if !description.isEmpty { description += "\n" }
                description += overflow
            }
            if failures > 0 {
                if !description.isEmpty { description += "\n" }
                description += "Leader takes \(failures) Stress from allies' slips."
            }
        }

        saveGame()
        return DiceRollResult(highestRoll: bestRoll,
                              outcome: outcome.label,
                              consequences: description,
                              actualDiceRolled: nil,
                              isCritical: nil,
                              finalEffect: nil)
    }

    private func processConsequences(_ consequences: [Consequence], context: ConsequenceContext) -> String {
        let executor = makeConsequenceExecutor()
        return executor.process(consequences, context: context, gameState: &gameState)
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
        // Recreate the shared content loader so subsequent lookups use the
        // selected scenario.
        ContentLoader.shared = ContentLoader(scenario: scenario)
        let generator = DungeonGenerator(content: ContentLoader.shared)
        let manifest = ContentLoader.shared.scenarioManifest
        let (newDungeon, generatedClocks) = generator.generate(level: 1, manifest: manifest)

        let partyBuilder = PartyBuilderService(content: ContentLoader.shared)
        let resolvedPartyPlan = partyPlan ?? partyBuilder.defaultPlan(for: manifest)
        let initialParty = partyBuilder.buildParty(using: resolvedPartyPlan)
        let persistedPartyPlan: PartyBuildPlan
        switch resolvedPartyPlan.mode {
        case .manualSelection:
            persistedPartyPlan = PartyBuildPlan(
                partySize: resolvedPartyPlan.partySize,
                nativeArchetypeIDs: resolvedPartyPlan.nativeArchetypeIDs,
                selectedArchetypeIDs: initialParty.compactMap(\.archetypeID),
                mode: resolvedPartyPlan.mode
            )
        default:
            persistedPartyPlan = resolvedPartyPlan
        }

        self.gameState = GameState(
            scenarioName: scenario,
            party: initialParty, // Use the generated party here
            activeClocks: generatedClocks,
            dungeon: newDungeon,
            currentNodeID: newDungeon.startingNodeID,
            characterLocations: [:],
            status: .playing,
            runOutcome: nil,
            runOutcomeText: nil,
            launchPartyPlan: persistedPartyPlan
        )

        for id in gameState.party.map({ $0.id }) {
            gameState.characterLocations[id.uuidString] = newDungeon.startingNodeID
        }

        if let startingNode = newDungeon.nodes[newDungeon.startingNodeID.uuidString] {
            AudioManager.shared.play(sound: "ambient_\(startingNode.soundProfile).wav", loop: true)
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
        guard connection.isUnlocked else { return }

        if partyMovementMode == .solo {
            gameState.characterLocations[characterID.uuidString] = connection.toNodeID
        } else {
            for member in gameState.party where !member.isDefeated {
                gameState.characterLocations[member.id.uuidString] = connection.toNodeID
            }
        }

        if let node = gameState.dungeon?.nodes[connection.toNodeID.uuidString] {
            gameState.dungeon?.nodes[connection.toNodeID.uuidString]?.isDiscovered = true
            AudioManager.shared.play(sound: "ambient_\(node.soundProfile).wav", loop: true)
        }

        saveGame()
    }

    func getNodeName(for characterID: UUID?) -> String? {
        guard let id = characterID,
              let nodeID = gameState.characterLocations[id.uuidString],
              let node = gameState.dungeon?.nodes[nodeID.uuidString] else { return nil }
        return node.name
    }

    func isPartyActuallySplit() -> Bool {
        let unique = Set(gameState.characterLocations.values)
        return unique.count > 1
    }

    /// Whether all party members currently share the same node.
    func canRegroup() -> Bool {
        !isPartyActuallySplit()
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
}
