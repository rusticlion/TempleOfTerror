import Foundation

protocol GameStateStoring {
    var saveURL: URL { get }
    func saveExists() -> Bool
    func save(_ gameState: GameState) throws
    func load() throws -> GameState
    func delete() throws
}

struct SaveGameStore: GameStateStoring {
    let saveURL: URL

    init(saveURL: URL = SaveGameStore.defaultSaveURL) {
        self.saveURL = saveURL
    }

    static var defaultSaveURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("savegame.json")
    }

    func saveExists() -> Bool {
        FileManager.default.fileExists(atPath: saveURL.path)
    }

    func save(_ gameState: GameState) throws {
        let directory = saveURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
        try gameState.save(to: saveURL)
    }

    func load() throws -> GameState {
        try GameState.load(from: saveURL)
    }

    func delete() throws {
        guard saveExists() else { return }
        try FileManager.default.removeItem(at: saveURL)
    }
}

struct RunSessionController {
    typealias AmbientSyncHandler = (MapNode?) -> Void

    let saveStore: SaveGameStore
    let syncAmbientAudio: AmbientSyncHandler

    init(
        saveStore: SaveGameStore,
        syncAmbientAudio: @escaping AmbientSyncHandler = Self.playAmbientAudio(for:)
    ) {
        self.saveStore = saveStore
        self.syncAmbientAudio = syncAmbientAudio
    }

    func saveExists() -> Bool {
        saveStore.saveExists()
    }

    func saveGame(_ gameState: GameState) throws {
        try saveStore.save(gameState)
    }

    func loadGame(using runtime: inout ScenarioRuntime) throws -> GameState {
        let loaded = try saveStore.load()
        let prepared = runtime.prepareLoadedState(loaded)
        syncAmbientAudio(currentAmbientNode(in: prepared))
        return prepared
    }

    func startNewRun(
        scenario: String = RuntimeDefaults.defaultScenarioID,
        partyPlan: PartyBuildPlan? = nil,
        using runtime: inout ScenarioRuntime
    ) throws -> GameState {
        let gameState = runtime.newGameState(scenario: scenario, partyPlan: partyPlan)
        syncAmbientAudio(startingNode(in: gameState))
        try saveGame(gameState)
        return gameState
    }

    func restartCurrentScenario(
        from gameState: GameState,
        using runtime: inout ScenarioRuntime
    ) throws -> GameState {
        try startNewRun(
            scenario: gameState.scenarioName,
            partyPlan: gameState.launchPartyPlan,
            using: &runtime
        )
    }

    @discardableResult
    func move(
        characterID: UUID,
        to connection: NodeConnection,
        movingGroupedParty: Bool,
        using runtime: inout ScenarioRuntime,
        in gameState: inout GameState
    ) throws -> ScenarioRuntime.MoveOutcome {
        let outcome = runtime.move(
            characterID: characterID,
            to: connection,
            movingGroupedParty: movingGroupedParty,
            in: &gameState
        )
        guard outcome.didMove else { return outcome }

        if let consequences = connection.onTraverse,
           !consequences.isEmpty {
            let traversalContext = ConsequenceContext(
                characterID: characterID,
                interactableID: nil,
                finalEffect: .standard,
                finalPosition: .risky,
                isCritical: false
            )
            _ = PendingResolutionDriver(
                runtime: runtime,
                debugLogging: false
            ).processConsequences(
                consequences,
                context: traversalContext,
                source: .freeAction,
                rollPresentation: nil,
                in: &gameState
            )
        }

        syncAmbientAudio(runtime.node(for: characterID, in: gameState) ?? outcome.enteredNode)
        try saveGame(gameState)
        return outcome
    }

    @discardableResult
    func jumpParty(
        to nodeID: UUID,
        in gameState: inout GameState
    ) throws -> Bool {
        guard let node = gameState.dungeon?.nodes[nodeID.uuidString] else { return false }
        for member in gameState.party where !member.isDefeated {
            gameState.characterLocations[member.id.uuidString] = nodeID
        }
        gameState.dungeon?.nodes[nodeID.uuidString]?.isDiscovered = true
        gameState.currentNodeID = nodeID
        syncAmbientAudio(node)
        try saveGame(gameState)
        return true
    }

    @discardableResult
    func jump(
        characterID: UUID,
        to nodeID: UUID,
        in gameState: inout GameState
    ) throws -> Bool {
        guard let node = gameState.dungeon?.nodes[nodeID.uuidString] else { return false }
        gameState.characterLocations[characterID.uuidString] = nodeID
        gameState.dungeon?.nodes[nodeID.uuidString]?.isDiscovered = true
        gameState.currentNodeID = nodeID
        syncAmbientAudio(node)
        try saveGame(gameState)
        return true
    }

    private func startingNode(in gameState: GameState) -> MapNode? {
        guard let startingNodeID = gameState.dungeon?.startingNodeID else { return nil }
        return gameState.dungeon?.nodes[startingNodeID.uuidString]
    }

    private func currentAmbientNode(in gameState: GameState) -> MapNode? {
        guard let nodeID = gameState.characterLocations.first?.value else {
            return startingNode(in: gameState)
        }
        return gameState.dungeon?.nodes[nodeID.uuidString]
    }

    private static func playAmbientAudio(for node: MapNode?) {
        guard let node else { return }
        AudioManager.shared.play(sound: "ambient_\(node.soundProfile).wav", loop: true)
    }
}

protocol ScenarioEntitlementStoring {
    func loadTestingUnlockedScenarioIDs() -> Set<String>
    func saveTestingUnlockedScenarioIDs(_ scenarioIDs: Set<String>)
    func setTestingUnlocked(_ isUnlocked: Bool, forScenarioID scenarioID: String)
    func resetTestingUnlockedScenarioIDs()
}

struct EntitlementStore: ScenarioEntitlementStoring {
    let userDefaults: UserDefaults
    let storageKey: String

    init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = "scenarioTestingUnlockedIDs"
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    func loadTestingUnlockedScenarioIDs() -> Set<String> {
        let storedScenarioIDs = userDefaults.stringArray(forKey: storageKey) ?? []
        return Set(
            storedScenarioIDs.compactMap { rawID in
                let trimmedID = rawID.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmedID.isEmpty ? nil : trimmedID
            }
        )
    }

    func saveTestingUnlockedScenarioIDs(_ scenarioIDs: Set<String>) {
        userDefaults.set(scenarioIDs.sorted(), forKey: storageKey)
    }

    func setTestingUnlocked(_ isUnlocked: Bool, forScenarioID scenarioID: String) {
        let trimmedID = scenarioID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedID.isEmpty else { return }

        var unlockedScenarioIDs = loadTestingUnlockedScenarioIDs()
        if isUnlocked {
            unlockedScenarioIDs.insert(trimmedID)
        } else {
            unlockedScenarioIDs.remove(trimmedID)
        }
        saveTestingUnlockedScenarioIDs(unlockedScenarioIDs)
    }

    func resetTestingUnlockedScenarioIDs() {
        userDefaults.removeObject(forKey: storageKey)
    }
}
