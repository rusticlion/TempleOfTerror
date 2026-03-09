import SwiftUI

struct MapView: View {
    @ObservedObject var viewModel: GameViewModel

    @State private var selectedNodeID: UUID? = nil

    private let horizontalInset: CGFloat = 52
    private let verticalInset: CGFloat = 58
    private let nodeCardWidth: CGFloat = 108

    struct DrawableConnection: Identifiable {
        let id: String
        let fromPos: CGPoint
        let toPos: CGPoint
        let isUnlocked: Bool
        let isKnown: Bool
    }

    private func calculateNodePositions(map: DungeonMap, size: CGSize) -> [UUID: CGPoint] {
        guard size.width > 1, size.height > 1 else { return [:] }

        var nodesByDepth: [Int: [UUID]] = [0: [map.startingNodeID]]
        var queue: [(id: UUID, depth: Int)] = [(map.startingNodeID, 0)]
        var visited: Set<UUID> = [map.startingNodeID]
        var head = 0

        while head < queue.count {
            let current = queue[head]
            head += 1

            guard let node = map.nodes[current.id.uuidString] else { continue }
            for connection in node.connections {
                if visited.insert(connection.toNodeID).inserted {
                    queue.append((connection.toNodeID, current.depth + 1))
                    nodesByDepth[current.depth + 1, default: []].append(connection.toNodeID)
                }
            }
        }

        let unreachableNodes = map.nodes.values
            .map(\.id)
            .filter { !visited.contains($0) }
            .sorted { lhs, rhs in
                let lhsName = map.nodes[lhs.uuidString]?.name ?? lhs.uuidString
                let rhsName = map.nodes[rhs.uuidString]?.name ?? rhs.uuidString
                return lhsName < rhsName
            }

        if !unreachableNodes.isEmpty {
            let nextDepth = (nodesByDepth.keys.max() ?? 0) + 1
            nodesByDepth[nextDepth] = unreachableNodes
        }

        let orderedDepths = nodesByDepth.keys.sorted()
        let usableWidth = max(size.width - (horizontalInset * 2), 1)
        let usableHeight = max(size.height - (verticalInset * 2), 1)
        let depthStep = orderedDepths.count <= 1 ? 0 : usableHeight / CGFloat(orderedDepths.count - 1)

        var positions: [UUID: CGPoint] = [:]

        for (depthIndex, depth) in orderedDepths.enumerated() {
            let nodeIDs = nodesByDepth[depth] ?? []
            let y = verticalInset + (orderedDepths.count <= 1 ? usableHeight / 2 : CGFloat(depthIndex) * depthStep)

            if nodeIDs.count <= 1 {
                if let onlyNodeID = nodeIDs.first {
                    positions[onlyNodeID] = CGPoint(x: horizontalInset + (usableWidth / 2), y: y)
                }
                continue
            }

            let xStep = usableWidth / CGFloat(nodeIDs.count - 1)
            for (index, nodeID) in nodeIDs.enumerated() {
                positions[nodeID] = CGPoint(
                    x: horizontalInset + (CGFloat(index) * xStep),
                    y: y
                )
            }
        }

        return positions
    }

    private func characters(at nodeID: UUID) -> [Character] {
        viewModel.gameState.party
            .filter { !$0.isDefeated && viewModel.gameState.characterLocations[$0.id.uuidString] == nodeID }
            .sorted { $0.name < $1.name }
    }

    private func isCurrentLocation(nodeID: UUID) -> Bool {
        viewModel.gameState.characterLocations.values.contains(nodeID)
    }

