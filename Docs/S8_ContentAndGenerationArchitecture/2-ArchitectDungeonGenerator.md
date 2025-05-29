Task 2: Architect the Dungeon Generator
This is the engine that will create variety. It will be a dedicated service that takes the loaded content and outputs a complete DungeonMap.

Action: Create a new DungeonGenerator.swift file.
Action: Design a basic generation algorithm.
Action: Update GameViewModel to call this generator instead of using its own hardcoded generateDungeon method.
DungeonGenerator.swift (New File)

Swift

import Foundation

class DungeonGenerator {
    private let content: ContentLoader

    init(content: ContentLoader = .shared) {
        self.content = content
    }

    func generate(level: Int) -> DungeonMap {
        var nodes: [UUID: MapNode] = [:]
        let nodeCount = 5 + level // Simple scaling: the deeper you go, the bigger the dungeon

        // 1. Create a chain of nodes
        var previousNodeID: UUID?
        var nodeIDs: [UUID] = []

        for i in 0..<nodeCount {
            let newNodeID = UUID()
            var connections: [NodeConnection] = []
            if let prevID = previousNodeID {
                // Connect back to the previous node
                connections.append(NodeConnection(toNodeID: prevID, description: "Go back"))
            }

            let newNode = MapNode(
                id: newNodeID,
                name: "Forgotten Antechamber \(i+1)",
                interactables: [], // We'll populate these next
                connections: connections
            )
            nodes[newNodeID] = newNode
            nodeIDs.append(newNodeID)

            // Connect the previous node forward to this one
            if let prevID = previousNodeID {
                let desc = i == nodeCount - 1 ? "Path to the final chamber" : "Deeper into the tomb"
                nodes[prevID]?.connections.append(NodeConnection(toNodeID: newNodeID, description: desc))
            }
            previousNodeID = newNodeID
        }

        // 2. Populate nodes with interactables
        for id in nodeIDs.dropFirst() { // Don't put interactables in the very first room
            if var node = nodes[id] {
                let numberOfInteractables = Int.random(in: 1...2)
                for _ in 0..<numberOfInteractables {
                    if let randomTemplate = content.interactableTemplates.randomElement() {
                        node.interactables.append(randomTemplate)
                    }
                }
                nodes[id] = node
            }
        }

        // For now, the start is the first node we made.
        let startingNodeID = nodeIDs.first!
        nodes[startingNodeID]?.isDiscovered = true
        
        return DungeonMap(nodes: nodes, startingNodeID: startingNodeID)
    }
}
GameViewModel.swift (Updates)

Swift

// In GameViewModel

// The old generateDungeon is removed entirely.
func startNewRun() {
    let generator = DungeonGenerator()
    let newDungeon = generator.generate(level: 1) // Start with a level 1 dungeon

    self.gameState = GameState(
        party: [/* ... generate random party ... */],
        activeClocks: [/* ... starting clocks ... */],
        dungeon: newDungeon,
        currentNodeID: newDungeon.startingNodeID,
        status: .playing
    )
}