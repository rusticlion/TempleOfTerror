import SwiftUI

struct MapView: View {
    @ObservedObject var viewModel: GameViewModel

    @State private var nodePositions: [UUID: CGPoint] = [:]
    @State private var selectedNodeInfo: (name: String, characters: [String])? = nil

    private func calculateNodePositions(map: DungeonMap, geometry: GeometryProxy) {
        var positions: [UUID: CGPoint] = [:]
        var queue: [(id: UUID, depth: Int)] = [(map.startingNodeID, 0)]
        var visited: Set<UUID> = [map.startingNodeID]
        var nodesByDepth: [Int: [UUID]] = [0: [map.startingNodeID]]

        var head = 0
        while head < queue.count {
            let current = queue[head]
            head += 1
            if let node = map.nodes[current.id.uuidString] {
                for connection in node.connections {
                    if !visited.contains(connection.toNodeID) {
                        visited.insert(connection.toNodeID)
                        queue.append((connection.toNodeID, current.depth + 1))
                        nodesByDepth[current.depth + 1, default: []].append(connection.toNodeID)
                    }
                }
            }
        }

        let ySpacing = geometry.size.height / CGFloat(nodesByDepth.keys.count + 1)
        for (depth, nodesInDepth) in nodesByDepth.sorted(by: { $0.key < $1.key }) {
            let xSpacing = geometry.size.width / CGFloat(nodesInDepth.count + 1)
            for (index, nodeID) in nodesInDepth.enumerated() {
                positions[nodeID] = CGPoint(x: CGFloat(index + 1) * xSpacing,
                                            y: CGFloat(depth + 1) * ySpacing)
            }
        }

        nodePositions = positions
    }

    private func isCurrentLocation(nodeID: UUID) -> Bool {
        viewModel.gameState.characterLocations.values.contains(nodeID)
    }

    private func updateSelectedNodeInfo(nodeID: UUID) {
        guard let map = viewModel.gameState.dungeon,
              let node = map.nodes[nodeID.uuidString] else {
            selectedNodeInfo = nil
            return
        }

        let charactersInNode = viewModel.gameState.party.filter { character in
            viewModel.gameState.characterLocations[character.id.uuidString] == nodeID
        }.map { $0.name }

        withAnimation {
            selectedNodeInfo = (name: node.name, characters: charactersInNode)
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                if let map = viewModel.gameState.dungeon {
                    ZStack {
                        ForEach(map.nodes.values.flatMap { node in node.connections.map { (node.id, $0) } }, id: \.1.toNodeID) { fromID, conn in
                            if let fromPos = nodePositions[fromID], let toPos = nodePositions[conn.toNodeID] {
                                Path { path in
                                    path.move(to: fromPos)
                                    path.addLine(to: toPos)
                                }
                                .stroke(Color.gray, lineWidth: 2)
                                .zIndex(0)
                            }
                        }

                        ForEach(Array(map.nodes.values), id: \.id) { node in
                            if let pos = nodePositions[node.id] {
                                Circle()
                                    .fill(node.isDiscovered ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 30, height: 30)
                                    .position(pos)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.green, lineWidth: isCurrentLocation(nodeID: node.id) ? 3 : 0)
                                            .frame(width: 36, height: 36)
                                            .position(pos)
                                    )
                                    .onTapGesture {
                                        updateSelectedNodeInfo(nodeID: node.id)
                                    }
                                    .zIndex(1)
                            }
                        }

                        if let info = selectedNodeInfo {
                            VStack {
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text(info.name).font(.headline)
                                    if !info.characters.isEmpty {
                                        Text("Party Present: \(info.characters.joined(separator: ", "))")
                                            .font(.caption)
                                    }
                                }
                                .padding()
                                .background(.thinMaterial)
                                .cornerRadius(8)
                                .padding(.bottom)
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        calculateNodePositions(map: map, geometry: geo)
                    }
                } else {
                    Text("No Map")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
            .navigationTitle("Dungeon Map")
            .onTapGesture {
                if selectedNodeInfo != nil {
                    withAnimation { selectedNodeInfo = nil }
                }
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(viewModel: GameViewModel())
    }
}