    private func selectedNode(from map: DungeonMap) -> MapNode? {
        guard let selectedNodeID else { return nil }
        guard let node = map.nodes[selectedNodeID.uuidString], node.isDiscovered else { return nil }
        return node
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bgWarm.ignoresSafeArea()

                VStack(spacing: 12) {
                    Text("Dungeon Map")
                        .font(Theme.displayFont(size: 22))
                        .foregroundColor(Theme.parchment)

                    if let map = viewModel.gameState.dungeon {
                        GeometryReader { geo in
                            let nodePositions = calculateNodePositions(map: map, size: geo.size)
                            let sortedNodes = map.nodes.values.sorted { lhs, rhs in
                                let lhsY = nodePositions[lhs.id]?.y ?? 0
                                let rhsY = nodePositions[rhs.id]?.y ?? 0
                                if lhsY == rhsY {
                                    return lhs.name < rhs.name
                                }
                                return lhsY < rhsY
                            }
                            let displayedNodes = sortedNodes.filter(\.isDiscovered)
                            let displayedNodeIDs = Set(displayedNodes.map(\.id))
                            let drawableConnections: [DrawableConnection] = displayedNodes.reduce(into: []) { connections, node in
                                guard let fromPos = nodePositions[node.id] else { return }

                                for connection in node.connections {
                                    guard displayedNodeIDs.contains(connection.toNodeID) else { continue }
                                    guard let toPos = nodePositions[connection.toNodeID] else { continue }
                                    let targetNode = map.nodes[connection.toNodeID.uuidString]
                                    let isKnown = node.isDiscovered || targetNode?.isDiscovered == true
                                    let id = "\(node.id.uuidString)-\(connection.toNodeID.uuidString)"
                                    connections.append(
                                        DrawableConnection(
                                            id: id,
                                            fromPos: fromPos,
                                            toPos: toPos,
                                            isUnlocked: connection.isUnlocked,
                                            isKnown: isKnown
                                        )
                                    )
                                }
                            }

                            ZStack {
                                ForEach(drawableConnections) { connection in
                                    Path { path in
                                        path.move(to: connection.fromPos)
                                        path.addLine(to: connection.toPos)
                                    }
                                    .stroke(
                                        connection.isUnlocked
                                            ? (connection.isKnown ? Theme.goldDim.opacity(0.55) : Theme.parchmentDeep.opacity(0.28))
                                            : Theme.danger.opacity(0.24),
                                        style: StrokeStyle(
                                            lineWidth: connection.isUnlocked ? 2 : 1.5,
                                            lineCap: .round,
                                            dash: connection.isUnlocked ? [] : [6, 5]
                                        )
                                    )
                                    .zIndex(0)
                                }

                                ForEach(displayedNodes, id: \.id) { node in
                                    if let pos = nodePositions[node.id] {
                                        let occupants = characters(at: node.id)
                                        let isCurrent = isCurrentLocation(nodeID: node.id)

                                        VStack(spacing: 7) {
                                            ZStack {
                                                if isCurrent {
                                                    Circle()
                                                        .stroke(Theme.gold, lineWidth: 3)
                                                        .frame(width: 48, height: 48)
                                                        .shadow(color: Theme.gold.opacity(0.3), radius: 8)
                                                }

                                                Circle()
                                                    .fill(Theme.parchment.opacity(0.18))
                                                    .frame(width: 36, height: 36)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Theme.parchmentDark, lineWidth: 1.5)
                                                    )

                                                Image(systemName: occupants.isEmpty ? "diamond.fill" : "person.2.fill")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(isCurrent ? Theme.gold : Theme.parchmentDark)

                                                if occupants.count > 1 {
                                                    Text("\(occupants.count)")
                                                        .font(Theme.systemFont(size: 9, weight: .bold))
                                                        .foregroundColor(Theme.ink)
                                                        .padding(4)
                                                        .background(Theme.gold, in: Circle())
                                                        .offset(x: 16, y: 16)
                                                }
                                            }

                                            VStack(spacing: 2) {
                                                Text(node.name)
                                                    .font(Theme.systemFont(size: 11, weight: .semibold))
                                                    .foregroundColor(Theme.parchment)
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(2)
                                                    .minimumScaleFactor(0.85)

                                                if !occupants.isEmpty {
                                                    Text(occupants.map(\.name).joined(separator: ", "))
                                                        .font(Theme.systemFont(size: 9, weight: .medium))
                                                        .foregroundColor(isCurrent ? Theme.goldDim : Theme.inkFaded)
                                                        .multilineTextAlignment(.center)
                                                        .lineLimit(2)
                                                }
                                            }
                                        }
                                        .frame(width: nodeCardWidth)
                                        .position(pos)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation {
                                                selectedNodeID = selectedNodeID == node.id ? nil : node.id
                                            }
                                        }
                                        .zIndex(isCurrent ? 2 : 1)
                                    }
                                }

                                if let selectedNode = selectedNode(from: map) {
                                    let occupants = characters(at: selectedNode.id)

                                    VStack {
                                        Spacer()

                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack(alignment: .top, spacing: 12) {
                                                Text(selectedNode.name)
                                                    .font(Theme.displayFont(size: 18))
                                                    .foregroundColor(Theme.ink)

                                                Spacer(minLength: 0)

                                                Button {
                                                    withAnimation {
                                                        selectedNodeID = nil
                                                    }
                                                } label: {
                                                    Image(systemName: "xmark")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundColor(Theme.inkFaded)
                                                        .padding(7)
                                                        .background(Theme.parchment.opacity(0.55), in: Circle())
                                                }
                                                .buttonStyle(.plain)
                                            }

                                            Text(selectedNode.isDiscovered ? "Discovered node" : "Undiscovered node")
                                                .font(Theme.systemFont(size: 11, weight: .semibold))
                                                .foregroundColor(Theme.inkFaded)
                                                .textCase(.uppercase)
                                                .tracking(0.6)

                                            if !occupants.isEmpty {
                                                Text("Party Present: \(occupants.map(\.name).joined(separator: ", "))")
                                                    .font(Theme.bodyFont(size: 13))
                                                    .foregroundColor(Theme.inkLight)
                                            }

                                            Text("\(selectedNode.interactables.count) interactable" + (selectedNode.interactables.count == 1 ? "" : "s") + "  •  \(selectedNode.connections.count) exit" + (selectedNode.connections.count == 1 ? "" : "s"))
                                                .font(Theme.systemFont(size: 11, weight: .medium))
                                                .foregroundColor(Theme.inkFaded)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Theme.cardBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Theme.parchmentDeep.opacity(0.45), lineWidth: 1)
                                        )
                                        .padding(.bottom)
                                    }
                                    .padding(.horizontal, 6)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } else {
                        Text("No Map")
                            .font(Theme.bodyFont(size: 16, italic: true))
                            .foregroundColor(Theme.parchmentDark)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .padding()
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(viewModel: GameViewModel())
    }
}
