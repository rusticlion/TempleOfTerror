import SwiftUI

struct RollProjectionDetails {
    var baseDiceCount: Int
    var finalDiceCount: Int
    var basePosition: RollPosition
    var finalPosition: RollPosition
    var baseEffect: RollEffect
    var finalEffect: RollEffect
    var notes: [String]
}

@MainActor
enum PartyMovementMode {
    case grouped
    case solo
}

class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var partyMovementMode: PartyMovementMode = .grouped


    // Retrieve the node a specific character is currently in
    func node(for characterID: UUID?) -> MapNode? {
        guard let id = characterID,
              let nodeID = gameState.characterLocations[id],
              let map = gameState.dungeon else { return nil }
        return map.nodes[nodeID]
    }


    init(scenario: String = "tomb") {
        self.gameState = GameState()
        startNewRun(scenario: scenario)
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
                apply(penalty: penalty, description: harm.description, to: action.actionType, diceCount: &diceCount, effect: &effect, notes: &notes)
            }
        }
        for harm in character.harm.moderate {
            if let penalty = HarmLibrary.families[harm.familyId]?.moderate.penalty {
                apply(penalty: penalty, description: harm.description, to: action.actionType, diceCount: &diceCount, effect: &effect, notes: &notes)
            }
        }
        for harm in character.harm.severe {
            if let penalty = HarmLibrary.families[harm.familyId]?.severe.penalty {
                apply(penalty: penalty, description: harm.description, to: action.actionType, diceCount: &diceCount, effect: &effect, notes: &notes)
            }
        }
        // Apply bonuses from modifiers
        for modifier in character.modifiers {
            if modifier.uses == 0 { continue }
            if let specific = modifier.applicableToAction, specific != action.actionType { continue }

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

        diceCount = max(diceCount, 0) // Can't roll negative dice

        return RollProjectionDetails(
            baseDiceCount: baseDice,
            finalDiceCount: diceCount,
            basePosition: basePosition,
            finalPosition: position,
            baseEffect: baseEffect,
            finalEffect: effect,
            notes: notes
        )
    }

    /// The main dice roll function, now returns the result for the UI.
    func performAction(for action: ActionOption, with character: Character, interactableID: String?) -> DiceRollResult {
        if action.isGroupAction {
            return performGroupAction(for: action, leader: character, interactableID: interactableID)
        }
        guard gameState.party.contains(where: { $0.id == character.id }) else {
            return DiceRollResult(highestRoll: 0, outcome: "Error", consequences: "Character not found.")
        }

        let dicePool = max(character.actions[action.actionType] ?? 0, 1)
        var highestRoll = 0
        for _ in 0..<dicePool {
            highestRoll = max(highestRoll, Int.random(in: 1...6))
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

        var consequencesDescription = processConsequences(consequencesToApply, forCharacter: character, interactableID: interactableID)

        if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
            var updatedModifiers: [Modifier] = []
            var consumedMessages: [String] = []
            for var modifier in gameState.party[charIndex].modifiers {
                if modifier.uses == 0 { continue }
                if let specific = modifier.applicableToAction, specific != action.actionType {
                    updatedModifiers.append(modifier)
                    continue
                }
                if modifier.uses > 0 {
                    modifier.uses -= 1
                    if modifier.uses == 0 {
                        let name = modifier.description.replacingOccurrences(of: "from ", with: "")
                        consumedMessages.append("Used up \(name).")
                        continue
                    }
                }
                updatedModifiers.append(modifier)
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
        }

        return DiceRollResult(highestRoll: highestRoll, outcome: outcomeString, consequences: consequencesDescription)
    }

    private func performGroupAction(for action: ActionOption, leader: Character, interactableID: String?) -> DiceRollResult {
        guard partyMovementMode == .grouped, !isPartyActuallySplit() else {
            return DiceRollResult(highestRoll: 0, outcome: "Cannot", consequences: "Party must be together for a group action.")
        }

        var bestRoll = 0
        var failures = 0

        for member in gameState.party {
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

        var description = processConsequences(consequences, forCharacter: leader, interactableID: interactableID)

        if let leaderIndex = gameState.party.firstIndex(where: { $0.id == leader.id }) {
            gameState.party[leaderIndex].stress += failures
            if failures > 0 {
                if !description.isEmpty { description += "\n" }
                description += "Leader takes \(failures) Stress from allies' slips."
            }
        }

        return DiceRollResult(highestRoll: bestRoll, outcome: outcomeString, consequences: description)
    }

    private func processConsequences(_ consequences: [Consequence], forCharacter character: Character, interactableID: String?) -> String {
        var descriptions: [String] = []
        let partyMemberId = character.id
        for consequence in consequences {
            switch consequence {
            case .gainStress(let amount):
                if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                    gameState.party[charIndex].stress += amount
                    descriptions.append("Gained \(amount) Stress.")
                }
            case .sufferHarm(let level, let familyId):
                let description = applyHarm(familyId: familyId, level: level, toCharacter: character.id)
                descriptions.append(description)
            case .tickClock(let clockName, let amount):
                if let clockIndex = gameState.activeClocks.firstIndex(where: { $0.name == clockName }) {
                    updateClock(id: gameState.activeClocks[clockIndex].id, ticks: amount)
                    descriptions.append("The '\(clockName)' clock progresses by \(amount).")
                }
            case .unlockConnection(let fromNodeID, let toNodeID):
                if let connIndex = gameState.dungeon?.nodes[fromNodeID]?.connections.firstIndex(where: { $0.toNodeID == toNodeID }) {
                    gameState.dungeon?.nodes[fromNodeID]?.connections[connIndex].isUnlocked = true
                    descriptions.append("A path has opened!")
                }
            case .removeInteractable(let id):
                if let nodeID = gameState.characterLocations[partyMemberId] {
                    gameState.dungeon?.nodes[nodeID]?.interactables.removeAll(where: { $0.id == id })
                    descriptions.append("The way is clear.")
                }
            case .removeSelfInteractable:
                if let nodeID = gameState.characterLocations[partyMemberId], let interactableStrID = interactableID {
                    gameState.dungeon?.nodes[nodeID]?.interactables.removeAll(where: { $0.id == interactableStrID })
                    descriptions.append("The way is clear.")
                }
            case .addInteractable(let inNodeID, let interactable):
                gameState.dungeon?.nodes[inNodeID]?.interactables.append(interactable)
                descriptions.append("Something new appears.")
            case .addInteractableHere(let interactable):
                if let nodeID = gameState.characterLocations[partyMemberId] {
                    gameState.dungeon?.nodes[nodeID]?.interactables.append(interactable)
                    descriptions.append("Something new appears.")
                }
            case .gainTreasure(let treasureId):
                if let treasure = ContentLoader.shared.treasureTemplates.first(where: { $0.id == treasureId }),
                   let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                    gameState.party[charIndex].treasures.append(treasure)
                    gameState.party[charIndex].modifiers.append(treasure.grantedModifier)
                    descriptions.append("Gained Treasure: \(treasure.name)!")
                }
            }
        }
        return descriptions.joined(separator: "\n")
    }

    private func apply(penalty: Penalty, description: String, to actionType: String, diceCount: inout Int, effect: inout RollEffect, notes: inout [String]) {
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
        default:
            break
        }
    }

    private func updateClock(id: UUID, ticks: Int) {
        if let index = gameState.activeClocks.firstIndex(where: { $0.id == id }) {
            gameState.activeClocks[index].progress = min(gameState.activeClocks[index].segments,
                                                         gameState.activeClocks[index].progress + ticks)
        }
    }

    func pushYourself(forCharacter character: Character) {
        if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
            let currentStress = gameState.party[charIndex].stress
            if currentStress + 2 > 9 {
                // Handle Trauma case later
            }
            gameState.party[charIndex].stress += 2
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
                    gameState.status = .gameOver
                    let fatalDescription = harmFamily.fatal.description
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
        let (newDungeon, generatedClocks) = generator.generate(level: 1)

        self.gameState = GameState(
            party: [
                Character(name: "Indy", characterClass: "Archaeologist", stress: 0, harm: HarmState(), actions: ["Study": 3, "Wreck": 1]),
                Character(name: "Sallah", characterClass: "Brawler", stress: 0, harm: HarmState(), actions: ["Finesse": 2, "Survey": 2]),
                Character(name: "Marion", characterClass: "Survivor", stress: 0, harm: HarmState(), actions: ["Tinker": 2, "Attune": 1])
            ],
            activeClocks: [
                GameClock(name: "The Guardian Wakes", segments: 6, progress: 0)
            ] + generatedClocks,
            dungeon: newDungeon,
            characterLocations: [:],
            status: .playing
        )

        for id in gameState.party.map({ $0.id }) {
            gameState.characterLocations[id] = newDungeon.startingNodeID
        }

        if let startingNode = newDungeon.nodes[newDungeon.startingNodeID] {
            AudioManager.shared.play(sound: "ambient_\(startingNode.soundProfile).wav", loop: true)
        }
    }


    /// Move one or all party members depending on the current movement mode.
    func move(characterID: UUID, to connection: NodeConnection) {
        guard connection.isUnlocked else { return }

        if partyMovementMode == .solo {
            gameState.characterLocations[characterID] = connection.toNodeID
        } else {
            for id in gameState.party.map({ $0.id }) {
                gameState.characterLocations[id] = connection.toNodeID
            }
        }

        if let node = gameState.dungeon?.nodes[connection.toNodeID] {
            gameState.dungeon?.nodes[connection.toNodeID]?.isDiscovered = true
            AudioManager.shared.play(sound: "ambient_\(node.soundProfile).wav", loop: true)
        }
    }

    func getNodeName(for characterID: UUID?) -> String? {
        guard let id = characterID,
              let nodeID = gameState.characterLocations[id],
              let node = gameState.dungeon?.nodes[nodeID] else { return nil }
        return node.name
    }

    func isPartyActuallySplit() -> Bool {
        let unique = Set(gameState.characterLocations.values)
        return unique.count > 1
    }

    func toggleMovementMode() {
        partyMovementMode = (partyMovementMode == .grouped) ? .solo : .grouped
    }
}

