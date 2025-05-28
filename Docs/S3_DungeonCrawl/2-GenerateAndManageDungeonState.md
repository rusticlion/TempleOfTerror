Task 2: Generate and Manage the Dungeon State
The GameViewModel needs to be updated to create, store, and manage the state of the dungeon map and the player's current location.

Action: Update GameState to include the map and the party's location.
Action: Add logic to GameViewModel to generate a simple, static map for this sprint.
Action: Create a new function in GameViewModel for moving between nodes.
Models.swift (GameState update)

Swift

struct GameState: Codable {
    var party: [Character] = []
    var activeClocks: [GameClock] = []
    var dungeon: DungeonMap? // The full map
    var currentNodeID: UUID? // The party's current location
}
GameViewModel.swift (Updates)

Swift

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState

    // Helper to get the current node
    var currentNode: MapNode? {
        guard let map = gameState.dungeon, let currentNodeID = gameState.currentNodeID else { return nil }
        return map.nodes[currentNodeID]
    }

    init() {
        // ... existing party/clock setup
        self.gameState = GameState(/*...party/clocks...*/)
        generateDungeon() // Call the new map generation function
    }

    func generateDungeon() {
        // For this sprint, we'll create a static 3-node map.
        // In the future, this will be procedural.
        var nodes: [UUID: MapNode] = [:]

        // Create Nodes
        let startNodeID = UUID()
        let secondNodeID = UUID()
        let thirdNodeID = UUID()

        let startNode = MapNode(
            name: "Entrance Chamber",
            interactables: [
                Interactable(title: "Sealed Stone Door", description: "A massive circular door covered in dust.", availableActions: [
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
                Interactable(title: "Trapped Pedestal", description: "An ancient pedestal covered in suspicious glyphs.", availableActions: [
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
        self.gameState.dungeon = map
        self.gameState.currentNodeID = startNodeID
    }

    func move(to newConnection: NodeConnection) {
        if newConnection.isUnlocked {
            self.gameState.currentNodeID = newConnection.toNodeID
            // Mark the new node as discovered
            self.gameState.dungeon?.nodes[newConnection.toNodeID]?.isDiscovered = true
        }
        // In the future, we can handle locked doors here.
    }
}