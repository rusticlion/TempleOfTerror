import Foundation

class DungeonGenerator {
    private let content: ContentLoader

    init(content: ContentLoader) {
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

        let themes = ["approach", "transit", "hazard", "objective"]

        let soundProfiles = ["cave_drips", "chasm_wind", "silent_tomb"]

        for i in 0..<nodeCount {
            var connections: [NodeConnection] = []
            if let prev = previousNode {
                connections.append(NodeConnection(toNodeID: prev.id, description: "Go back"))
            }

            let theme = themes.randomElement()

            let newNode = MapNode(
                id: UUID(),
                name: "Uncharted Area \(i + 1)",
                soundProfile: soundProfiles.randomElement() ?? "silent_tomb",
                interactables: [],
                connections: connections,
                theme: theme
            )
            nodes[newNode.id.uuidString] = newNode
            nodeIDs.append(newNode.id)

            if let prev = previousNode {
                let desc = i == nodeCount - 1 ? "Push toward the objective" : "Advance deeper into the site"
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

struct ScenarioRuntime {
    struct MoveOutcome {
        let didMove: Bool
        let enteredNode: MapNode?
    }

    private let contentLoaderFactory: (String) -> ContentLoader
    private let dungeonGeneratorFactory: (ContentLoader) -> DungeonGenerator
    private let partyBuilderFactory: (ContentLoader) -> PartyBuilderService
    private var activeContentLoader: ContentLoader

    init(
        defaultScenario: String = RuntimeDefaults.defaultScenarioID,
        contentLoaderFactory: @escaping (String) -> ContentLoader = { ContentLoader(scenario: $0) },
        dungeonGeneratorFactory: @escaping (ContentLoader) -> DungeonGenerator = { DungeonGenerator(content: $0) },
        partyBuilderFactory: @escaping (ContentLoader) -> PartyBuilderService = { PartyBuilderService(content: $0) }
    ) {
        self.contentLoaderFactory = contentLoaderFactory
        self.dungeonGeneratorFactory = dungeonGeneratorFactory
        self.partyBuilderFactory = partyBuilderFactory
        self.activeContentLoader = contentLoaderFactory(defaultScenario)
    }

    var content: ContentLoader {
        activeContentLoader
    }

    @discardableResult
    mutating func activateScenario(named scenario: String) -> ContentLoader {
        let loader = contentLoaderFactory(scenario)
        activeContentLoader = loader
        return loader
    }

    mutating func newGameState(scenario: String = RuntimeDefaults.defaultScenarioID, partyPlan: PartyBuildPlan? = nil) -> GameState {
        let content = activateScenario(named: scenario)
        let generator = dungeonGeneratorFactory(content)
        let manifest = content.scenarioManifest
        let (newDungeon, generatedClocks) = generator.generate(level: 1, manifest: manifest)

        let partyBuilder = partyBuilderFactory(content)
        let resolvedPartyPlan = partyPlan ?? partyBuilder.defaultPlan(for: manifest)
        let initialParty = partyBuilder.buildParty(using: resolvedPartyPlan)
        let persistedPartyPlan: PartyBuildPlan
        switch resolvedPartyPlan.mode {
        case .manualSelection:
            persistedPartyPlan = PartyBuildPlan(
                partySize: resolvedPartyPlan.partySize,
                nativeArchetypeIDs: resolvedPartyPlan.nativeArchetypeIDs,
                selectedArchetypeIDs: initialParty.compactMap(\.archetypeID),
                mode: resolvedPartyPlan.mode
            )
        default:
            persistedPartyPlan = resolvedPartyPlan
        }

        var gameState = GameState(
            scenarioName: scenario,
            party: initialParty,
            activeClocks: generatedClocks,
            dungeon: newDungeon,
            currentNodeID: newDungeon.startingNodeID,
            characterLocations: [:],
            status: .playing,
            runOutcome: nil,
            runOutcomeText: nil,
            launchPartyPlan: persistedPartyPlan
        )

        for id in gameState.party.map(\.id) {
            gameState.characterLocations[id.uuidString] = newDungeon.startingNodeID
        }

        return gameState
    }

    mutating func prepareLoadedState(_ storedGameState: GameState) -> GameState {
        _ = activateScenario(named: storedGameState.scenarioName)
        return storedGameState
    }

    func node(for characterID: UUID?, in gameState: GameState) -> MapNode? {
        guard let id = characterID,
              let nodeID = gameState.characterLocations[id.uuidString],
              let map = gameState.dungeon else { return nil }
        return map.nodes[nodeID.uuidString]
    }

    func nodeName(for characterID: UUID?, in gameState: GameState) -> String? {
        node(for: characterID, in: gameState)?.name
    }

    func threats(for characterID: UUID?, in gameState: GameState) -> [Interactable] {
        guard let characterID,
              let character = gameState.party.first(where: { $0.id == characterID }),
              let node = node(for: characterID, in: gameState) else { return [] }
        return visibleInteractables(in: node, for: character, gameState: gameState).filter(\.isThreat)
    }

    func isCharacterEngaged(_ characterID: UUID?, in gameState: GameState) -> Bool {
        !threats(for: characterID, in: gameState).isEmpty
    }

    func visibleInteractables(for characterID: UUID?, in gameState: GameState) -> [Interactable] {
        guard let characterID,
              let character = gameState.party.first(where: { $0.id == characterID }),
              let node = node(for: characterID, in: gameState) else { return [] }

        let visible = visibleInteractables(in: node, for: character, gameState: gameState)
        let threats = visible.filter(\.isThreat)
        guard !threats.isEmpty else {
            return visible
        }

        let pressureOptions = visible.filter { !$0.isThreat && $0.usableUnderThreat }
        return threats + pressureOptions
    }

    func activeNodeModifiers(for characterID: UUID?, in gameState: GameState) -> [Modifier] {
        guard let node = node(for: characterID, in: gameState) else { return [] }
        return node.activeModifiers.filter { $0.uses != 0 }
    }

    func isPartyActuallySplit(in gameState: GameState) -> Bool {
        Set(gameState.characterLocations.values).count > 1
    }

    func canRegroup(in gameState: GameState) -> Bool {
        !isPartyActuallySplit(in: gameState)
    }

    @discardableResult
    func move(
        characterID: UUID,
        to connection: NodeConnection,
        movingGroupedParty: Bool,
        in gameState: inout GameState
    ) -> MoveOutcome {
        guard canTraverse(characterID: characterID, via: connection, in: gameState) else {
            return MoveOutcome(didMove: false, enteredNode: nil)
        }

        let movedIDs: [UUID]
        if movingGroupedParty {
            movedIDs = gameState.party
                .filter { !$0.isDefeated }
                .map(\.id)
        } else {
            movedIDs = [characterID]
        }

        let enteredNode = moveCharacters(
            ids: movedIDs,
            toNodeID: connection.toNodeID,
            focusCharacterID: characterID,
            in: &gameState
        )
        return MoveOutcome(didMove: true, enteredNode: enteredNode)
    }

    func canTraverse(
        characterID: UUID,
        via connection: NodeConnection,
        in gameState: GameState
    ) -> Bool {
        guard connection.isUnlocked, !isCharacterEngaged(characterID, in: gameState) else {
            return false
        }
        guard let character = gameState.party.first(where: { $0.id == characterID }) else {
            return false
        }

        return areConditionsMet(
            connection.conditions,
            for: character,
            finalEffect: .standard,
            finalPosition: .risky,
            gameState: gameState
        )
    }

    @discardableResult
    func unlockConnection(
        fromNodeID: UUID,
        toNodeID: UUID,
        in gameState: inout GameState
    ) -> Bool {
        guard let connectionIndex = gameState.dungeon?.nodes[fromNodeID.uuidString]?.connections.firstIndex(where: { $0.toNodeID == toNodeID }) else {
            return false
        }
        gameState.dungeon?.nodes[fromNodeID.uuidString]?.connections[connectionIndex].isUnlocked = true
        return true
    }

    @discardableResult
    func lockConnection(
        fromNodeID: UUID,
        toNodeID: UUID,
        in gameState: inout GameState
    ) -> Bool {
        guard let connectionIndex = gameState.dungeon?.nodes[fromNodeID.uuidString]?.connections.firstIndex(where: { $0.toNodeID == toNodeID }) else {
            return false
        }
        gameState.dungeon?.nodes[fromNodeID.uuidString]?.connections[connectionIndex].isUnlocked = false
        return true
    }

    @discardableResult
    func moveCharacter(
        id characterID: UUID,
        toNodeID: UUID,
        in gameState: inout GameState
    ) -> MapNode? {
        moveCharacters(
            ids: [characterID],
            toNodeID: toNodeID,
            focusCharacterID: characterID,
            in: &gameState
        )
    }

    @discardableResult
    func moveCharacters(
        ids characterIDs: [UUID],
        toNodeID: UUID,
        focusCharacterID: UUID? = nil,
        in gameState: inout GameState
    ) -> MapNode? {
        guard gameState.dungeon?.nodes[toNodeID.uuidString] != nil else { return nil }

        var seenIDs: Set<UUID> = []
        let uniqueIDs = characterIDs.filter { seenIDs.insert($0).inserted }
        for characterID in uniqueIDs {
            gameState.characterLocations[characterID.uuidString] = toNodeID
        }

        if let focusCharacterID {
            if uniqueIDs.contains(focusCharacterID) {
                gameState.currentNodeID = toNodeID
            } else if let focusedNodeID = currentNodeID(for: focusCharacterID, in: gameState) {
                gameState.currentNodeID = focusedNodeID
            }
        } else {
            gameState.currentNodeID = toNodeID
        }

        return discoverNode(id: toNodeID, in: &gameState)
    }

    func entryConsequences(
        for nodeID: UUID,
        via connection: NodeConnection? = nil,
        in gameState: inout GameState
    ) -> [Consequence] {
        guard let node = gameState.dungeon?.nodes[nodeID.uuidString] else {
            return connection?.onTraverse ?? []
        }

        var consequences = connection?.onTraverse ?? []
        let firstEnterConsequences = node.onFirstEnter ?? []
        let firstEnterKey = nodeID.uuidString
        let isFirstEnter = !gameState.triggeredFirstEnterNodeIDs.contains(firstEnterKey)

        if !firstEnterConsequences.isEmpty, isFirstEnter {
            gameState.triggeredFirstEnterNodeIDs.append(firstEnterKey)
            consequences.append(contentsOf: firstEnterConsequences)
        }

        if let onEnter = node.onEnter {
            consequences.append(contentsOf: onEnter)
        }

        return consequences
    }

    @discardableResult
    func removeInteractable(
        id interactableID: String,
        fromNodeID nodeID: UUID,
        in gameState: inout GameState
    ) -> Int? {
        guard var node = gameState.dungeon?.nodes[nodeID.uuidString] else { return nil }
        let before = node.interactables.count
        node.interactables.removeAll(where: { $0.id == interactableID })
        gameState.dungeon?.nodes[nodeID.uuidString] = node
        return before - node.interactables.count
    }

    @discardableResult
    func removeAction(
        named actionName: String,
        fromInteractable interactableID: String,
        inNodeID nodeID: UUID,
        in gameState: inout GameState
    ) -> Bool {
        guard let targetIndex = gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.firstIndex(where: { $0.id == interactableID }) else {
            return false
        }
        gameState.dungeon?.nodes[nodeID.uuidString]?.interactables[targetIndex].availableActions.removeAll(where: { $0.name == actionName })
        return true
    }

    @discardableResult
    func addAction(
        _ action: ActionOption,
        toInteractable interactableID: String,
        inNodeID nodeID: UUID,
        in gameState: inout GameState
    ) -> Bool {
        guard let targetIndex = gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.firstIndex(where: { $0.id == interactableID }) else {
            return false
        }
        gameState.dungeon?.nodes[nodeID.uuidString]?.interactables[targetIndex].availableActions.append(action)
        return true
    }

    @discardableResult
    func addInteractable(
        _ interactable: Interactable,
        inNodeID nodeID: UUID,
        in gameState: inout GameState
    ) -> Bool {
        guard gameState.dungeon?.nodes[nodeID.uuidString] != nil else { return false }
        gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.append(interactable)
        return true
    }

    @discardableResult
    func addInteractableHere(
        _ interactable: Interactable,
        forCharacterID characterID: UUID,
        in gameState: inout GameState
    ) -> Bool {
        guard let nodeID = currentNodeID(for: characterID, in: gameState) else { return false }
        return addInteractable(interactable, inNodeID: nodeID, in: &gameState)
    }

    @discardableResult
    func grantNodeModifier(
        _ modifier: Modifier,
        inNodeID nodeID: UUID,
        in gameState: inout GameState
    ) -> Bool {
        guard gameState.dungeon?.nodes[nodeID.uuidString] != nil else { return false }

        var grantedModifier = modifier
        grantedModifier.id = UUID()
        if let sourceKey = grantedModifier.sourceKey?.trimmingCharacters(in: .whitespacesAndNewlines),
           !sourceKey.isEmpty {
            grantedModifier.sourceKey = sourceKey
            gameState.dungeon?.nodes[nodeID.uuidString]?.activeModifiers.removeAll { $0.sourceKey == sourceKey }
        }

        gameState.dungeon?.nodes[nodeID.uuidString]?.activeModifiers.append(grantedModifier)
        return true
    }

    @discardableResult
    func removeNodeModifier(
        sourceKey: String,
        fromNodeID nodeID: UUID,
        in gameState: inout GameState
    ) -> Bool {
        guard var node = gameState.dungeon?.nodes[nodeID.uuidString] else { return false }
        let before = node.activeModifiers.count
        node.activeModifiers.removeAll { $0.sourceKey == sourceKey }
        gameState.dungeon?.nodes[nodeID.uuidString] = node
        return before != node.activeModifiers.count
    }

    func currentNodeID(for characterID: UUID, in gameState: GameState) -> UUID? {
        gameState.characterLocations[characterID.uuidString]
    }

    func resolveInteractableTemplate(id templateID: String) -> Interactable? {
        activeContentLoader.interactableTemplateDict[templateID]
    }

    private func visibleInteractables(
        in node: MapNode,
        for character: Character,
        gameState: GameState
    ) -> [Interactable] {
        node.interactables.filter { interactable in
            areConditionsMet(
                interactable.conditions,
                for: character,
                finalEffect: .standard,
                finalPosition: .risky,
                gameState: gameState
            )
        }
    }

    private func areConditionsMet(
        _ conditions: [GameCondition]?,
        for character: Character,
        finalEffect: RollEffect,
        finalPosition: RollPosition,
        gameState: GameState
    ) -> Bool {
        ConsequenceExecutor(
            debugLogging: false,
            runtime: self
        ).areConditionsMet(
            conditions: conditions,
            forCharacter: character,
            finalEffect: finalEffect,
            finalPosition: finalPosition,
            gameState: gameState
        )
    }

    @discardableResult
    private func discoverNode(id nodeID: UUID, in gameState: inout GameState) -> MapNode? {
        gameState.dungeon?.nodes[nodeID.uuidString]?.isDiscovered = true
        return gameState.dungeon?.nodes[nodeID.uuidString]
    }
}
