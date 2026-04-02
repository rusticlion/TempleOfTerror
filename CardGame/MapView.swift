import SwiftUI

struct MapView: View {
    @ObservedObject var viewModel: GameViewModel

    @State private var selectedNodeID: UUID? = nil

    struct DrawableConnection: Identifiable {
        let id: String
        let fromPos: CGPoint
        let toPos: CGPoint
        let isUnlocked: Bool
        let isKnown: Bool
    }

    private struct MapLayoutMetrics {
        let horizontalInset: CGFloat
        let topInset: CGFloat
        let bottomInset: CGFloat
        let nodeCardWidth: CGFloat
        let currentRingSize: CGFloat
        let nodeSize: CGFloat
        let iconSize: CGFloat
        let nodeNameFontSize: CGFloat
        let occupantFontSize: CGFloat
    }

    private struct MapNodeButton: View {
        let node: MapNode
        let occupants: [Character]
        let isCurrent: Bool
        let metrics: MapLayoutMetrics
        let accessibilityIdentifier: String
        let action: () -> Void

        private var accessibilityValueText: String {
            occupants.isEmpty
                ? "No explorers present"
                : "\(occupants.count) explorer" + (occupants.count == 1 ? "" : "s") + " present"
        }

        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    ZStack {
                        if isCurrent {
                            Circle()
                                .stroke(Theme.gold, lineWidth: 3)
                                .frame(width: metrics.currentRingSize, height: metrics.currentRingSize)
                                .shadow(color: Theme.gold.opacity(0.3), radius: 8)
                        }

                        Circle()
                            .fill(Theme.parchment.opacity(0.18))
                            .frame(width: metrics.nodeSize, height: metrics.nodeSize)
                            .overlay(
                                Circle()
                                    .stroke(Theme.parchmentDark, lineWidth: 1.5)
                            )

                        Image(systemName: occupants.isEmpty ? "diamond.fill" : "person.2.fill")
                            .font(.system(size: metrics.iconSize, weight: .semibold))
                            .foregroundColor(isCurrent ? Theme.gold : Theme.parchmentDark)

                        if occupants.count > 1 {
                            Text("\(occupants.count)")
                                .font(Theme.systemFont(size: 10, weight: .bold))
                                .foregroundColor(Theme.ink)
                                .padding(4)
                                .background(Theme.gold, in: Circle())
                                .offset(x: metrics.nodeSize * 0.44, y: metrics.nodeSize * 0.44)
                        }
                    }

                    VStack(spacing: 3) {
                        Text(node.name)
                            .font(Theme.systemFont(size: metrics.nodeNameFontSize, weight: .semibold))
                            .foregroundColor(Theme.parchment)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)

