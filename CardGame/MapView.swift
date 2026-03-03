import SwiftUI

struct MapView: View {
    @ObservedObject var viewModel: GameViewModel

    @State private var nodePositions: [UUID: CGPoint] = [:]
    @State private var selectedNodeInfo: (name: String, characters: [String])? = nil

    struct DrawableConnection: Identifiable {
        let id: String
        let fromPos: CGPoint
        let toPos: CGPoint
    }

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
            !character.isDefeated &&
            viewModel.gameState.characterLocations[character.id.uuidString] == nodeID
        }.map { $0.name }

        withAnimation {
            selectedNodeInfo = (name: node.name, characters: charactersInNode)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bgWarm.ignoresSafeArea()

                VStack(spacing: 12) {
                    Text("Dungeon Map")
                        .font(Theme.displayFont(size: 22))
                        .foregroundColor(Theme.parchment)

                    GeometryReader { geo in
                        if let map = viewModel.gameState.dungeon {
                            let drawableConnections: [DrawableConnection] = map.nodes.values.reduce(into: []) { connections, node in
                                if let fromPos = nodePositions[node.id] {
                                    for connection in node.connections {
                                        if let toPos = nodePositions[connection.toNodeID] {
                                            let id = "\(node.id.uuidString)-\(connection.toNodeID.uuidString)"
                                            connections.append(DrawableConnection(id: id, fromPos: fromPos, toPos: toPos))
                                        }
                                    }
                                }
                            }

                            ZStack {
                                ForEach(drawableConnections) { dConn in
                                    Path { path in
                                        path.move(to: dConn.fromPos)
                                        path.addLine(to: dConn.toPos)
                                    }
                                    .stroke(Theme.parchmentDeep.opacity(0.4),
                                            style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                                    .zIndex(0)
                                }

                                ForEach(Array(map.nodes.values), id: \.id) { node in
                                    if let pos = nodePositions[node.id] {
                                        Group {
                                            if node.isDiscovered {
                                                Circle()
                                                    .fill(Theme.parchment.opacity(0.15))
                                                    .frame(width: 32, height: 32)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Theme.parchmentDark, lineWidth: 1.5)
                                                    )
                                            } else {
                                                Circle()
                                                    .fill(Theme.inkFaded.opacity(0.08))
                                                    .frame(width: 28, height: 28)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(
                                                                Theme.inkFaded.opacity(0.25),
                                                                style: StrokeStyle(lineWidth: 1, dash: [2, 2])
                                                            )
                                                    )
                                                    .overlay(
                                                        Text("?")
                                                            .font(Theme.bodyFont(size: 16, italic: true))
                                                            .foregroundColor(Theme.inkFaded.opacity(0.5))
                                                    )
                                            }
                                        }
                                        .position(pos)
                                        .overlay {
                                            if isCurrentLocation(nodeID: node.id) {
                                                Circle()
                                                    .stroke(Theme.gold, lineWidth: 2.5)
                                                    .frame(width: 38, height: 38)
                                                    .shadow(color: Theme.gold.opacity(0.4), radius: 6)
                                                    .position(pos)
                                            }
                                        }
                                        .onTapGesture {
                                            updateSelectedNodeInfo(nodeID: node.id)
                                        }
                                        .zIndex(1)
                                    }
                                }

                                if let info = selectedNodeInfo {
                                    VStack {
                                        Spacer()
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(info.name)
                                                .font(Theme.displayFont(size: 18))
                                                .foregroundColor(Theme.ink)
                                            if !info.characters.isEmpty {
                                                Text("Party Present: \(info.characters.joined(separator: ", "))")
                                                    .font(Theme.bodyFont(size: 13))
                                                    .foregroundColor(Theme.inkLight)
                                            }
                                        }
                                        .padding()
                                        .background(Theme.cardBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Theme.parchmentDeep.opacity(0.45), lineWidth: 1)
                                        )
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
                                .font(Theme.bodyFont(size: 16, italic: true))
                                .foregroundColor(Theme.parchmentDark)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                .padding()
            }
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
