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
        // Determine base dice pool from the character's action ratings.
        let diceCount = character.actions[action.actionType] ?? 0
        return "Roll \(diceCount)d6. Position: \(action.position.rawValue), Effect: \(action.effect.rawValue)"
    }

    /// The main dice roll function, now returns the result for the UI.
    func performAction(for action: ActionOption, with character: Character, onClock clockID: UUID?) -> DiceRollResult {
        guard let characterIndex = gameState.party.firstIndex(where: { $0.id == character.id }) else {
            return DiceRollResult(highestRoll: 0, outcome: "Error", consequences: "Character not found.")
        }

        let dicePool = max(character.actions[action.actionType] ?? 0, 1)
        var highestRoll = 0
        for _ in 0..<dicePool {
            highestRoll = max(highestRoll, Int.random(in: 1...6))
        }

        var outcome: String
        var consequences: String

        switch highestRoll {
        case 6:
            outcome = "Full Success!"
            consequences = "You master the situation."
            if let clockID = clockID {
                let ticks = 2 // Standard effect
                updateClock(id: clockID, ticks: ticks)
                consequences += "\nThe '\(gameState.activeClocks.first(where: {$0.id == clockID})?.name ?? "")' clock progresses by \(ticks)."
            }
        case 4...5:
            outcome = "Partial Success..."
            gameState.party[characterIndex].stress += 2
            consequences = "You do it, but at a cost. Gained 2 Stress."
        default:
            outcome = "Failure."
            gameState.party[characterIndex].harm.lesser.append("Bruised")
            consequences = "Things go wrong. You suffer minor harm."
        }

        return DiceRollResult(highestRoll: highestRoll, outcome: outcome, consequences: consequences)
    }

    private func updateClock(id: UUID, ticks: Int) {
        if let index = gameState.activeClocks.firstIndex(where: { $0.id == id }) {
            gameState.activeClocks[index].progress = min(gameState.activeClocks[index].segments,
                                                         gameState.activeClocks[index].progress + ticks)
        }
    }

    /// Generates the dungeon map for the sprint. Currently static.
    func generateDungeon() {
        var nodes: [UUID: MapNode] = [:]

        let startNodeID = UUID()
        let secondNodeID = UUID()
        let thirdNodeID = UUID()

        let startNode = MapNode(
            name: "Entrance Chamber",
            interactables: [
                Interactable(title: "Sealed Stone Door",
                              description: "A massive circular door covered in dust.",
                              availableActions: [
                                ActionOption(name: "Examine the Mechanism", actionType: "Study", position: .controlled, effect: .standard),
                                ActionOption(name: "Push with all your might", actionType: "Wreck", position: .desperate, effect: .great)
                              ])
            ],
            connections: [NodeConnection(toNodeID: secondNodeID, isUnlocked: false, description: "The Stone Door")],
            isDiscovered: true
        )

        let secondNode = MapNode(
            name: "The Trap Room",
            interactables: [
                Interactable(title: "Trapped Pedestal",
                              description: "An ancient pedestal covered in suspicious glyphs.",
                              availableActions: [
                                ActionOption(name: "Tinker with it", actionType: "Tinker", position: .risky, effect: .standard)
                              ])
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

