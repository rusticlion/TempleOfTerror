import XCTest
@testable import CardGame

private final class HookedDungeonGenerator: DungeonGenerator {
    private let fixedMap: DungeonMap
    private let fixedClocks: [GameClock]

    init(
        fixedMap: DungeonMap,
        fixedClocks: [GameClock] = [],
        content: ContentLoader = ContentLoader(scenario: "temple_of_terror")
    ) {
        self.fixedMap = fixedMap
        self.fixedClocks = fixedClocks
        super.init(content: content)
    }

    override func generate(level: Int, manifest: ScenarioManifest? = nil) -> (DungeonMap, [GameClock]) {
        (fixedMap, fixedClocks)
    }
}

final class RunSessionControllerTests: XCTestCase {
    func testRunSessionControllerStartNewRunPersistsAndSyncsStartingNode() throws {
        let tempSave = TestFixtures.makeTemporarySaveStore()
        defer { try? FileManager.default.removeItem(at: tempSave.directory) }

        var syncedNodeID: UUID?
        let controller = RunSessionController(
            saveStore: tempSave.store
        ) { node in
            syncedNodeID = node?.id
        }

        var runtime = ScenarioRuntime()
        let gameState = try controller.startNewRun(
            scenario: "charons_bargain",
            using: &runtime
        )

        XCTAssertEqual(gameState.scenarioName, "charons_bargain")
        XCTAssertTrue(tempSave.store.saveExists())
        XCTAssertEqual(
            syncedNodeID?.uuidString.lowercased(),
            "00000000-0000-0000-0000-000000000001"
        )
    }

    func testRunSessionControllerStartNewRunProcessesStartingNodeHooks() throws {
        let tempSave = TestFixtures.makeTemporarySaveStore()
        defer { try? FileManager.default.removeItem(at: tempSave.directory) }

        let startID = UUID()
        let map = DungeonMap(
            nodes: [
                startID.uuidString: MapNode(
                    id: startID,
                    name: "Hooked Start",
                    soundProfile: "start",
                    interactables: [],
                    connections: [],
                    onEnter: [.incrementScenarioCounter("start_entries", amount: 1)],
                    onFirstEnter: [.setScenarioFlag("start_hook_fired")]
                )
            ],
            startingNodeID: startID
        )

        var runtime = ScenarioRuntime(
            defaultScenario: "temple_of_terror",
            contentLoaderFactory: { _ in ContentLoader(scenario: "temple_of_terror") },
            dungeonGeneratorFactory: { loader in
                HookedDungeonGenerator(fixedMap: map, content: loader)
            }
        )

        let controller = RunSessionController(saveStore: tempSave.store)
        let gameState = try controller.startNewRun(
            scenario: "temple_of_terror",
            using: &runtime
        )

        XCTAssertEqual(gameState.scenarioFlags["start_hook_fired"], true)
        XCTAssertEqual(gameState.scenarioCounters["start_entries"], 1)
        XCTAssertEqual(gameState.triggeredFirstEnterNodeIDs, [startID.uuidString])
        XCTAssertTrue(tempSave.store.saveExists())
    }

    func testRunSessionControllerMovePersistsAndSyncsEnteredNode() throws {
        let tempSave = TestFixtures.makeTemporarySaveStore()
        defer { try? FileManager.default.removeItem(at: tempSave.directory) }

        let startID = UUID()
        let nextID = UUID()
        let connection = NodeConnection(toNodeID: nextID, description: "Advance")
        var runtime = ScenarioRuntime()
        let character = Character(
            id: UUID(),
            name: "Scout",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Prowl": 1]
        )
        var gameState = GameState(
            party: [character],
            dungeon: DungeonMap(
                nodes: [
                    startID.uuidString: MapNode(
                        id: startID,
                        name: "Entry",
                        soundProfile: "entry",
                        interactables: [],
                        connections: [connection]
                    ),
                    nextID.uuidString: MapNode(
                        id: nextID,
                        name: "Vault",
                        soundProfile: "vault",
                        interactables: [],
                        connections: []
                    )
                ],
                startingNodeID: startID
            ),
            characterLocations: [character.id.uuidString: startID]
        )

        var syncedNodeID: UUID?
        let controller = RunSessionController(
            saveStore: tempSave.store
        ) { node in
            syncedNodeID = node?.id
        }

        let outcome = try controller.move(
            characterID: character.id,
            to: connection,
            movingGroupedParty: false,
            using: &runtime,
            in: &gameState
        )

        XCTAssertTrue(outcome.didMove)
        XCTAssertEqual(gameState.characterLocations[character.id.uuidString], nextID)
        XCTAssertEqual(syncedNodeID, nextID)
        XCTAssertTrue(tempSave.store.saveExists())
    }

