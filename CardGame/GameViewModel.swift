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
    init(startNewWithScenario scenario: String) {
        self.gameState = GameState()
        startNewRun(scenario: scenario)
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

    /// Calculates the projection before the roll.
    func calculateProjection(for action: ActionOption, with character: Character) -> RollProjectionDetails {
        var diceCount = character.actions[action.actionType] ?? 0
        var position = action.position
        var effect = action.effect
        let baseDice = diceCount
        let basePosition = position
        let baseEffect = effect
        var notes: [String] = []

        // Apply penalties from all active harm conditions
        for harm in character.harm.lesser {
            if let penalty = HarmLibrary.families[harm.familyId]?.lesser.penalty {
                apply(penalty: penalty, description: harm.description, to: action.actionType, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes)
            }
            if let boon = HarmLibrary.families[harm.familyId]?.lesser.boon {
                apply(boon: boon, description: harm.description, to: action.actionType, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes)
            }
        }
        for harm in character.harm.moderate {
            if let penalty = HarmLibrary.families[harm.familyId]?.moderate.penalty {
                apply(penalty: penalty, description: harm.description, to: action.actionType, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes)
            }
            if let boon = HarmLibrary.families[harm.familyId]?.moderate.boon {
                apply(boon: boon, description: harm.description, to: action.actionType, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes)
            }
        }
        for harm in character.harm.severe {
            if let penalty = HarmLibrary.families[harm.familyId]?.severe.penalty {
                apply(penalty: penalty, description: harm.description, to: action.actionType, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes)
            }
            if let boon = HarmLibrary.families[harm.familyId]?.severe.boon {
                apply(boon: boon, description: harm.description, to: action.actionType, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes)
            }
        }
        // Apply bonuses from modifiers
        for modifier in character.modifiers {
            if modifier.uses == 0 { continue }
            if let actions = modifier.applicableActions {
                if !actions.contains(action.actionType) { continue }
            } else if let specific = modifier.applicableToAction, specific != action.actionType {
                continue
            }

            if modifier.bonusDice != 0 {
                diceCount += modifier.bonusDice
                var note = "(+\(modifier.bonusDice)d \(modifier.description)"
                if modifier.uses > 0 {
                    note += " (\(modifier.uses) use\(modifier.uses == 1 ? "" : "s") left)"
                }
                if modifier.uses == 1 { note += " - will be consumed" }
                note += ")"
                notes.append(note)
            }

            if modifier.improvePosition {
                position = position.improved()
                var note = "(Improved Position from \(modifier.description)"
                if modifier.uses > 0 {
                    note += " (\(modifier.uses) use\(modifier.uses == 1 ? "" : "s") left)"
                }
                if modifier.uses == 1 { note += " - will be consumed" }
                note += ")"
                notes.append(note)
            }

            if modifier.improveEffect {
                effect = effect.increased()
                var note = "(+1 Effect from \(modifier.description)"
                if modifier.uses > 0 {
                    note += " (\(modifier.uses) use\(modifier.uses == 1 ? "" : "s") left)"
                }
                if modifier.uses == 1 { note += " - will be consumed" }
                note += ")"
                notes.append(note)
            }
        }

        if action.isGroupAction {
            notes.append("Group Action: party rolls together; best result counts. Leader takes 1 Stress per failed ally.")
        }

        let rawDicePool = diceCount
        diceCount = max(diceCount, 0) // Can't roll negative dice

        if baseDice == 0 {
            notes.append("\(character.name) has 0 rating in \(action.actionType): Rolling 2d6, taking lowest.")
        }

        let displayDice = (baseDice == 0) ? 2 : diceCount

        return RollProjectionDetails(
            baseDiceCount: baseDice,
            finalDiceCount: displayDice,
            rawDicePool: rawDicePool,
            basePosition: basePosition,
            finalPosition: position,
            baseEffect: baseEffect,
            finalEffect: effect,
            notes: notes
        )
    }

    /// Retrieve the base roll projection along with selectable optional modifiers.
    func getRollContext(for action: ActionOption, with character: Character) -> (baseProjection: RollProjectionDetails, optionalModifiers: [SelectableModifierInfo]) {
        var diceCount = character.actions[action.actionType] ?? 0
        var position = action.position
        var effect = action.effect
        let baseDice = diceCount
        let basePosition = position
        let baseEffect = effect
        var notes: [String] = []

        // Non-optional harm penalties/boons
        for harm in character.harm.lesser {
            if let penalty = HarmLibrary.families[harm.familyId]?.lesser.penalty {
                apply(penalty: penalty, description: harm.description, to: action.actionType, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes)
            }
            if let boon = HarmLibrary.families[harm.familyId]?.lesser.boon {
                apply(boon: boon, description: harm.description, to: action.actionType, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes)
            }
        }
        for harm in character.harm.moderate {
            if let penalty = HarmLibrary.families[harm.familyId]?.moderate.penalty {
                apply(penalty: penalty, description: harm.description, to: action.actionType, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes)
            }
            if let boon = HarmLibrary.families[harm.familyId]?.moderate.boon {
                apply(boon: boon, description: harm.description, to: action.actionType, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes)
            }
        }
        for harm in character.harm.severe {
            if let penalty = HarmLibrary.families[harm.familyId]?.severe.penalty {
                apply(penalty: penalty, description: harm.description, to: action.actionType, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes)
            }
            if let boon = HarmLibrary.families[harm.familyId]?.severe.boon {
                apply(boon: boon, description: harm.description, to: action.actionType, diceCount: &diceCount, position: &position, effect: &effect, notes: &notes)
            }
        }

        // Always-on modifiers
        for modifier in character.modifiers {
            if modifier.uses == 0 { continue }
            if modifier.isOptionalToApply { continue }
            if let actions = modifier.applicableActions {
                if !actions.contains(action.actionType) { continue }
            } else if let specific = modifier.applicableToAction, specific != action.actionType {
                continue
            }

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

        let rawDicePool = diceCount
        diceCount = max(diceCount, 0)
        if baseDice == 0 { notes.append("\(character.name) has 0 rating in \(action.actionType): Rolling 2d6, taking lowest.") }

        let displayDice = (baseDice == 0) ? 2 : diceCount
        let projection = RollProjectionDetails(
            baseDiceCount: baseDice,
            finalDiceCount: displayDice,
            rawDicePool: rawDicePool,
            basePosition: basePosition,
            finalPosition: position,
            baseEffect: baseEffect,
            finalEffect: effect,
            notes: notes
        )

        // Gather optional modifiers
        var optionalInfos: [SelectableModifierInfo] = []
        for mod in character.modifiers {
            if !mod.isOptionalToApply { continue }
            if mod.uses == 0 { continue }
            if let actions = mod.applicableActions {
                if !actions.contains(action.actionType) { continue }
            } else if let specific = mod.applicableToAction, specific != action.actionType {
                continue
            }

            var effectDesc: [String] = []
            if mod.bonusDice != 0 { effectDesc.append("+\(mod.bonusDice)d") }
            if mod.improvePosition { effectDesc.append("Improves Position") }
            if mod.improveEffect { effectDesc.append("+1 Effect") }
            let detail = effectDesc.joined(separator: ", ")
            let usesString = mod.uses > 0 ? "\(mod.uses)" : "∞"
            let info = SelectableModifierInfo(id: mod.id,
                                              description: mod.description,
                                              detailedEffect: detail,
                                              remainingUses: usesString,
                                              modifierData: mod)
            optionalInfos.append(info)
        }

        // Push Yourself option
        if character.stress <= 7 {
            let pushMod = Modifier(bonusDice: 1, uses: 1, isOptionalToApply: true, description: "Push Yourself")
            let pushInfo = SelectableModifierInfo(id: pushMod.id,
                                                 description: "Push Yourself",
                                                 detailedEffect: "+1d",
                                                 remainingUses: "Costs 2 Stress",
                                                 modifierData: pushMod)
            optionalInfos.append(pushInfo)
        }

        return (projection, optionalInfos)
    }

    /// Apply chosen modifiers to a base projection and return the updated projection.
    func calculateEffectiveProjection(baseProjection: RollProjectionDetails, applying chosenModifierStructs: [Modifier]) -> RollProjectionDetails {
        var result = baseProjection
        for mod in chosenModifierStructs {
            if mod.bonusDice != 0 {
                result.rawDicePool += mod.bonusDice
                result.notes.append("(+\(mod.bonusDice)d from \(mod.description))")
            }
            if mod.improvePosition {
                result.finalPosition = result.finalPosition.improved()
                result.notes.append("(Improved Position from \(mod.description))")
            }
            if mod.improveEffect {
                result.finalEffect = result.finalEffect.increased()
                result.notes.append("(+1 Effect from \(mod.description))")
            }
        }
        if baseProjection.baseDiceCount == 0 {
            result.finalDiceCount = result.rawDicePool > 0 ? result.rawDicePool : 2
        } else {
            result.finalDiceCount = max(result.rawDicePool, 0)
        }
        return result
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

        let context = getRollContext(for: action, with: character)
        var workingProjection = context.baseProjection

        var appliedOptionalMods: [Modifier] = []
        var consumedMessages: [String] = []
        var updatedModifiers: [Modifier] = gameState.party[charIndex].modifiers

        // Map of modifier id to index for quick lookup
        var idToIndex: [UUID: Int] = [:]
        for (idx, mod) in updatedModifiers.enumerated() { idToIndex[mod.id] = idx }

        for id in chosenOptionalModifierIDs {
            if let idx = idToIndex[id] {
                var mod = updatedModifiers[idx]
                appliedOptionalMods.append(mod)
                if mod.uses > 0 {
                    mod.uses -= 1
                    if mod.uses == 0 {
                        let name = mod.description.replacingOccurrences(of: "from ", with: "")
                        consumedMessages.append("Used up \(name).")
                        updatedModifiers.remove(at: idx)
                        // update indices after removal
                        idToIndex = [:]
                        for (i, m) in updatedModifiers.enumerated() { idToIndex[m.id] = i }
                        continue
                    } else {
                        updatedModifiers[idx] = mod
                    }
                }
            } else {
                // Treat as Push Yourself
                appliedOptionalMods.append(Modifier(bonusDice: 1, uses: 1, isOptionalToApply: true, description: "Push Yourself"))
                gameState.party[charIndex].stress += 2
                _ = checkStressOverflow(for: charIndex)
            }
        }

        workingProjection = calculateEffectiveProjection(baseProjection: workingProjection, applying: appliedOptionalMods)
        var finalEffect = workingProjection.finalEffect
        let finalPosition = workingProjection.finalPosition
        let rawPool = workingProjection.rawDicePool
        let useRatingZero = rawPool <= 0
        let dicePool = useRatingZero ? 2 : rawPool
        var actualDiceRolled: [Int] = []
        var highestRoll: Int
        var isCritical = false

        if let provided = diceResults {
            actualDiceRolled = provided
            if useRatingZero {
                if provided.count >= 2 {
                    highestRoll = min(provided[0], provided[1])
                    if provided[0] == 6 && provided[1] == 6 { isCritical = true }
                } else {
                    highestRoll = provided.min() ?? 0
                }
            } else {
                highestRoll = provided.max() ?? 0
                let sixes = provided.filter { $0 == 6 }.count
                if sixes > 1 { isCritical = true }
            }
        } else {
            if useRatingZero {
                let d1 = Int.random(in: 1...6)
                let d2 = Int.random(in: 1...6)
                actualDiceRolled = [d1, d2]
                highestRoll = min(d1, d2)
                if d1 == 6 && d2 == 6 { isCritical = true }
            } else {
                for _ in 0..<dicePool {
                    actualDiceRolled.append(Int.random(in: 1...6))
                }
                highestRoll = actualDiceRolled.max() ?? 0
                let sixes = actualDiceRolled.filter { $0 == 6 }.count
                if sixes > 1 { isCritical = true }
            }
        }

        var consequencesToApply: [Consequence] = []
        var outcomeString = ""

        switch highestRoll {
        case 6:
            outcomeString = "Full Success!"
            consequencesToApply = action.outcomes[.success] ?? []
        case 4...5:
            outcomeString = "Partial Success..."
            consequencesToApply = action.outcomes[.partial] ?? []
        default:
            outcomeString = "Failure."
            consequencesToApply = action.outcomes[.failure] ?? []
        }
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

        gameState.party[charIndex].modifiers = updatedModifiers
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
                              outcome: outcomeString,
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

        var consequences: [Consequence] = []
        var outcomeString = ""

        switch bestRoll {
        case 6:
            outcomeString = "Full Success!"
            consequences = action.outcomes[.success] ?? []
        case 4...5:
            outcomeString = "Partial Success..."
            consequences = action.outcomes[.partial] ?? []
        default:
            outcomeString = "Failure."
            consequences = action.outcomes[.failure] ?? []
        }

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
                              outcome: outcomeString,
                              consequences: description,
                              actualDiceRolled: nil,
                              isCritical: nil,
                              finalEffect: nil)
    }

    private func processConsequences(_ consequences: [Consequence], context: ConsequenceContext) -> String {
        var descriptions: [String] = []
        let character = context.character
        let interactableID = context.interactableID
        let partyMemberId = character.id
        let currentEffect = context.finalEffect
        let currentPosition = context.finalPosition
        for consequence in consequences {
            if !areConditionsMet(conditions: consequence.conditions,
                                 forCharacter: character,
                                 finalEffect: currentEffect,
                                 finalPosition: currentPosition) {
                continue
            }
            // First check if we have a narrative description
            var narrativeUsed = false
            if let narrative = consequence.description {
                descriptions.append(narrative)
                narrativeUsed = true
            }
            
            // Process the mechanical effect
            switch consequence.kind {
            case .gainStress:
                if let amount = consequence.amount,
                   let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                    gameState.party[charIndex].stress += amount
                    descriptions.append("Gained \(amount) Stress.")
                    if let overflow = checkStressOverflow(for: charIndex) {
                        descriptions.append(overflow)
                    }
                }
            case .sufferHarm:
                if let level = consequence.level,
                   let familyId = consequence.familyId {
                    let harmDesc = applyHarm(familyId: familyId, level: level, toCharacter: character.id)
                    if !narrativeUsed {
                        descriptions.append(harmDesc)
                    }
                }
            case .tickClock:
                if let clockName = consequence.clockName, let amount = consequence.amount {
                    if let clockIndex = gameState.activeClocks.firstIndex(where: { $0.name == clockName }) {
                        let clockId = gameState.activeClocks[clockIndex].id
                        updateClock(id: clockId, ticks: amount, actingCharacter: context.character)
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
                   let connIndex = gameState.dungeon?.nodes[fromNodeID.uuidString]?.connections.firstIndex(where: { $0.toNodeID == toNodeID }) {
                    gameState.dungeon?.nodes[fromNodeID.uuidString]?.connections[connIndex].isUnlocked = true
                    if !narrativeUsed {
                        descriptions.append("A path has opened!")
                    }
                }
            case .removeInteractable:
                if let id = consequence.interactableId,
                   let nodeID = gameState.characterLocations[partyMemberId.uuidString] {
                    gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.removeAll(where: { $0.id == id })
                    if !narrativeUsed {
                        descriptions.append("The way is clear.")
                    }
                }
            case .removeSelfInteractable:
                if let nodeID = gameState.characterLocations[partyMemberId.uuidString], let interactableStrID = interactableID {
                    gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.removeAll(where: { $0.id == interactableStrID })
                    if !narrativeUsed {
                        descriptions.append("The way is clear.")
                    }
                }
            case .removeAction:
                if let nodeID = gameState.characterLocations[partyMemberId.uuidString],
                   let actionName = consequence.actionName {
                    let targetId = consequence.interactableId ?? interactableID
                    if let tid = targetId,
                       let idx = gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.firstIndex(where: { $0.id == tid }) {
                        gameState.dungeon?.nodes[nodeID.uuidString]?.interactables[idx].availableActions.removeAll(where: { $0.name == actionName })
                        if !narrativeUsed {
                            descriptions.append("'\(actionName)' can no longer be taken.")
                        }
                    }
                }
            case .addInteractable:
                if let inNodeID = consequence.inNodeID, let interactable = consequence.newInteractable {
                    gameState.dungeon?.nodes[inNodeID.uuidString]?.interactables.append(interactable)
                    if !narrativeUsed {
                        descriptions.append("Something new appears.")
                    }
                }
            case .addInteractableHere:
                if let interactable = consequence.newInteractable,
                   let nodeID = gameState.characterLocations[partyMemberId.uuidString] {
                    gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.append(interactable)
                    if !narrativeUsed {
                        descriptions.append("Something new appears.")
                    }
                }
            case .gainTreasure:
                if let treasureId = consequence.treasureId,
                   let treasure = ContentLoader.shared.treasureTemplates.first(where: { $0.id == treasureId }),
                   let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                    gameState.party[charIndex].treasures.append(treasure)
                    gameState.party[charIndex].modifiers.append(treasure.grantedModifier)
                    if !narrativeUsed {
                        descriptions.append("Gained Treasure: \(treasure.name)!")
                    }
                }
            case .modifyDice:
                if let amount = consequence.amount,
                   let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                    let duration = consequence.duration ?? "next roll"
                    let uses = duration == "next roll" ? 1 : 99
                    let modifier = Modifier(bonusDice: amount,
                                           uses: uses,
                                           description: "Bonus from consequence")
                    gameState.party[charIndex].modifiers.append(modifier)
                    if !narrativeUsed {
                        descriptions.append("Gain +\(amount)d for \(duration).")
                    }
                }
            case .createChoice:
                // Choice handling not yet implemented; process first option if available
                if let option = consequence.choiceOptions?.first {
                    descriptions.append("Auto-selecting: \(option.title)")
                    let sub = processConsequences(option.consequences, context: context)
                    if !sub.isEmpty { descriptions.append(sub) }
                }
            case .triggerEvent:
                if let id = consequence.eventId {
                    // Placeholder for event system
                    if !narrativeUsed {
                        descriptions.append("Event triggered: \(id)")
                    }
                }
            case .triggerConsequences:
                if let extra = consequence.triggered {
                    let subDesc = processConsequences(extra, context: context)
                    if !subDesc.isEmpty { descriptions.append(subDesc) }
                }
            }
        }
        return descriptions.joined(separator: "\n")
    }

    /// Check if a list of conditions are satisfied for the given character and roll results.
    private func areConditionsMet(
        conditions: [GameCondition]?,
        forCharacter character: Character,
        finalEffect: RollEffect,
        finalPosition: RollPosition
    ) -> Bool {
        guard let conditions = conditions, !conditions.isEmpty else { return true }

        for condition in conditions {
            var conditionMet = false
            switch condition.type {
            case .requiresMinEffectLevel:
                if let req = condition.effectParam {
                    conditionMet = finalEffect.isBetterThanOrEqualTo(req)
                }
            case .requiresExactEffectLevel:
                conditionMet = (condition.effectParam == finalEffect)
            case .requiresMinPositionLevel:
                if let req = condition.positionParam {
                    conditionMet = finalPosition.isWorseThanOrEqualTo(req)
                }
            case .requiresExactPositionLevel:
                conditionMet = (condition.positionParam == finalPosition)
            case .characterHasTreasureId:
                if let tId = condition.stringParam {
                    conditionMet = character.treasures.contains(where: { $0.id == tId })
                }
            case .partyHasTreasureWithTag:
                if let tag = condition.stringParam {
                    conditionMet = self.partyHasTreasureTag(tag)
                }
            case .clockProgress:
                if let name = condition.stringParam,
                   let min = condition.intParam,
                   let clock = gameState.activeClocks.first(where: { $0.name == name }) {
                    var metMin = clock.progress >= min
                    if let max = condition.intParamMax {
                        metMin = metMin && clock.progress <= max
                    }
                    conditionMet = metMin
                }
            }
            if !conditionMet { return false }
        }
        return true
    }

    private func apply(penalty: Penalty, description: String, to actionType: String, diceCount: inout Int, position: inout RollPosition, effect: inout RollEffect, notes: inout [String]) {
        switch penalty {
        case .reduceEffect:
            effect = effect.decreased()
            notes.append("(-1 Effect from \(description))")
        case .actionPenalty(let action) where action == actionType:
            diceCount -= 1
            notes.append("(-1d from \(description))")
        case .banAction(let action) where action == actionType:
            diceCount = 0
            notes.append("(Cannot perform due to \(description))")
        case .actionPositionPenalty(let action) where action == actionType:
            position = position.decreased()
            notes.append("(-Position from \(description))")
        case .actionEffectPenalty(let action) where action == actionType:
            effect = effect.decreased()
            notes.append("(-Effect from \(description))")
        default:
            break
        }
    }

    private func apply(boon: Modifier, description: String, to actionType: String, diceCount: inout Int, position: inout RollPosition, effect: inout RollEffect, notes: inout [String]) {
        if let actions = boon.applicableActions {
            if !actions.contains(actionType) { return }
        } else if let specific = boon.applicableToAction, specific != actionType {
            return
        }

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

    private func updateClock(id: UUID, ticks: Int, actingCharacter: Character? = nil) {
        guard let index = gameState.activeClocks.firstIndex(where: { $0.id == id }) else { return }

        var clock = gameState.activeClocks[index]
        clock.progress = min(clock.segments, clock.progress + ticks)

        if let tickCons = clock.onTickConsequences {
            if let char = actingCharacter ?? gameState.party.first {
                let context = ConsequenceContext(character: char,
                                                 interactableID: nil,
                                                 finalEffect: .standard,
                                                 finalPosition: .controlled,
                                                 isCritical: false)
                _ = processConsequences(tickCons, context: context)
            }
        }

        if clock.progress >= clock.segments {
            if let completeCons = clock.onCompleteConsequences,
               let char = actingCharacter ?? gameState.party.first {
                let context = ConsequenceContext(character: char,
                                                 interactableID: nil,
                                                 finalEffect: .standard,
                                                 finalPosition: .controlled,
                                                 isCritical: false)
                _ = processConsequences(completeCons, context: context)
            }
        }

        gameState.activeClocks[index] = clock
    }

    private func checkStressOverflow(for index: Int) -> String? {
        if gameState.party[index].stress > 9 {
            return handleStressOverflow(for: index)
        }
        return nil
    }

    private func handleStressOverflow(for index: Int) -> String {
        let charId = gameState.party[index].id
        gameState.party[index].stress = 0
        let harmDesc = applyHarm(familyId: "mental_fraying", level: .lesser, toCharacter: charId)
        return "Stress Overload!\n" + harmDesc
    }

    func pushYourself(forCharacter character: Character) {
        if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
            gameState.party[charIndex].stress += 2
            _ = checkStressOverflow(for: charIndex)
        }
    }

    private func applyHarm(familyId: String, level: HarmLevel, toCharacter characterId: UUID) -> String {
        guard let charIndex = gameState.party.firstIndex(where: { $0.id == characterId }) else { return "" }
        guard let harmFamily = HarmLibrary.families[familyId] else { return "" }

        var currentLevel = level

        while true {
            switch currentLevel {
            case .lesser:
                if gameState.party[charIndex].harm.lesser.count < HarmState.lesserSlots {
                    let harm = harmFamily.lesser
                    gameState.party[charIndex].harm.lesser.append((familyId, harm.description))
                    return "Suffered Lesser Harm: \(harm.description)."
                } else {
                    currentLevel = .moderate
                }
            case .moderate:
                if gameState.party[charIndex].harm.moderate.count < HarmState.moderateSlots {
                    let harm = harmFamily.moderate
                    gameState.party[charIndex].harm.moderate.append((familyId, harm.description))
                    return "Suffered Moderate Harm: \(harm.description)."
                } else {
                    currentLevel = .severe
                }
            case .severe:
                if gameState.party[charIndex].harm.severe.count < HarmState.severeSlots {
                    let harm = harmFamily.severe
                    gameState.party[charIndex].harm.severe.append((familyId, harm.description))
                    return "Suffered SEVERE Harm: \(harm.description)."
                } else {
                    // Character suffers Fatal Harm and is removed from play
                    gameState.party[charIndex].isDefeated = true
                    gameState.characterLocations.removeValue(forKey: characterId.uuidString)
                    let fatalDescription = harmFamily.fatal.description

                    // If no active characters remain, end the run
                    if gameState.party.allSatisfy({ $0.isDefeated }) {
                        gameState.status = .gameOver
                    }

                    saveGame()
                    return "Suffered FATAL Harm: \(fatalDescription)."
                }
            }
        }
    }

    /// Starts a brand new run, resetting the game state. The scenario id
    /// corresponds to a folder within `Content/Scenarios`.
    func startNewRun(scenario: String = "tomb") {
        // Recreate the shared content loader so subsequent lookups use the
        // selected scenario.
        ContentLoader.shared = ContentLoader(scenario: scenario)
        let generator = DungeonGenerator(content: ContentLoader.shared)
        let manifest = ContentLoader.shared.scenarioManifest
        let (newDungeon, generatedClocks) = generator.generate(level: 1, manifest: manifest)

        // Use the new PartyGenerationService
        let partyService = PartyGenerationService()
        let initialParty = partyService.generateRandomParty()

        self.gameState = GameState(
            scenarioName: scenario,
            party: initialParty, // Use the generated party here
            activeClocks: [
                GameClock(name: "Test Clock", segments: 4, progress: 0)
            ] + generatedClocks,
            dungeon: newDungeon,
            characterLocations: [:],
            status: .playing
        )

        for id in gameState.party.map({ $0.id }) {
            gameState.characterLocations[id.uuidString] = newDungeon.startingNodeID
        }

        if let startingNode = newDungeon.nodes[newDungeon.startingNodeID.uuidString] {
            AudioManager.shared.play(sound: "ambient_\(startingNode.soundProfile).wav", loop: true)
        }

        saveGame()
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

