import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState

    // Helper to get the current node
    var currentNode: MapNode? {
        guard let map = gameState.dungeon, let currentNodeID = gameState.currentNodeID else { return nil }
        return map.nodes[currentNodeID]
    }

    init() {
        // For the sprint, we'll use hardcoded starting data.
        self.gameState = GameState(
            party: [
                Character(name: "Indy", characterClass: "Archaeologist", stress: 0, harm: HarmState(), actions: ["Study": 3, "Wreck": 1]),
                Character(name: "Sallah", characterClass: "Brawler", stress: 0, harm: HarmState(), actions: ["Finesse": 2, "Survey": 2]),
                Character(name: "Marion", characterClass: "Survivor", stress: 0, harm: HarmState(), actions: ["Tinker": 2, "Attune": 1])
            ],
            activeClocks: [
                GameClock(name: "The Guardian Wakes", segments: 6, progress: 0)
            ]
        )
        generateDungeon() // Call the new map generation function
    }

    // --- Core Logic Functions for the Sprint ---

    /// Calculates the projection before the roll.
    func calculateProjection(for action: ActionOption, with character: Character) -> String {
        var diceCount = character.actions[action.actionType] ?? 0
        var position = action.position
        var effect = action.effect
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
        diceCount = max(diceCount, 0) // Can't roll negative dice

        let notesString = notes.isEmpty ? "" : " " + notes.joined(separator: ", ")
        return "Roll \(diceCount)d6. Position: \(position.rawValue), Effect: \(effect.rawValue)\(notesString)"
    }

    /// The main dice roll function, now returns the result for the UI.
    func performAction(for action: ActionOption, with character: Character) -> DiceRollResult {
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

        let consequencesDescription = processConsequences(consequencesToApply, forCharacter: character)

        return DiceRollResult(highestRoll: highestRoll, outcome: outcomeString, consequences: consequencesDescription)
    }

    private func processConsequences(_ consequences: [Consequence], forCharacter character: Character) -> String {
        var descriptions: [String] = []
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
                if let nodeID = gameState.currentNodeID {
                    gameState.dungeon?.nodes[nodeID]?.interactables.removeAll(where: { $0.id == id })
                    descriptions.append("The way is clear.")
                }
            case .addInteractable(let inNodeID, let interactable):
                gameState.dungeon?.nodes[inNodeID]?.interactables.append(interactable)
                descriptions.append("Something new appears.")
            case .gainTreasure(let treasure):
                if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
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

    /// Starts a brand new run, resetting the game state
    func startNewRun() {
        self.gameState = GameState(
            party: [
                Character(name: "Indy", characterClass: "Archaeologist", stress: 0, harm: HarmState(), actions: ["Study": 3, "Wreck": 1]),
                Character(name: "Sallah", characterClass: "Brawler", stress: 0, harm: HarmState(), actions: ["Finesse": 2, "Survey": 2]),
                Character(name: "Marion", characterClass: "Survivor", stress: 0, harm: HarmState(), actions: ["Tinker": 2, "Attune": 1])
            ],
            activeClocks: [
                GameClock(name: "The Guardian Wakes", segments: 6, progress: 0)
            ],
            status: .playing
        )
        generateDungeon()
    }

    /// Generates the dungeon map for the sprint. Currently static.
    func generateDungeon() {
        var nodes: [UUID: MapNode] = [:]

        let startNodeID = UUID()
        let secondNodeID = UUID()
        let thirdNodeID = UUID()

        let stoneDoorID = UUID()
        let doorInteractable = Interactable(
            id: stoneDoorID,
            title: "Sealed Stone Door",
            description: "A massive circular door covered in dust.",
            availableActions: [
                ActionOption(
                    name: "Examine the Mechanism",
                    actionType: "Study",
                    position: .controlled,
                    effect: .standard,
                    outcomes: [
                        .success: [
                            .unlockConnection(fromNodeID: startNodeID, toNodeID: secondNodeID),
                            .removeInteractable(id: stoneDoorID)
                        ],
                        .partial: [.gainStress(amount: 1)],
                        .failure: [.tickClock(clockName: "The Guardian Wakes", amount: 1)]
                    ]
                )
            ]
        )

        let pedestalID = UUID()
        let pedestalInteractable = Interactable(
            id: pedestalID,
            title: "Trapped Pedestal",
            description: "An ancient pedestal covered in suspicious glyphs.",
            availableActions: [
                ActionOption(
                    name: "Tinker with it",
                    actionType: "Tinker",
                    position: .risky,
                    effect: .standard,
                    outcomes: [
                        .success: [
                            .removeInteractable(id: pedestalID),
                            .gainTreasure(treasure: Treasure(
                                name: "Lens of True Sight",
                                description: "This crystal lens reveals hidden things.",
                                grantedModifier: Modifier(
                                    improveEffect: true,
                                    applicableToAction: "Survey",
                                    uses: 2,
                                    description: "from Lens of True Sight"
                                )
                            ))
                        ],
                        .failure: [
                            .sufferHarm(level: .lesser, familyId: "electric_shock")
                        ]
                    ]
                )
            ]
        )

        let startNode = MapNode(
            name: "Entrance Chamber",
            interactables: [doorInteractable],
            connections: [NodeConnection(toNodeID: secondNodeID, isUnlocked: false, description: "The Stone Door")],
            isDiscovered: true
        )

        let secondNode = MapNode(
            name: "The Trap Room",
            interactables: [
                pedestalInteractable
            ],
            connections: [
                NodeConnection(toNodeID: startNodeID, description: "Back to the entrance"),
                NodeConnection(toNodeID: thirdNodeID, description: "A narrow corridor")
            ]
        )

        let thirdNode = MapNode(name: "The Echoing Chasm", interactables: [], connections: [])

        nodes[startNodeID] = startNode
        nodes[secondNodeID] = secondNode
        nodes[thirdNodeID] = thirdNode

        let map = DungeonMap(nodes: nodes, startingNodeID: startNodeID)
        gameState.dungeon = map
        gameState.currentNodeID = startNodeID
    }

    /// Move the party to a connected node if possible.
    func move(to newConnection: NodeConnection) {
        if newConnection.isUnlocked {
            gameState.currentNodeID = newConnection.toNodeID
            gameState.dungeon?.nodes[newConnection.toNodeID]?.isDiscovered = true
        }
    }
}

