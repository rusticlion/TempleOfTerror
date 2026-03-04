import Foundation

class DungeonGenerator {
    private let content: ContentLoader

    init(content: ContentLoader = .shared) {
        self.content = content
    }

    static func resolveEntryNodeID(_ entryNode: String, in map: DungeonMap) -> UUID? {
        if let uuid = UUID(uuidString: entryNode),
           map.nodes[uuid.uuidString] != nil {
            return uuid
        }

        let matches = map.nodes.values.filter {
            $0.name.compare(entryNode, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
        guard matches.count == 1 else { return nil }
        return matches[0].id
    }

    func generate(level: Int, manifest: ScenarioManifest? = nil) -> (DungeonMap, [GameClock]) {
        let manifestToUse = manifest ?? content.scenarioManifest
        if let manifest = manifestToUse,
           let mapFile = manifest.mapFile,
           var predefined = content.loadMap(named: mapFile) {
            if let entryNode = manifest.entryNode {
                if let resolvedEntryNodeID = Self.resolveEntryNodeID(entryNode, in: predefined) {
                    predefined.startingNodeID = resolvedEntryNodeID
                    predefined.nodes[resolvedEntryNodeID.uuidString]?.isDiscovered = true
                } else {
                    print("Warning: Failed to resolve entry node '\(entryNode)' for scenario \(manifest.id)")
                }
            }
            return (predefined, content.clockTemplates)
        } else if let manifest = manifestToUse, manifest.mapFile != nil {
            print("Warning: Failed to load map file \(manifest.mapFile!) for scenario \(manifest.id)")
        }

        var nodes: [String: MapNode] = [:]
        let nodeCount = 5 + level // Simple scaling

        var previousNode: MapNode? = nil
        var nodeIDs: [UUID] = []
        var lockedConnection: (from: UUID, to: UUID)? = nil

        let themes = ["antechamber", "corridor", "trap_chamber", "shrine"]

        let soundProfiles = ["cave_drips", "chasm_wind", "silent_tomb"]

        for i in 0..<nodeCount {
            var connections: [NodeConnection] = []
            if let prev = previousNode {
                connections.append(NodeConnection(toNodeID: prev.id, description: "Go back"))
            }

            let theme = themes.randomElement()

            let newNode = MapNode(
                id: UUID(),
                name: "Forgotten Antechamber \(i + 1)",
                soundProfile: soundProfiles.randomElement() ?? "silent_tomb",
                interactables: [],
                connections: connections,
                theme: theme
            )
            nodes[newNode.id.uuidString] = newNode
            nodeIDs.append(newNode.id)

            if let prev = previousNode {
                let desc = i == nodeCount - 1 ? "Path to the final chamber" : "Deeper into the tomb"
                let connection = NodeConnection(toNodeID: newNode.id, description: desc)
                nodes[prev.id.uuidString]?.connections.append(connection)
            }
            previousNode = newNode
        }

        // Choose a single connection along the main path to lock
        if nodeIDs.count > 2 {
            let lockIndex = Int.random(in: 1..<(nodeIDs.count - 1))
            let fromID = nodeIDs[lockIndex]
            let toID = nodeIDs[lockIndex + 1]
            if let idx = nodes[fromID.uuidString]?.connections.firstIndex(where: { $0.toNodeID == toID }) {
                nodes[fromID.uuidString]?.connections[idx].isUnlocked = false
                lockedConnection = (from: fromID, to: toID)
            }
        }

        for id in nodeIDs {
            if var node = nodes[id.uuidString] {
                let number = Int.random(in: 1...2)
                for _ in 0..<number {
                    if let template = content.interactableTemplates.randomElement() {
                        node.interactables.append(template)
                    }
                }
                nodes[id.uuidString] = node
            }
        }

        if let lock = lockedConnection {
            let lever = Interactable(
                id: "lever_room_\(lock.from.uuidString)",
                title: "Rusty Lever",
                description: "It looks like it controls a nearby mechanism.",
                availableActions: [
                    ActionOption(
                        name: "Pull the Lever",
                        actionType: "Tinker",
                        position: .risky,
                        effect: .standard,
                        requiresTest: false,
                        outcomes: [
                            .success: [
                                .unlockConnection(fromNodeID: lock.from, toNodeID: lock.to),
                                .removeSelfInteractable
                            ]
                        ]
                    )
                ]
            )
            nodes[lock.from.uuidString]?.interactables.append(lever)
        }

        let startingNodeID = nodeIDs.first!
        nodes[startingNodeID.uuidString]?.isDiscovered = true

        return (DungeonMap(nodes: nodes, startingNodeID: startingNodeID), content.clockTemplates)
    }
}
