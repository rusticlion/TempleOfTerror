import XCTest
@testable import CardGame

final class ScenarioRuntimeTests: XCTestCase {
    func testScenarioRuntimeGroupedMoveUpdatesPartyLocationsAndDiscovery() throws {
        let startID = UUID()
        let nextID = UUID()
        let connection = NodeConnection(toNodeID: nextID, description: "Forward")
        let runtime = ScenarioRuntime()

        let startNode = MapNode(
            id: startID,
            name: "Start",
            soundProfile: "",
            interactables: [],
            connections: [connection]
        )
        let nextNode = MapNode(
            id: nextID,
            name: "Next",
            soundProfile: "",
            interactables: [],
            connections: [],
            isDiscovered: false
        )

        let scout = Character(id: UUID(), name: "Scout", characterClass: "Scout", stress: 0, harm: HarmState(), actions: ["Prowl": 1])
        let scholar = Character(id: UUID(), name: "Scholar", characterClass: "Scholar", stress: 0, harm: HarmState(), actions: ["Study": 1])
        var gameState = GameState(
            party: [scout, scholar],
            dungeon: DungeonMap(
                nodes: [
                    startID.uuidString: startNode,
                    nextID.uuidString: nextNode
                ],
                startingNodeID: startID
            ),
            characterLocations: [
                scout.id.uuidString: startID,
                scholar.id.uuidString: startID
            ]
        )

        let outcome = runtime.move(
            characterID: scout.id,
            to: connection,
            movingGroupedParty: true,
            in: &gameState
        )

        XCTAssertTrue(outcome.didMove)
        XCTAssertEqual(gameState.characterLocations[scout.id.uuidString], nextID)
        XCTAssertEqual(gameState.characterLocations[scholar.id.uuidString], nextID)
        XCTAssertEqual(gameState.dungeon?.nodes[nextID.uuidString]?.isDiscovered, true)
        XCTAssertEqual(outcome.enteredNode?.id, nextID)
    }

    func testScenarioRuntimeVisibleInteractablesKeepPressureOptionsDuringThreat() throws {
        let nodeID = UUID()
        let runtime = ScenarioRuntime()
        let threat = Interactable(
            id: "cb_corrupted_maintenance_droid",
            title: "Corrupted Maintenance Droid",
            description: "",
            availableActions: [],
            isThreat: true
        )
        let console = Interactable(
            id: "engineering_override_console",
            title: "Engineering Override Console",
            description: "",
            availableActions: [],
            usableUnderThreat: true
        )
        let stash = Interactable(
            id: "hidden_supplies",
            title: "Hidden Supplies",
            description: "",
            availableActions: []
        )
        let character = Character(
            id: UUID(),
            name: "Engineer",
            characterClass: "Engineer",
            stress: 0,
            harm: HarmState(),
            actions: ["Tinker": 1]
        )
        let gameState = GameState(
            party: [character],
            dungeon: DungeonMap(
                nodes: [
                    nodeID.uuidString: MapNode(
                        id: nodeID,
                        name: "Engineering",
                        soundProfile: "",
                        interactables: [stash, console, threat],
                        connections: []
                    )
                ],
                startingNodeID: nodeID
            ),
            characterLocations: [character.id.uuidString: nodeID]
        )

        XCTAssertEqual(
            runtime.visibleInteractables(for: character.id, in: gameState).map(\.id),
            ["cb_corrupted_maintenance_droid", "engineering_override_console"]
        )
    }

