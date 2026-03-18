import XCTest
@testable import CardGame

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
}
