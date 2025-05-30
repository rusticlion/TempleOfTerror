import SwiftUI

struct MapView: View {
    @ObservedObject var viewModel: GameViewModel

    private func orderedNodes(from map: DungeonMap) -> [MapNode] {
        var result: [MapNode] = []
        var queue: [UUID] = [map.startingNodeID]
        var visited: Set<UUID> = []
        while let id = queue.first {
            queue.removeFirst()
            guard visited.insert(id).inserted else { continue }
            if let node = map.nodes[id] {
                result.append(node)
                queue.append(contentsOf: node.connections.map { $0.toNodeID })
            }
        }
        return result
    }

    private func isCurrentLocation(nodeID: UUID) -> Bool {
        viewModel.gameState.characterLocations.values.contains(nodeID)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                if let map = viewModel.gameState.dungeon {
                    let nodes = orderedNodes(from: map)
                    let spacing = geo.size.width / CGFloat(max(nodes.count, 1) + 1)
                    ZStack {
                        ForEach(Array(nodes.enumerated()), id: \.1.id) { index, node in
                            let pos = CGPoint(x: spacing * CGFloat(index + 1), y: geo.size.height / 2)
                            ForEach(node.connections, id: \.toNodeID) { conn in
                                if let targetIdx = nodes.firstIndex(where: { $0.id == conn.toNodeID }) {
                                    let target = CGPoint(x: spacing * CGFloat(targetIdx + 1), y: geo.size.height / 2)
                                    Path { path in
                                        path.move(to: pos)
                                        path.addLine(to: target)
                                    }
                                    .stroke(Color.gray, lineWidth: 2)
                                    .zIndex(0) // ensure connectors are beneath nodes
                                }
                            }
                        }
                        ForEach(Array(nodes.enumerated()), id: \.1.id) { index, node in
                            let pos = CGPoint(x: spacing * CGFloat(index + 1), y: geo.size.height / 2)
                            Circle()
                                .fill(node.isDiscovered ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 30, height: 30)
                                .position(pos)
                                .overlay(
                                    Circle()
                                        .stroke(Color.green, lineWidth: 3)
                                        .opacity(isCurrentLocation(nodeID: node.id) ? 1 : 0)
                                        .frame(width: 36, height: 36)
                                        .position(pos)
                                )
                                .zIndex(1) // draw nodes above connectors
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("No Map")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
            .navigationTitle("Dungeon Map")
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(viewModel: GameViewModel())
    }
}