    func testScenarioRuntimeMoveBlockedWhileCharacterEngagedByThreat() throws {
        let startID = UUID()
        let nextID = UUID()
        let connection = NodeConnection(toNodeID: nextID, description: "Retreat")
        let runtime = ScenarioRuntime()
        let threat = Interactable(
            id: "void_leech",
            title: "Void Leech",
            description: "",
            availableActions: [],
            isThreat: true
        )
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
                        name: "Hold",
                        soundProfile: "",
                        interactables: [threat],
                        connections: [connection]
                    ),
                    nextID.uuidString: MapNode(
                        id: nextID,
                        name: "Passage",
                        soundProfile: "",
                        interactables: [],
                        connections: []
                    )
                ],
                startingNodeID: startID
            ),
            characterLocations: [character.id.uuidString: startID]
        )

        let outcome = runtime.move(
            characterID: character.id,
            to: connection,
            movingGroupedParty: false,
            in: &gameState
        )

        XCTAssertFalse(outcome.didMove)
        XCTAssertEqual(gameState.characterLocations[character.id.uuidString], startID)
        XCTAssertNil(outcome.enteredNode)
    }

    func testScenarioRuntimeThreatEngagementIsLocalToThreatenedNode() throws {
        let threatNodeID = UUID()
        let safeNodeID = UUID()
        let destinationID = UUID()
        let safeConnection = NodeConnection(toNodeID: destinationID, description: "Advance")
        let runtime = ScenarioRuntime()
        let threat = Interactable(
            id: "guardian",
            title: "Guardian",
            description: "",
            availableActions: [],
            isThreat: true
        )
        let scout = Character(
            id: UUID(),
            name: "Scout",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Prowl": 1]
        )
        let scholar = Character(
            id: UUID(),
            name: "Scholar",
            characterClass: "Scholar",
            stress: 0,
            harm: HarmState(),
            actions: ["Study": 1]
        )
        var gameState = GameState(
            party: [scout, scholar],
            dungeon: DungeonMap(
                nodes: [
                    threatNodeID.uuidString: MapNode(
                        id: threatNodeID,
                        name: "Bridge",
                        soundProfile: "",
                        interactables: [threat],
                        connections: []
                    ),
                    safeNodeID.uuidString: MapNode(
                        id: safeNodeID,
                        name: "Med Bay",
                        soundProfile: "",
                        interactables: [],
                        connections: [safeConnection]
                    ),
                    destinationID.uuidString: MapNode(
                        id: destinationID,
                        name: "Archive",
                        soundProfile: "",
                        interactables: [],
                        connections: []
                    )
                ],
                startingNodeID: threatNodeID
            ),
            characterLocations: [
                scout.id.uuidString: threatNodeID,
                scholar.id.uuidString: safeNodeID
            ]
        )

        XCTAssertTrue(runtime.isCharacterEngaged(scout.id, in: gameState))
        XCTAssertFalse(runtime.isCharacterEngaged(scholar.id, in: gameState))

        let outcome = runtime.move(
            characterID: scholar.id,
            to: safeConnection,
            movingGroupedParty: false,
            in: &gameState
        )

        XCTAssertTrue(outcome.didMove)
        XCTAssertEqual(gameState.characterLocations[scout.id.uuidString], threatNodeID)
        XCTAssertEqual(gameState.characterLocations[scholar.id.uuidString], destinationID)
    }

    func testScenarioRuntimeMoveBlockedByUnmetConnectionConditions() throws {
        let startID = UUID()
        let nextID = UUID()
        let conditionedConnection = NodeConnection(
            toNodeID: nextID,
            description: "Slip Through",
            conditions: [GameCondition(type: .scenarioFlagSet, stringParam: "gate_open")]
        )
        let runtime = ScenarioRuntime()
        let scout = Character(
            id: UUID(),
            name: "Scout",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Prowl": 1]
        )
        var gameState = GameState(
            party: [scout],
            dungeon: DungeonMap(
                nodes: [
                    startID.uuidString: MapNode(
                        id: startID,
                        name: "Antechamber",
                        soundProfile: "",
                        interactables: [],
                        connections: [conditionedConnection]
                    ),
                    nextID.uuidString: MapNode(
                        id: nextID,
                        name: "Inner Vault",
                        soundProfile: "",
                        interactables: [],
                        connections: []
                    )
                ],
                startingNodeID: startID
            ),
            characterLocations: [scout.id.uuidString: startID]
        )

        XCTAssertFalse(runtime.canTraverse(characterID: scout.id, via: conditionedConnection, in: gameState))
        XCTAssertFalse(
            runtime.move(
                characterID: scout.id,
                to: conditionedConnection,
                movingGroupedParty: false,
                in: &gameState
            ).didMove
        )

        gameState.scenarioFlags["gate_open"] = true

        XCTAssertTrue(runtime.canTraverse(characterID: scout.id, via: conditionedConnection, in: gameState))
    }

    func testScenarioRuntimeMoveCharacterDiscoversDestinationNode() throws {
        let startID = UUID()
        let nextID = UUID()
        let runtime = ScenarioRuntime()
        let scout = Character(
            id: UUID(),
            name: "Scout",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Prowl": 1]
        )
        var gameState = GameState(
            party: [scout],
            dungeon: DungeonMap(
                nodes: [
                    startID.uuidString: MapNode(
                        id: startID,
                        name: "Spire Top",
                        soundProfile: "",
                        interactables: [],
                        connections: []
                    ),
                    nextID.uuidString: MapNode(
                        id: nextID,
                        name: "Black Pool",
                        soundProfile: "",
                        interactables: [],
                        connections: [],
                        isDiscovered: false
                    )
                ],
                startingNodeID: startID
            ),
            characterLocations: [scout.id.uuidString: startID]
        )

        let movedNode = runtime.moveCharacter(id: scout.id, toNodeID: nextID, in: &gameState)

        XCTAssertEqual(movedNode?.id, nextID)
        XCTAssertEqual(gameState.characterLocations[scout.id.uuidString], nextID)
        XCTAssertEqual(gameState.dungeon?.nodes[nextID.uuidString]?.isDiscovered, true)
    }

    func testScenarioRuntimeCanLockAndUnlockConnections() throws {
        let startID = UUID()
        let nextID = UUID()
        let connection = NodeConnection(toNodeID: nextID, description: "Forward")
        let runtime = ScenarioRuntime()
        var gameState = GameState(
            dungeon: DungeonMap(
                nodes: [
                    startID.uuidString: MapNode(
                        id: startID,
                        name: "Entry",
                        soundProfile: "",
                        interactables: [],
                        connections: [connection]
                    ),
                    nextID.uuidString: MapNode(
                        id: nextID,
                        name: "Hall",
                        soundProfile: "",
                        interactables: [],
                        connections: []
                    )
                ],
                startingNodeID: startID
            )
        )

        XCTAssertTrue(runtime.lockConnection(fromNodeID: startID, toNodeID: nextID, in: &gameState))
        XCTAssertEqual(gameState.dungeon?.nodes[startID.uuidString]?.connections.first?.isUnlocked, false)
        XCTAssertTrue(runtime.unlockConnection(fromNodeID: startID, toNodeID: nextID, in: &gameState))
        XCTAssertEqual(gameState.dungeon?.nodes[startID.uuidString]?.connections.first?.isUnlocked, true)
    }
}