                        if !occupants.isEmpty {
                            Text(occupants.map(\.name).joined(separator: ", "))
                                .font(Theme.systemFont(size: metrics.occupantFontSize, weight: .medium))
                                .foregroundColor(isCurrent ? Theme.goldDim : Theme.inkFaded)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }
                    }
                }
                .frame(width: metrics.nodeCardWidth)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(node.name)
            .accessibilityValue(accessibilityValueText)
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier(accessibilityIdentifier)
        }
    }

    private struct SelectedMapNodeCard: View {
        let node: MapNode
        let occupants: [Character]
        let routeSummary: String?
        let onClose: () -> Void

        var body: some View {
            VStack {
                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 12) {
                        Text(node.name)
                            .font(Theme.displayFont(size: 18))
                            .foregroundColor(Theme.ink)
                            .accessibilityIdentifier("selectedMapNodeTitle")

                        Spacer(minLength: 0)

                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Theme.inkFaded)
                                .padding(7)
                                .background(Theme.parchment.opacity(0.55), in: Circle())
                        }
                        .buttonStyle(.plain)
                    }

                    Text(node.isDiscovered ? "Discovered node" : "Undiscovered node")
                        .font(Theme.systemFont(size: 11, weight: .semibold))
                        .foregroundColor(Theme.inkFaded)
                        .textCase(.uppercase)
                        .tracking(0.6)

                    if !occupants.isEmpty {
                        Text("Party Present: \(occupants.map(\.name).joined(separator: ", "))")
                            .font(Theme.bodyFont(size: 13))
                            .foregroundColor(Theme.inkLight)
                    }

                    Text("\(node.interactables.count) interactable" + (node.interactables.count == 1 ? "" : "s") + "  •  \(node.connections.count) exit" + (node.connections.count == 1 ? "" : "s"))
                        .font(Theme.systemFont(size: 11, weight: .medium))
                        .foregroundColor(Theme.inkFaded)

                    if let routeSummary {
                        Text(routeSummary)
                            .font(Theme.bodyFont(size: 12))
                            .foregroundColor(Theme.inkLight)
                    }
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
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("selectedMapNodeCard")
            }
            .padding(.horizontal, 6)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func groupedDisplayedNodes(
        in map: DungeonMap,
        displayedNodeIDs: Set<UUID>
    ) -> [Int: [UUID]] {
        guard !displayedNodeIDs.isEmpty else { return [:] }

        let rootID: UUID = displayedNodeIDs.contains(map.startingNodeID)
            ? map.startingNodeID
            : displayedNodeIDs.sorted { lhs, rhs in
                let lhsName = map.nodes[lhs.uuidString]?.name ?? lhs.uuidString
                let rhsName = map.nodes[rhs.uuidString]?.name ?? rhs.uuidString
                return lhsName < rhsName
            }.first ?? map.startingNodeID

        var nodesByDepth: [Int: [UUID]] = [0: [rootID]]
        var queue: [(id: UUID, depth: Int)] = [(rootID, 0)]
        var visited: Set<UUID> = [rootID]
        var head = 0

        while head < queue.count {
            let current = queue[head]
            head += 1

            guard let node = map.nodes[current.id.uuidString] else { continue }
            for connection in node.connections {
                guard displayedNodeIDs.contains(connection.toNodeID) else { continue }
                if visited.insert(connection.toNodeID).inserted {
                    queue.append((connection.toNodeID, current.depth + 1))
                    nodesByDepth[current.depth + 1, default: []].append(connection.toNodeID)
                }
            }
        }

        let unreachableNodes = displayedNodeIDs
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

        return nodesByDepth
    }

    private func layoutMetrics(
        for size: CGSize,
        nodesByDepth: [Int: [UUID]]
    ) -> MapLayoutMetrics {
        let isPortrait = size.height >= size.width
        let maxNodesPerDepth = max(nodesByDepth.values.map(\.count).max() ?? 1, 1)
        let horizontalInset: CGFloat = isPortrait ? 26 : 48
        let topInset: CGFloat = isPortrait ? 34 : 42
        let bottomInset: CGFloat = isPortrait ? 118 : 82
        let availableWidth = max(size.width - (horizontalInset * 2), 1)
        let widthPerNode = availableWidth / CGFloat(maxNodesPerDepth)
        let minWidth: CGFloat = isPortrait ? 112 : 92
        let maxWidth: CGFloat = isPortrait ? 150 : 126
        let nodeCardWidth = min(max(widthPerNode, minWidth), maxWidth)
        let nodeSize = min(max(nodeCardWidth * 0.36, 38), isPortrait ? 52 : 44)
        let currentRingSize = nodeSize + (isPortrait ? 16 : 12)
        let iconSize = nodeSize * 0.34

        return MapLayoutMetrics(
            horizontalInset: horizontalInset,
            topInset: topInset,
            bottomInset: bottomInset,
            nodeCardWidth: nodeCardWidth,
            currentRingSize: currentRingSize,
            nodeSize: nodeSize,
            iconSize: iconSize,
            nodeNameFontSize: isPortrait ? 13 : 11,
            occupantFontSize: isPortrait ? 10 : 9
        )
    }

    private func calculateNodePositions(
        nodesByDepth: [Int: [UUID]],
        size: CGSize,
        metrics: MapLayoutMetrics
    ) -> [UUID: CGPoint] {
        guard size.width > 1, size.height > 1 else { return [:] }

        let orderedDepths = nodesByDepth.keys.sorted()
        let usableWidth = max(size.width - (metrics.horizontalInset * 2), 1)
        let usableHeight = max(size.height - metrics.topInset - metrics.bottomInset, 1)
        let depthStep = orderedDepths.count <= 1 ? 0 : usableHeight / CGFloat(orderedDepths.count - 1)

        var positions: [UUID: CGPoint] = [:]

        for (depthIndex, depth) in orderedDepths.enumerated() {
            let nodeIDs = nodesByDepth[depth] ?? []
            let y = metrics.topInset + (orderedDepths.count <= 1 ? usableHeight / 2 : CGFloat(depthIndex) * depthStep)

            if nodeIDs.count <= 1 {
                if let onlyNodeID = nodeIDs.first {
                    positions[onlyNodeID] = CGPoint(
                        x: metrics.horizontalInset + (usableWidth / 2),
                        y: y
                    )
                }
                continue
            }

            let xStep = usableWidth / CGFloat(nodeIDs.count - 1)
            for (index, nodeID) in nodeIDs.enumerated() {
                positions[nodeID] = CGPoint(
                    x: metrics.horizontalInset + (CGFloat(index) * xStep),
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

    private func mapNodeAccessibilityIdentifier(for nodeID: UUID) -> String {
        "mapNodeButton_\(nodeID.uuidString.lowercased())"
    }

    private func visibleRouteSummary(for node: MapNode) -> String? {
        guard !node.connections.isEmpty else { return nil }
        let summaries = node.connections.prefix(2).map(\.description)
        let suffix = node.connections.count > 2 ? " +" : ""
        return "Routes: \(summaries.joined(separator: " • "))\(suffix)"
    }

    private var legendView: some View {
        ViewThatFits {
            HStack(spacing: 14) {
                Label("Gold ring = current location", systemImage: "circle")
                Label("Dashed red path = locked route", systemImage: "line.diagonal")
                Label("Number badge = multiple explorers", systemImage: "number.circle")
            }

            VStack(alignment: .leading, spacing: 8) {
                Label("Gold ring = current location", systemImage: "circle")
                Label("Dashed red path = locked route", systemImage: "line.diagonal")
                Label("Number badge = multiple explorers", systemImage: "number.circle")
            }
        }
        .font(Theme.systemFont(size: 10, weight: .medium))
        .foregroundColor(Theme.inkFaded)
        .lineLimit(2)
        .minimumScaleFactor(0.85)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("mapLegend")
    }

    @ViewBuilder
    private func mapCanvas(
        map: DungeonMap,
        size: CGSize
    ) -> some View {
        let displayedNodes = map.nodes.values.filter(\.isDiscovered)
        let displayedNodeIDs = Set(displayedNodes.map(\.id))
        let nodesByDepth = groupedDisplayedNodes(in: map, displayedNodeIDs: displayedNodeIDs)
        let metrics = layoutMetrics(for: size, nodesByDepth: nodesByDepth)
        let nodePositions = calculateNodePositions(
            nodesByDepth: nodesByDepth,
            size: size,
            metrics: metrics
        )
        let sortedNodes = displayedNodes.sorted { lhs, rhs in
            let lhsY = nodePositions[lhs.id]?.y ?? 0
            let rhsY = nodePositions[rhs.id]?.y ?? 0
            if lhsY == rhsY {
                return lhs.name < rhs.name
            }
            return lhsY < rhsY
        }
        let drawableConnections: [DrawableConnection] = displayedNodes.reduce(into: []) { connections, node in
            guard let fromPos = nodePositions[node.id] else { return }

            for connection in node.connections {
                guard displayedNodeIDs.contains(connection.toNodeID) else { continue }
                guard let toPos = nodePositions[connection.toNodeID] else { continue }
                let targetNode = map.nodes[connection.toNodeID.uuidString]
                let id = "\(node.id.uuidString)-\(connection.toNodeID.uuidString)"
                connections.append(
                    DrawableConnection(
                        id: id,
                        fromPos: fromPos,
                        toPos: toPos,
                        isUnlocked: connection.isUnlocked,
                        isKnown: node.isDiscovered || targetNode?.isDiscovered == true
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

            ForEach(sortedNodes, id: \.id) { node in
                if let pos = nodePositions[node.id] {
                    let occupants = characters(at: node.id)
                    let isCurrent = isCurrentLocation(nodeID: node.id)

                    MapNodeButton(
                        node: node,
                        occupants: occupants,
                        isCurrent: isCurrent,
                        metrics: metrics,
                        accessibilityIdentifier: mapNodeAccessibilityIdentifier(for: node.id)
                    ) {
                        withAnimation {
                            selectedNodeID = selectedNodeID == node.id ? nil : node.id
                        }
                    }
                    .position(pos)
                    .contentShape(Rectangle())
                    .zIndex(isCurrent ? 2 : 1)
                }
            }

            if let selectedNode = selectedNode(from: map) {
                SelectedMapNodeCard(
                    node: selectedNode,
                    occupants: characters(at: selectedNode.id),
                    routeSummary: visibleRouteSummary(for: selectedNode)
                ) {
                    withAnimation {
                        selectedNodeID = nil
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("mapCanvas")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bgWarm.ignoresSafeArea()

                VStack(spacing: 12) {
                    Text("Dungeon Map")
                        .font(Theme.displayFont(size: 22))
                        .foregroundColor(Theme.parchment)

                    Text("Tap a room to inspect what is currently known there.")
                        .font(Theme.systemFont(size: 12, weight: .medium))
                        .foregroundColor(Theme.inkFaded)
                        .multilineTextAlignment(.center)

                    if let map = viewModel.gameState.dungeon {
                        GeometryReader { geo in
                            mapCanvas(map: map, size: geo.size)
                        }

                        legendView
                            .padding(.top, 4)
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