    func testRunSessionControllerMoveProcessesOnTraverseConsequences() throws {
        let tempSave = TestFixtures.makeTemporarySaveStore()
        defer { try? FileManager.default.removeItem(at: tempSave.directory) }

        let startID = UUID()
        let hallwayID = UUID()
        let poolID = UUID()
        let connection = NodeConnection(
            toNodeID: hallwayID,
            description: "Rush Forward",
            onTraverse: [
                .setScenarioFlag("gate_is_falling"),
                .moveActingCharacterToNode(poolID)
            ]
        )
        var runtime = ScenarioRuntime()
        let character = Character(
            id: UUID(),
            name: "Scout",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Prowl": 1]
        )
        var gameState = GameState(
            party: [character],
            dungeon: DungeonMap(
                nodes: [
                    startID.uuidString: MapNode(
                        id: startID,
                        name: "Spire Base",
                        soundProfile: "base",
                        interactables: [],
                        connections: [connection]
                    ),
                    hallwayID.uuidString: MapNode(
                        id: hallwayID,
                        name: "Far Ledge",
                        soundProfile: "ledge",
                        interactables: [],
                        connections: []
                    ),
                    poolID.uuidString: MapNode(
                        id: poolID,
                        name: "Deep Pool",
                        soundProfile: "pool",
                        interactables: [],
                        connections: []
                    )
                ],
                startingNodeID: startID
            ),
            characterLocations: [character.id.uuidString: startID]
        )

        var syncedNodeID: UUID?
        let controller = RunSessionController(
            saveStore: tempSave.store
        ) { node in
            syncedNodeID = node?.id
        }

        let outcome = try controller.move(
            characterID: character.id,
            to: connection,
            movingGroupedParty: false,
            using: &runtime,
            in: &gameState
        )

        XCTAssertTrue(outcome.didMove)
        XCTAssertEqual(outcome.enteredNode?.id, hallwayID)
        XCTAssertEqual(gameState.characterLocations[character.id.uuidString], poolID)
        XCTAssertEqual(gameState.scenarioFlags["gate_is_falling"], true)
        XCTAssertEqual(syncedNodeID, poolID)
        XCTAssertTrue(tempSave.store.saveExists())
    }

    func testRunSessionControllerMoveProcessesNodeEntryHooksWithFirstEnterOnlyOnce() throws {
        let tempSave = TestFixtures.makeTemporarySaveStore()
        defer { try? FileManager.default.removeItem(at: tempSave.directory) }

        let startID = UUID()
        let vaultID = UUID()
        let forward = NodeConnection(toNodeID: vaultID, description: "Forward")
        let back = NodeConnection(toNodeID: startID, description: "Back")
        var runtime = ScenarioRuntime()
        let character = Character(
            id: UUID(),
            name: "Scout",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Prowl": 1]
        )
        var gameState = GameState(
            party: [character],
            dungeon: DungeonMap(
                nodes: [
                    startID.uuidString: MapNode(
                        id: startID,
                        name: "Entry",
                        soundProfile: "entry",
                        interactables: [],
                        connections: [forward]
                    ),
                    vaultID.uuidString: MapNode(
                        id: vaultID,
                        name: "Vault",
                        soundProfile: "vault",
                        interactables: [],
                        connections: [back],
                        onEnter: [.incrementScenarioCounter("vault_entries", amount: 1)],
                        onFirstEnter: [.setScenarioFlag("vault_first_entered")]
                    )
                ],
                startingNodeID: startID
            ),
            currentNodeID: startID,
            characterLocations: [character.id.uuidString: startID]
        )

        let controller = RunSessionController(saveStore: tempSave.store)

        _ = try controller.move(
            characterID: character.id,
            to: forward,
            movingGroupedParty: false,
            using: &runtime,
            in: &gameState
        )

        XCTAssertEqual(gameState.scenarioFlags["vault_first_entered"], true)
        XCTAssertEqual(gameState.scenarioCounters["vault_entries"], 1)

        _ = try controller.move(
            characterID: character.id,
            to: back,
            movingGroupedParty: false,
            using: &runtime,
            in: &gameState
        )
        _ = try controller.move(
            characterID: character.id,
            to: forward,
            movingGroupedParty: false,
            using: &runtime,
            in: &gameState
        )

        XCTAssertEqual(gameState.scenarioFlags["vault_first_entered"], true)
        XCTAssertEqual(gameState.scenarioCounters["vault_entries"], 2)
        XCTAssertEqual(gameState.triggeredFirstEnterNodeIDs, [vaultID.uuidString])
    }

    func testRunSessionControllerLoadGamePrefersCurrentNodeForAmbientSync() throws {
        let tempSave = TestFixtures.makeTemporarySaveStore()
        defer { try? FileManager.default.removeItem(at: tempSave.directory) }

        let shrineID = UUID()
        let westID = UUID()
        let eastID = UUID()
        let scout = Character(
            id: UUID(),
            name: "Scout",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Prowl": 1]
        )
        let whisper = Character(
            id: UUID(),
            name: "Whisper",
            characterClass: "Occultist",
            stress: 0,
            harm: HarmState(),
            actions: ["Attune": 1]
        )
        let savedState = GameState(
            scenarioName: "charons_bargain",
            party: [scout, whisper],
            dungeon: DungeonMap(
                nodes: [
                    shrineID.uuidString: MapNode(
                        id: shrineID,
                        name: "Shrine",
                        soundProfile: "shrine",
                        interactables: [],
                        connections: []
                    ),
                    westID.uuidString: MapNode(
                        id: westID,
                        name: "West Hall",
                        soundProfile: "west",
                        interactables: [],
                        connections: []
                    ),
                    eastID.uuidString: MapNode(
                        id: eastID,
                        name: "East Hall",
                        soundProfile: "east",
                        interactables: [],
                        connections: []
                    )
                ],
                startingNodeID: westID
            ),
            currentNodeID: shrineID,
            characterLocations: [
                scout.id.uuidString: westID,
                whisper.id.uuidString: eastID
            ]
        )

        try tempSave.store.save(savedState)

        var syncedNodeID: UUID?
        let controller = RunSessionController(
            saveStore: tempSave.store
        ) { node in
            syncedNodeID = node?.id
        }

        var runtime = ScenarioRuntime()
        let loaded = try controller.loadGame(using: &runtime)

        XCTAssertEqual(loaded.currentNodeID, shrineID)
        XCTAssertEqual(syncedNodeID, shrineID)
    }
}
