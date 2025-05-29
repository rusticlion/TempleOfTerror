import Foundation

class DungeonGenerator {
    private let content: ContentLoader

    init(content: ContentLoader = .shared) {
        self.content = content
    }

    func generate(level: Int) -> DungeonMap {
        var nodes: [UUID: MapNode] = [:]
        let nodeCount = 5 + level // Simple scaling

        var previousNode: MapNode? = nil
        var nodeIDs: [UUID] = []

        let soundProfiles = ["cave_drips", "chasm_wind", "silent_tomb"]

        for i in 0..<nodeCount {
            var connections: [NodeConnection] = []
            if let prev = previousNode {
                connections.append(NodeConnection(toNodeID: prev.id, description: "Go back"))
            }

            var newNode = MapNode(
                name: "Forgotten Antechamber \(i + 1)",
                soundProfile: soundProfiles.randomElement() ?? "silent_tomb",
                interactables: [],
                connections: connections
            )
            nodes[newNode.id] = newNode
            nodeIDs.append(newNode.id)

            if let prev = previousNode {
                let desc = i == nodeCount - 1 ? "Path to the final chamber" : "Deeper into the tomb"
                nodes[prev.id]?.connections.append(NodeConnection(toNodeID: newNode.id, description: desc))
            }
            previousNode = newNode
        }

        for id in nodeIDs.dropFirst() {
            if var node = nodes[id] {
                let number = Int.random(in: 1...2)
                for _ in 0..<number {
                    if let template = content.interactableTemplates.randomElement() {
                        node.interactables.append(template)
                    }
                }
                nodes[id] = node
            }
        }

        let startingNodeID = nodeIDs.first!
        nodes[startingNodeID]?.isDiscovered = true

        return DungeonMap(nodes: nodes, startingNodeID: startingNodeID)
    }
}
