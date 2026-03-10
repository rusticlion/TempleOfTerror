//
//  CardGameTests.swift
//  CardGameTests
//
//  Created by Russell Leon Bates IV on 5/28/25.
//

import XCTest
@testable import CardGame

final class CardGameTests: XCTestCase {
    private static var scenariosRootURL: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Content/Scenarios", isDirectory: true)
    }

    private static var contentRootURL: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Content", isDirectory: true)
    }

    private func makeViewModel(scenario: String = RuntimeDefaults.defaultScenarioID) -> GameViewModel {
        var runtime = ScenarioRuntime()
        _ = runtime.activateScenario(named: scenario)
        let viewModel = GameViewModel(runtime: runtime)
        viewModel.gameState.scenarioName = scenario
        return viewModel
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testRemoveActionConsequence() throws {
        // Set up a simple game state with one interactable
        let vm = GameViewModel()
        let nodeID = UUID()
        let action1 = ActionOption(name: "Open",
                                   actionType: "Skirmish",
                                   position: .risky,
                                   effect: .standard)
        let action2 = ActionOption(name: "Look",
                                   actionType: "Survey",
                                   position: .risky,
                                   effect: .standard)
        let interactable = Interactable(id: "test",
                                        title: "Test",
                                        description: "Test",
                                        availableActions: [action1, action2])
        let node = MapNode(id: nodeID,
                           name: "Room",
                           soundProfile: "",
                           interactables: [interactable],
                           connections: [])
        vm.gameState.dungeon = DungeonMap(nodes: [nodeID.uuidString: node],
                                          startingNodeID: nodeID)

        let character = Character(id: UUID(),
                                  name: "Hero",
                                  characterClass: "Rogue",
                                  stress: 0,
                                  harm: HarmState(),
                                  actions: ["Skirmish": 1, "Survey": 1],
                                  treasures: [],
                                  modifiers: [])
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = nodeID

        let removeCon = Consequence.removeAction(name: "Open", fromInteractable: "self")
        let dummyAction = ActionOption(name: "Trigger",
                                       actionType: "Skirmish",
                                       position: .risky,
                                       effect: .standard,
                                       requiresTest: false,
                                       outcomes: [.success: [removeCon, .removeAction(name: "Trigger", fromInteractable: "self")]])
        vm.gameState.dungeon?.nodes[nodeID.uuidString]?.interactables[0].availableActions.append(dummyAction)

        _ = vm.performFreeAction(for: dummyAction, with: character, interactableID: "test")

        let remaining = vm.gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.first?.availableActions.map { $0.name }
        XCTAssertEqual(remaining, ["Look"])
    }

    func testAddActionConsequence() throws {
        let vm = GameViewModel()
        let nodeID = UUID()
        let action1 = ActionOption(name: "Look",
                                   actionType: "Survey",
                                   position: .risky,
                                   effect: .standard)
        let interactable = Interactable(id: "test",
                                        title: "Test",
                                        description: "Test",
                                        availableActions: [action1])
        let node = MapNode(id: nodeID,
                           name: "Room",
                           soundProfile: "",
                           interactables: [interactable],
                           connections: [])
        vm.gameState.dungeon = DungeonMap(nodes: [nodeID.uuidString: node],
                                          startingNodeID: nodeID)

        let character = Character(id: UUID(),
                                  name: "Hero",
                                  characterClass: "Rogue",
                                  stress: 0,
                                  harm: HarmState(),
                                  actions: ["Skirmish": 1, "Survey": 1],
                                  treasures: [],
                                  modifiers: [])
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = nodeID

        let newAct = ActionOption(name: "Open",
                                  actionType: "Skirmish",
                                  position: .risky,
                                  effect: .standard)
        let addCon = Consequence.addAction(newAct, toInteractable: "self")
        let dummy = ActionOption(name: "Trigger",
                                 actionType: "Skirmish",
                                 position: .risky,
                                 effect: .standard,
                                 requiresTest: false,
                                 outcomes: [.success: [addCon, .removeAction(name: "Trigger", fromInteractable: "self")]])
        vm.gameState.dungeon?.nodes[nodeID.uuidString]?.interactables[0].availableActions.append(dummy)

        _ = vm.performFreeAction(for: dummy, with: character, interactableID: "test")

        let names = vm.gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.first?.availableActions.map { $0.name }
        XCTAssertEqual(Set(names ?? []), Set(["Look", "Open"]))
    }

    func testRemoveInteractableConsequence() throws {
        let vm = GameViewModel()
        let nodeID = UUID()
        let action = ActionOption(name: "Trigger",
                                  actionType: "Skirmish",
                                  position: .risky,
                                  effect: .standard,
                                  requiresTest: false,
                                  outcomes: [.success: [.removeInteractable(id: "target")]])
        let target = Interactable(id: "target",
                                  title: "Target",
                                  description: "",
                                  availableActions: [action])
        let node = MapNode(id: nodeID,
                           name: "Room",
                           soundProfile: "",
                           interactables: [target],
                           connections: [])
        vm.gameState.dungeon = DungeonMap(nodes: [nodeID.uuidString: node],
                                          startingNodeID: nodeID)

        let character = Character(id: UUID(),
                                  name: "Hero",
                                  characterClass: "Rogue",
                                  stress: 0,
                                  harm: HarmState(),
                                  actions: ["Skirmish": 1],
                                  treasures: [],
                                  modifiers: [])
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = nodeID

        _ = vm.performFreeAction(for: action, with: character, interactableID: "target")

        let remaining = vm.gameState.dungeon?.nodes[nodeID.uuidString]?.interactables
        XCTAssertTrue(remaining?.isEmpty ?? false)
    }

    func testHealHarmConsequence() throws {
        let vm = makeViewModel()
        let nodeID = UUID()
        let node = MapNode(id: nodeID,
                           name: "Room",
                           soundProfile: "",
                           interactables: [],
                           connections: [])
        vm.gameState.dungeon = DungeonMap(nodes: [nodeID.uuidString: node],
                                          startingNodeID: nodeID)

        var harm = HarmState()
        harm.lesser = [(familyId: "head_trauma", description: "Headache")]
        harm.moderate = [(familyId: "leg_injury", description: "Torn Muscle")]
        harm.severe = [(familyId: "gear_damage", description: "Lost Map")]

        let character = Character(id: UUID(),
                                  name: "Healer",
                                  characterClass: "Cleric",
                                  stress: 0,
                                  harm: harm,
                                  actions: ["Study": 1],
                                  treasures: [],
                                  modifiers: [])
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = nodeID

        let healCon = Consequence.healHarm
        let action = ActionOption(name: "Heal",
                                 actionType: "Study",
                                 position: .risky,
                                 effect: .standard,
                                 requiresTest: false,
                                 outcomes: [.success: [healCon]])

        _ = vm.performFreeAction(for: action, with: character, interactableID: nil)

        let updated = vm.gameState.party[0].harm
        XCTAssertTrue(updated.severe.isEmpty)
        XCTAssertEqual(updated.moderate.count, 1)
        XCTAssertEqual(updated.moderate[0].description, "Broken Tools")
        XCTAssertEqual(updated.lesser.count, 1)
        XCTAssertEqual(updated.lesser[0].description, "Twisted Ankle")
    }

    func testAdjustStressRecoversStressAndClampsAtZero() throws {
        let vm = GameViewModel()
        let character = Character(
            id: UUID(),
            name: "Steady",
            characterClass: "Scholar",
            stress: 1,
            harm: HarmState(),
            actions: ["Study": 1]
        )
        vm.gameState.party = [character]

        let action = ActionOption(
            name: "Catch Your Breath",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            requiresTest: false,
            outcomes: [.success: [.adjustStress(-3)]]
        )

        let description = vm.performFreeAction(for: action, with: character, interactableID: nil)

        XCTAssertEqual(vm.gameState.party[0].stress, 0)
        XCTAssertTrue(description.contains("Recovered 1 Stress."))
    }

    func testRestartCurrentScenarioKeepsScenarioSelection() throws {
        let vm = GameViewModel()
        vm.startNewRun(scenario: "charons_bargain")
        vm.restartCurrentScenario()

        XCTAssertEqual(vm.gameState.scenarioName, "charons_bargain")
        XCTAssertEqual(vm.gameState.dungeon?.startingNodeID.uuidString.lowercased(),
                       "00000000-0000-0000-0000-000000000001")
    }

    func testTriggerEventSetsRunEndingState() throws {
        let cases: [(eventID: String, outcome: RunOutcome)] = [
            ("game_over_coward_ending", .escaped),
            ("cb_reactor_meltdown", .defeat),
            ("cb_vfe_deactivated", .victory)
        ]

        for testCase in cases {
            let vm = makeViewModel(scenario: "charons_bargain")
            let nodeID = UUID()
            let node = MapNode(id: nodeID,
                               name: "Room",
                               soundProfile: "",
                               interactables: [],
                               connections: [])
            vm.gameState.dungeon = DungeonMap(nodes: [nodeID.uuidString: node],
                                              startingNodeID: nodeID)

            let character = Character(id: UUID(),
                                      name: "Trigger Tester",
                                      characterClass: "Rogue",
                                      stress: 0,
                                      harm: HarmState(),
                                      actions: ["Study": 1],
                                      treasures: [],
                                      modifiers: [])
            vm.gameState.party = [character]
            vm.gameState.characterLocations[character.id.uuidString] = nodeID

            let action = ActionOption(name: "Trigger",
                                      actionType: "Study",
                                      position: .controlled,
                                      effect: .standard,
                                      requiresTest: false,
                                      outcomes: [.success: [.triggerEvent(id: testCase.eventID)]])

            _ = vm.performFreeAction(for: action, with: character, interactableID: nil)

            XCTAssertEqual(vm.gameState.status, .gameOver)
            XCTAssertEqual(vm.gameState.runOutcome, testCase.outcome)
            XCTAssertNotNil(vm.gameState.runOutcomeText)
        }
    }

    func testAuthoredEventUpdatesScenarioState() throws {
        let vm = makeViewModel(scenario: "charons_bargain")
        let nodeID = UUID()
        let node = MapNode(id: nodeID,
                           name: "Room",
                           soundProfile: "",
                           interactables: [],
                           connections: [])
        vm.gameState.dungeon = DungeonMap(nodes: [nodeID.uuidString: node],
                                          startingNodeID: nodeID)

        let character = Character(id: UUID(),
                                  name: "Archivist",
                                  characterClass: "Scholar",
                                  stress: 0,
                                  harm: HarmState(),
                                  actions: ["Study": 1],
                                  treasures: [],
                                  modifiers: [])
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = nodeID

        let beaconInfo = ActionOption(name: "Trigger Beacon Status",
                                       actionType: "Study",
                                       position: .controlled,
                                       effect: .standard,
                                       requiresTest: false,
                                       outcomes: [.success: [.triggerEvent(id: "cb_beacon_partially_active")]])
        let fullInfo = ActionOption(name: "Trigger Full Info",
                                    actionType: "Study",
                                    position: .controlled,
                                    effect: .standard,
                                    requiresTest: false,
                                    outcomes: [.success: [.triggerEvent(id: "cb_ng_reveals_lab_location")]])

        _ = vm.performFreeAction(for: beaconInfo, with: character, interactableID: nil)
        _ = vm.performFreeAction(for: fullInfo, with: character, interactableID: nil)

        XCTAssertEqual(vm.gameState.scenarioFlags["cb_beacon_partially_active"], true)
        XCTAssertEqual(vm.gameState.scenarioFlags["cb_lab_location_known"], true)
    }

    func testAuthoredEventUsesRunContentAfterSharedLoaderChanges() throws {
        let vm = GameViewModel()
        vm.startNewRun(scenario: "charons_bargain")

        guard let character = vm.gameState.party.first else {
            return XCTFail("Expected a party member in the started run.")
        }

        ContentLoader.shared = ContentLoader()

        let action = ActionOption(
            name: "Trigger Full Info",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            requiresTest: false,
            outcomes: [.success: [.triggerEvent(id: "cb_ng_reveals_lab_location")]]
        )

        _ = vm.performFreeAction(for: action, with: character, interactableID: nil)

        XCTAssertEqual(vm.gameState.scenarioFlags["cb_lab_location_known"], true)
    }

    func testAuthoredEventCanRelocateThreatAcrossNodes() throws {
        let vm = makeViewModel(scenario: "charons_bargain")

        let engineeringID = UUID(uuidString: "00000000-0000-0000-0000-000000000009")!
        let corridorID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let quartersID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
        let podsID = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!

        let evade = ActionOption(name: "Evade Droid",
                                 actionType: "Finesse",
                                 position: .controlled,
                                 effect: .standard,
                                 requiresTest: false,
                                 outcomes: [.success: [.triggerEvent(id: "cb_droid_evaded_moves_node")]])
        let placeholderDroid = Interactable(id: "cb_corrupted_maintenance_droid",
                                            title: "Corrupted Maintenance Droid",
                                            description: "",
                                            availableActions: [evade])
        let engineering = MapNode(id: engineeringID,
                                  name: "Engineering",
                                  soundProfile: "",
                                  interactables: [placeholderDroid],
                                  connections: [])
        let corridor = MapNode(id: corridorID,
                               name: "Main Corridor",
                               soundProfile: "",
                               interactables: [],
                               connections: [])
        let quarters = MapNode(id: quartersID,
                               name: "Crew Quarters",
                               soundProfile: "",
                               interactables: [],
                               connections: [])
        let pods = MapNode(id: podsID,
                           name: "Escape Pods",
                           soundProfile: "",
                           interactables: [],
                           connections: [])

        vm.gameState.dungeon = DungeonMap(
            nodes: [
                engineeringID.uuidString: engineering,
                corridorID.uuidString: corridor,
                quartersID.uuidString: quarters,
                podsID.uuidString: pods
            ],
            startingNodeID: engineeringID
        )

        let character = Character(id: UUID(),
                                  name: "Runner",
                                  characterClass: "Scout",
                                  stress: 0,
                                  harm: HarmState(),
                                  actions: ["Finesse": 1],
                                  treasures: [],
                                  modifiers: [])
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = engineeringID

        _ = vm.performFreeAction(for: evade, with: character, interactableID: "cb_corrupted_maintenance_droid")

        XCTAssertFalse(vm.gameState.dungeon?.nodes[engineeringID.uuidString]?.interactables.contains(where: { $0.id == "cb_corrupted_maintenance_droid" }) ?? true)
        XCTAssertTrue(vm.gameState.dungeon?.nodes[corridorID.uuidString]?.interactables.contains(where: { $0.id == "cb_corrupted_maintenance_droid" }) ?? false)
        XCTAssertEqual(vm.gameState.scenarioCounters["cb_droid_relocations"], 1)

        vm.gameState.characterLocations[character.id.uuidString] = corridorID
        _ = vm.performFreeAction(for: evade, with: character, interactableID: "cb_corrupted_maintenance_droid")

        XCTAssertFalse(vm.gameState.dungeon?.nodes[corridorID.uuidString]?.interactables.contains(where: { $0.id == "cb_corrupted_maintenance_droid" }) ?? true)
        XCTAssertTrue(vm.gameState.dungeon?.nodes[quartersID.uuidString]?.interactables.contains(where: { $0.id == "cb_corrupted_maintenance_droid" }) ?? false)
        XCTAssertEqual(vm.gameState.scenarioCounters["cb_droid_relocations"], 2)
    }

    func testVisibleInteractablesHideConditionGatedActions() throws {
        let vm = GameViewModel()
        let nodeID = UUID()
        let hiddenAction = ActionOption(
            name: "Open Maintenance Hatch",
            actionType: "Tinker",
            position: .controlled,
            effect: .standard,
            requiresTest: false,
            conditions: [GameCondition(type: .scenarioFlagSet, stringParam: "hatch_open")],
            outcomes: [.success: []]
        )
        let inspectAction = ActionOption(
            name: "Inspect Console",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            requiresTest: false,
            outcomes: [.success: []]
        )
        let console = Interactable(
            id: "maintenance_console",
            title: "Maintenance Console",
            description: "",
            availableActions: [inspectAction, hiddenAction]
        )
        let node = MapNode(
            id: nodeID,
            name: "Maintenance",
            soundProfile: "",
            interactables: [console],
            connections: []
        )
        let character = Character(
            id: UUID(),
            name: "Engineer",
            characterClass: "Engineer",
            stress: 0,
            harm: HarmState(),
            actions: ["Study": 1, "Tinker": 1]
        )
        vm.gameState.dungeon = DungeonMap(nodes: [nodeID.uuidString: node], startingNodeID: nodeID)
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = nodeID

        XCTAssertEqual(
            vm.visibleInteractables(for: character.id).first?.availableActions.map(\.name),
            ["Inspect Console"]
        )

        vm.gameState.scenarioFlags["hatch_open"] = true

        XCTAssertEqual(
            Set(vm.visibleInteractables(for: character.id).first?.availableActions.map(\.name) ?? []),
            Set(["Inspect Console", "Open Maintenance Hatch"])
        )
    }

    func testConditionHiddenThreatDoesNotEngageOrBlockMovement() throws {
        let startID = UUID()
        let nextID = UUID()
        let connection = NodeConnection(toNodeID: nextID, description: "Advance")
        let runtime = ScenarioRuntime()
        let hiddenThreat = Interactable(
            id: "lurker",
            title: "Lurker",
            description: "",
            availableActions: [],
            conditions: [GameCondition(type: .scenarioFlagSet, stringParam: "lurker_awake")],
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
                        name: "Passage",
                        soundProfile: "",
                        interactables: [hiddenThreat],
                        connections: [connection]
                    ),
                    nextID.uuidString: MapNode(
                        id: nextID,
                        name: "Exit",
                        soundProfile: "",
                        interactables: [],
                        connections: []
                    )
                ],
                startingNodeID: startID
            ),
            characterLocations: [character.id.uuidString: startID]
        )

        XCTAssertFalse(runtime.isCharacterEngaged(character.id, in: gameState))

        let outcome = runtime.move(
            characterID: character.id,
            to: connection,
            movingGroupedParty: false,
            in: &gameState
        )

        XCTAssertTrue(outcome.didMove)
        XCTAssertEqual(gameState.characterLocations[character.id.uuidString], nextID)
    }

    func testPerformFreeActionRejectsStaleConditionGatedAction() throws {
        let vm = GameViewModel()
        let nodeID = UUID()
        let gatedAction = ActionOption(
            name: "Override Lock",
            actionType: "Tinker",
            position: .controlled,
            effect: .standard,
            requiresTest: false,
            conditions: [GameCondition(type: .scenarioFlagSet, stringParam: "override_available")],
            outcomes: [.success: [.setScenarioFlag("override_fired")]]
        )
        let terminal = Interactable(
            id: "sealed_terminal",
            title: "Sealed Terminal",
            description: "",
            availableActions: [gatedAction]
        )
        let node = MapNode(
            id: nodeID,
            name: "Security",
            soundProfile: "",
            interactables: [terminal],
            connections: []
        )
        let character = Character(
            id: UUID(),
            name: "Breaker",
            characterClass: "Engineer",
            stress: 0,
            harm: HarmState(),
            actions: ["Tinker": 1]
        )
        vm.gameState.dungeon = DungeonMap(nodes: [nodeID.uuidString: node], startingNodeID: nodeID)
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = nodeID
        vm.gameState.scenarioFlags["override_available"] = true

        let staleAction = try XCTUnwrap(vm.visibleInteractables(for: character.id).first?.availableActions.first)
        vm.gameState.scenarioFlags.removeValue(forKey: "override_available")

        let description = vm.performFreeAction(
            for: staleAction,
            with: character,
            interactableID: "sealed_terminal"
        )

        XCTAssertEqual(description, "That action is no longer available.")
        XCTAssertNil(vm.gameState.scenarioFlags["override_fired"])
    }

    func testPackagedScenariosHaveNoValidationErrors() throws {
        let reports = ScenarioValidator().validateAllScenarios(at: Self.scenariosRootURL)
        XCTAssertFalse(reports.isEmpty, "Expected at least one packaged scenario to validate.")

        let failingReports = reports.filter { !$0.errors.isEmpty }
        XCTAssertTrue(
            failingReports.isEmpty,
            failingReports.map(\.formattedDescription).joined(separator: "\n\n")
        )
    }

    func testScenarioCatalogLoadsFromContentManifest() throws {
        let catalogURL = Self.contentRootURL.appendingPathComponent("scenario_catalog.json")
        let manifest = try ContentLoader.loadScenarioCatalog(from: catalogURL)

        XCTAssertEqual(manifest.schemaVersion, 1)
        XCTAssertEqual(manifest.scenarios.map(\.scenarioID), [
            "temple_of_terror",
            "shadow_of_a_doubt",
            "charons_bargain"
        ])
    }

    func testScenarioCatalogIncludesLaunchPricingAndPurchaseMetadata() throws {
        let catalogURL = Self.contentRootURL.appendingPathComponent("scenario_catalog.json")
        let manifest = try ContentLoader.loadScenarioCatalog(from: catalogURL)

        let temple = try XCTUnwrap(manifest.entry(for: "temple_of_terror"))
        XCTAssertEqual(temple.availabilityModel, .included)
        XCTAssertEqual(temple.priceTier, .standard)
        XCTAssertEqual(temple.contentStatus, .bundled)
        XCTAssertTrue(temple.recommendedStart)
        XCTAssertNil(temple.productID)
        XCTAssertTrue(temple.matches(scenarioID: "tomb"))

        let bargain = try XCTUnwrap(manifest.entry(for: "charons_bargain"))
        XCTAssertEqual(bargain.availabilityModel, .iap)
        XCTAssertEqual(bargain.priceTier, .premium)
        XCTAssertEqual(bargain.contentStatus, .bundled)
        XCTAssertEqual(bargain.productID, "com.russellbates.dicedelver.scenario.charons_bargain")
    }

    func testCatalogResolutionBridgesTempleToLegacyTombRuntime() throws {
        let catalogURL = Self.contentRootURL.appendingPathComponent("scenario_catalog.json")
        let catalog = try ContentLoader.loadScenarioCatalog(from: catalogURL)
        let resolved = ContentLoader.resolveCatalogEntries(
            catalog,
            availableScenarios: [
                ScenarioManifest(
                    id: "tomb",
                    title: "Forgotten Tomb",
                    description: "Legacy tomb prototype."
                ),
                ScenarioManifest(
                    id: "charons_bargain",
                    title: "Charon's Bargain",
                    description: "Premium freighter horror scenario."
                )
            ]
        )

        let temple = try XCTUnwrap(resolved.first(where: { $0.catalogEntry.scenarioID == "temple_of_terror" }))
        XCTAssertEqual(temple.runtimeScenarioID, "tomb")
        XCTAssertEqual(temple.runtimeManifest?.id, "tomb")
        XCTAssertTrue(temple.isStartable)

        let shadow = try XCTUnwrap(resolved.first(where: { $0.catalogEntry.scenarioID == "shadow_of_a_doubt" }))
        XCTAssertNil(shadow.runtimeScenarioID)
        XCTAssertFalse(shadow.isStartable)
        XCTAssertTrue(shadow.isComingSoon)
    }

    func testCatalogResolutionPrefersTempleRuntimeOverLegacyTombWhenBothExist() throws {
        let catalogURL = Self.contentRootURL.appendingPathComponent("scenario_catalog.json")
        let catalog = try ContentLoader.loadScenarioCatalog(from: catalogURL)
        let resolved = ContentLoader.resolveCatalogEntries(
            catalog,
            availableScenarios: [
                ScenarioManifest(
                    id: "tomb",
                    title: "Forgotten Tomb",
                    description: "Legacy tomb prototype."
                ),
                ScenarioManifest(
                    id: "temple_of_terror",
                    title: "Temple of Terror",
                    description: "New fixed-map temple scenario."
                )
            ]
        )

        let temple = try XCTUnwrap(resolved.first(where: { $0.catalogEntry.scenarioID == "temple_of_terror" }))
        XCTAssertEqual(temple.runtimeScenarioID, "temple_of_terror")
        XCTAssertEqual(temple.runtimeManifest?.title, "Temple of Terror")
        XCTAssertTrue(temple.isStartable)
    }

    func testScenarioValidatorRejectsUnsupportedActionTypes() throws {
        let scenarioID = "validator_bad_action"
        let fixture = try makeValidatorFixtureRoot(scenarioID: scenarioID)
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let invalidAction = ActionOption(
            name: "Do Something Impossible",
            actionType: "Dance",
            position: .risky,
            effect: .standard,
            outcomes: [.success: [.gainStress(1)]]
        )
        let interactable = Interactable(
            id: "invalid_action_test",
            title: "Broken Console",
            description: "This should fail validation.",
            availableActions: [invalidAction]
        )
        try writeJSON([interactable], to: fixture.scenarioURL.appendingPathComponent("interactables.json"))

        let report = ScenarioValidator().validateScenario(at: fixture.scenarioURL)
        XCTAssertTrue(
            report.errors.contains(where: { $0.message.contains("Unsupported actionType 'Dance'") }),
            report.formattedDescription
        )
    }

    func testScenarioValidatorWarnsForUnreachableFixedMapNodes() throws {
        let scenarioID = "validator_unreachable_node"
        let fixture = try makeValidatorFixtureRoot(scenarioID: scenarioID, mapFile: "map.json")
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let entryNodeID = UUID(uuidString: "00000000-0000-0000-0000-000000000101")!
        let unreachableNodeID = UUID(uuidString: "00000000-0000-0000-0000-000000000102")!
        let map = DungeonMap(
            nodes: [
                entryNodeID.uuidString: MapNode(
                    id: entryNodeID,
                    name: "Entry",
                    soundProfile: "",
                    interactables: [],
                    connections: [NodeConnection(toNodeID: entryNodeID, description: "Loop")]
                ),
                unreachableNodeID.uuidString: MapNode(
                    id: unreachableNodeID,
                    name: "Isolated Wing",
                    soundProfile: "",
                    interactables: [],
                    connections: []
                )
            ],
            startingNodeID: entryNodeID
        )
        try writeJSON(map, to: fixture.scenarioURL.appendingPathComponent("map.json"))

        let report = ScenarioValidator().validateScenario(at: fixture.scenarioURL)
        XCTAssertTrue(
            report.warnings.contains(where: { $0.message.contains("Node is unreachable from the scenario entry node.") }),
            report.formattedDescription
        )
    }

    func testScenarioValidatorWarnsForLikelySoftLockNodes() throws {
        let scenarioID = "validator_soft_lock"
        let fixture = try makeValidatorFixtureRoot(scenarioID: scenarioID, mapFile: "map.json")
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let entryNodeID = UUID(uuidString: "00000000-0000-0000-0000-000000000201")!
        let map = DungeonMap(
            nodes: [
                entryNodeID.uuidString: MapNode(
                    id: entryNodeID,
                    name: "Dead End",
                    soundProfile: "",
                    interactables: [],
                    connections: []
                )
            ],
            startingNodeID: entryNodeID
        )
        try writeJSON(map, to: fixture.scenarioURL.appendingPathComponent("map.json"))

        let report = ScenarioValidator().validateScenario(at: fixture.scenarioURL)
        XCTAssertTrue(
            report.warnings.contains(where: { $0.message.contains("possible soft-lock") }),
            report.formattedDescription
        )
    }

    func testScenarioValidatorWarnsOnNegativeLegacyGainStress() throws {
        let scenarioID = "validator_negative_gain_stress"
        let fixture = try makeValidatorFixtureRoot(scenarioID: scenarioID)
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let action = ActionOption(
            name: "Steady Yourself",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            outcomes: [.success: [.gainStress(-1)]]
        )
        let interactable = Interactable(
            id: "legacy_stress_recovery",
            title: "Legacy Stress Recovery",
            description: "",
            availableActions: [action]
        )
        try writeJSON([interactable], to: fixture.scenarioURL.appendingPathComponent("interactables.json"))

        let report = ScenarioValidator().validateScenario(at: fixture.scenarioURL)
        XCTAssertTrue(
            report.warnings.contains(where: { $0.message.contains("Negative gainStress is legacy content") }),
            report.formattedDescription
        )
    }

    func testScenarioValidatorRejectsAmbiguousInteractableSpawnForms() throws {
        let scenarioID = "validator_bad_spawn_forms"
        let fixture = try makeValidatorFixtureRoot(scenarioID: scenarioID, mapFile: "map.json")
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let nodeID = UUID(uuidString: "00000000-0000-0000-0000-000000000301")!
        var spawnConsequence = Consequence(kind: .addInteractable)
        spawnConsequence.inNodeID = nodeID
        spawnConsequence.interactableTemplateID = "spawn_template"
        spawnConsequence.newInteractable = Interactable(
            id: "inline_spawn",
            title: "Inline Spawn",
            description: "",
            availableActions: []
        )

        let action = ActionOption(
            name: "Trigger Spawn",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            outcomes: [.success: [spawnConsequence]]
        )
        let map = DungeonMap(
            nodes: [
                nodeID.uuidString: MapNode(
                    id: nodeID,
                    name: "Entry",
                    soundProfile: "",
                    interactables: [
                        Interactable(
                            id: "spawn_console",
                            title: "Spawn Console",
                            description: "",
                            availableActions: [action]
                        )
                    ],
                    connections: []
                )
            ],
            startingNodeID: nodeID
        )

        try writeJSON(map, to: fixture.scenarioURL.appendingPathComponent("map.json"))
        try writeJSON(
            [
                Interactable(
                    id: "spawn_template",
                    title: "Spawn Template",
                    description: "",
                    availableActions: []
                )
            ],
            to: fixture.scenarioURL.appendingPathComponent("interactables.json")
        )

        let report = ScenarioValidator().validateScenario(at: fixture.scenarioURL)
        XCTAssertTrue(
            report.errors.contains(where: { $0.message.contains("requires exactly one spawn form") }),
            report.formattedDescription
        )
    }

    func testStartNewRunUsesScenarioNativeArchetypes() throws {
        let loader = ContentLoader(scenario: "charons_bargain")
        let vm = GameViewModel()
        vm.startNewRun(scenario: "charons_bargain")

        let allowedIDs = Set(loader.scenarioManifest?.nativeArchetypeIDs ?? [])
        XCTAssertFalse(allowedIDs.isEmpty)
        XCTAssertEqual(vm.gameState.party.count, loader.scenarioManifest?.partySize ?? 3)
        XCTAssertTrue(vm.gameState.party.allSatisfy { character in
            guard let archetypeID = character.archetypeID else { return false }
            return allowedIDs.contains(archetypeID)
        })
    }

    func testPartyBuilderRespectsManualSelectionPlan() throws {
        let loader = ContentLoader(scenario: "charons_bargain")
        let builder = PartyBuilderService(content: loader)
        let plan = PartyBuildPlan(
            partySize: 3,
            nativeArchetypeIDs: loader.scenarioManifest?.nativeArchetypeIDs ?? [],
            selectedArchetypeIDs: ["pilot", "medic", "engineer"],
            mode: .manualSelection
        )

        let party = builder.buildParty(using: plan)

        XCTAssertEqual(party.count, 3)
        XCTAssertEqual(
            party.compactMap(\.archetypeID),
            ["pilot", "medic", "engineer"]
        )
    }

    func testRestartCurrentScenarioReusesLaunchPartyPlan() throws {
        let loader = ContentLoader(scenario: "charons_bargain")
        let vm = GameViewModel()
        let plan = PartyBuildPlan(
            partySize: 3,
            nativeArchetypeIDs: loader.scenarioManifest?.nativeArchetypeIDs ?? [],
            selectedArchetypeIDs: ["pilot", "medic", "engineer"],
            mode: .manualSelection
        )

        vm.startNewRun(scenario: "charons_bargain", partyPlan: plan)
        vm.restartCurrentScenario()

        XCTAssertEqual(vm.gameState.launchPartyPlan, plan)
        XCTAssertEqual(
            vm.gameState.party.compactMap(\.archetypeID),
            ["pilot", "medic", "engineer"]
        )
    }

    func testContentLoaderMergesGlobalAndScenarioHarmFamilies() throws {
        let loader = ContentLoader(scenario: "charons_bargain")

        XCTAssertNotNil(loader.harmFamilyDict["head_trauma"])
        XCTAssertNotNil(loader.harmFamilyDict["vfe_cerebral_euphoria"])
    }

    func testContentLoaderUsesScenarioLocalArchetypes() throws {
        let loader = ContentLoader(scenario: "test_lab")

        XCTAssertEqual(
            Set(loader.archetypeTemplates.map(\.id)),
            Set(["scientist", "engineer", "medic"])
        )
    }

    func testStressOverflowUsesScenarioConfiguredHarmFamily() throws {
        var runtime = ScenarioRuntime()
        _ = runtime.activateScenario(named: "charons_bargain")
        ContentLoader.shared = ContentLoader()
        var gameState = GameState(
            scenarioName: "charons_bargain",
            party: [
                Character(
                    id: UUID(),
                    name: "Test Subject",
                    characterClass: "Scientist",
                    stress: 10,
                    harm: HarmState(),
                    actions: ["Study": 1]
                )
            ]
        )

        let description = ConsequenceExecutor(debugLogging: false, runtime: runtime)
            .checkStressOverflow(for: 0, gameState: &gameState)

        XCTAssertEqual(gameState.party[0].stress, 0)
        XCTAssertEqual(gameState.party[0].harm.lesser.first?.familyId, "vfe_cerebral_euphoria")
        XCTAssertNotNil(description)
    }

    func testPushYourselfUsesRunContentAfterSharedLoaderChanges() throws {
        let vm = GameViewModel()
        vm.startNewRun(scenario: "charons_bargain")

        guard let character = vm.gameState.party.first else {
            return XCTFail("Expected a party member in the started run.")
        }

        vm.gameState.party[0].stress = 8
        ContentLoader.shared = ContentLoader()

        vm.pushYourself(forCharacter: character)

        XCTAssertEqual(vm.gameState.party[0].stress, 0)
        XCTAssertEqual(vm.gameState.party[0].harm.lesser.first?.familyId, "vfe_cerebral_euphoria")
    }

    func testDungeonGeneratorResolvesEntryNodeByName() throws {
        let dockingBayID = UUID()
        let corridorID = UUID()
        let map = DungeonMap(
            nodes: [
                dockingBayID.uuidString: MapNode(
                    id: dockingBayID,
                    name: "Docking Bay",
                    soundProfile: "",
                    interactables: [],
                    connections: []
                ),
                corridorID.uuidString: MapNode(
                    id: corridorID,
                    name: "Main Corridor",
                    soundProfile: "",
                    interactables: [],
                    connections: []
                )
            ],
            startingNodeID: corridorID
        )

        XCTAssertEqual(DungeonGenerator.resolveEntryNodeID("Docking Bay", in: map), dockingBayID)
    }

    func testSaveGameStoreRoundTripsGameState() throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let saveURL = tempDirectory.appendingPathComponent("savegame.json")
        let store = SaveGameStore(saveURL: saveURL)

        let partyMember = Character(
            id: UUID(),
            name: "Saver",
            characterClass: "Scholar",
            stress: 2,
            harm: HarmState(),
            actions: ["Study": 2]
        )
        let gameState = GameState(
            scenarioName: "charons_bargain",
            party: [partyMember],
            scenarioFlags: ["flag": true],
            scenarioCounters: ["counter": 3]
        )

        defer { try? store.delete() }

        try store.save(gameState)
        XCTAssertTrue(store.saveExists())

        let loaded = try store.load()
        XCTAssertEqual(loaded.scenarioName, "charons_bargain")
        XCTAssertEqual(loaded.party.count, 1)
        XCTAssertEqual(loaded.party[0].name, "Saver")
        XCTAssertEqual(loaded.scenarioFlags["flag"], true)
        XCTAssertEqual(loaded.scenarioCounters["counter"], 3)
    }

    func testCreateChoicePausesResolutionAndPersistsAcrossSaveLoad() throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let saveURL = tempDirectory.appendingPathComponent("savegame.json")
        let store = SaveGameStore(saveURL: saveURL)
        defer { try? store.delete() }

        let character = Character(
            id: UUID(),
            name: "Decider",
            characterClass: "Scholar",
            stress: 0,
            harm: HarmState(),
            actions: ["Study": 2]
        )
        let vm = GameViewModel(saveStore: store)
        vm.gameState.party = [character]

        let leftChoice = ChoiceOption(
            title: "Take the left idol",
            consequences: [.setScenarioFlag("took_left_idol")]
        )
        let rightChoice = ChoiceOption(
            title: "Pocket the silver key",
            consequences: [.incrementScenarioCounter("silver_keys", amount: 1)]
        )
        var choiceConsequence = Consequence.createChoice(options: [leftChoice, rightChoice])
        choiceConsequence.description = "Which prize do you claim?"

        let freeAction = ActionOption(
            name: "Search the dais",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            requiresTest: false,
            outcomes: [
                .success: [
                    .setScenarioFlag("dais_opened"),
                    choiceConsequence,
                    .incrementScenarioCounter("after_choice", amount: 1)
                ]
            ]
        )

        _ = vm.performFreeAction(for: freeAction, with: character, interactableID: nil)

        XCTAssertEqual(vm.gameState.scenarioFlags["dais_opened"], true)
        XCTAssertNil(vm.gameState.scenarioFlags["took_left_idol"])
        XCTAssertNil(vm.gameState.scenarioCounters["silver_keys"])
        XCTAssertNil(vm.gameState.scenarioCounters["after_choice"])
        XCTAssertEqual(vm.gameState.pendingResolution?.pendingChoice?.prompt, "Which prize do you claim?")

        let loadedVM = GameViewModel(saveStore: store)
        XCTAssertTrue(loadedVM.loadGame())
        XCTAssertEqual(loadedVM.gameState.pendingResolution?.pendingChoice?.options.count, 2)
        XCTAssertEqual(loadedVM.gameState.scenarioFlags["dais_opened"], true)

        _ = loadedVM.choosePendingChoice(at: 1)

        XCTAssertEqual(loadedVM.gameState.scenarioCounters["silver_keys"], 1)
        XCTAssertEqual(loadedVM.gameState.scenarioCounters["after_choice"], 1)
        XCTAssertNil(loadedVM.gameState.scenarioFlags["took_left_idol"])
        XCTAssertNil(loadedVM.gameState.pendingResolution?.pendingChoice)
        XCTAssertTrue(loadedVM.gameState.pendingResolution?.isComplete == true)
    }

    func testResistingStressConsequenceUsesResolveAndReducesAppliedStress() throws {
        let character = Character(
            id: UUID(),
            name: "Occultist",
            characterClass: "Whisper",
            stress: 0,
            harm: HarmState(),
            actions: ["Attune": 2]
        )
        let vm = GameViewModel()
        vm.gameState.party = [character]

        let action = ActionOption(
            name: "Touch the glyph",
            actionType: "Attune",
            position: .risky,
            effect: .standard,
            outcomes: [.success: [.gainStress(3)]]
        )

        let result = vm.performAction(for: action, with: character, interactableID: nil, usingDice: [6])

        XCTAssertTrue(result.isAwaitingDecision)
        XCTAssertEqual(vm.pendingResistanceAttribute(), .resolve)

        let resistance = vm.resistPendingConsequence(usingDice: [6])

        XCTAssertEqual(resistance?.highestRoll, 6)
        XCTAssertEqual(resistance?.stressCost, 0)
        XCTAssertEqual(vm.gameState.party[0].stress, 1)
        XCTAssertTrue(vm.gameState.pendingResolution?.isComplete == true)
        XCTAssertEqual(vm.gameState.pendingResolution?.resolvedText.contains("Resisted with Resolve"), true)
    }

    func testResistingClockTickReducesProgress() throws {
        let character = Character(
            id: UUID(),
            name: "Scout",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Study": 1]
        )
        let vm = GameViewModel()
        vm.gameState.party = [character]
        vm.gameState.activeClocks = [GameClock(name: "Alarm", segments: 4, progress: 1)]

        let action = ActionOption(
            name: "Probe the mechanism",
            actionType: "Study",
            position: .risky,
            effect: .standard,
            outcomes: [.success: [.tickClock(name: "Alarm", amount: 3)]]
        )

        _ = vm.performAction(for: action, with: character, interactableID: nil, usingDice: [6])
        XCTAssertEqual(vm.pendingResistanceAttribute(), .insight)

        _ = vm.resistPendingConsequence(usingDice: [6])

        XCTAssertEqual(vm.gameState.activeClocks.first?.progress, 2)
        XCTAssertTrue(vm.gameState.pendingResolution?.isComplete == true)
    }

    func testResistanceStressOverflowAppliesOverflowHarm() throws {
        let character = Character(
            id: UUID(),
            name: "Overloaded",
            characterClass: "Scholar",
            stress: 9,
            harm: HarmState(),
            actions: ["Study": 1]
        )
        let vm = makeViewModel()
        vm.gameState.party = [character]
        vm.gameState.activeClocks = [GameClock(name: "Alarm", segments: 4, progress: 0)]

        let action = ActionOption(
            name: "Read the omen",
            actionType: "Study",
            position: .risky,
            effect: .standard,
            outcomes: [.success: [.tickClock(name: "Alarm", amount: 2)]]
        )

        _ = vm.performAction(for: action, with: character, interactableID: nil, usingDice: [6])
        let resistance = vm.resistPendingConsequence(usingDice: [1])

        XCTAssertEqual(resistance?.stressCost, 5)
        XCTAssertEqual(vm.gameState.party[0].stress, 0)
        XCTAssertFalse(vm.gameState.party[0].harm.lesser.isEmpty)
        XCTAssertTrue(vm.gameState.pendingResolution?.resolvedText.contains("Stress Overload!") == true)
    }

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

    func testPressureInteractableCanResolveThreatWithoutCollapsingNode() throws {
        let vm = makeViewModel()
        let nodeID = UUID()
        let disableDrone = ActionOption(
            name: "Trigger Emergency Shutdown",
            actionType: "Tinker",
            position: .risky,
            effect: .standard,
            requiresTest: false,
            outcomes: [.success: [.removeInteractable(id: "cb_corrupted_maintenance_droid")]]
        )
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
            availableActions: [disableDrone],
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
        vm.gameState.dungeon = DungeonMap(
            nodes: [
                nodeID.uuidString: MapNode(
                    id: nodeID,
                    name: "Engineering",
                    soundProfile: "",
                    interactables: [threat, console, stash],
                    connections: []
                )
            ],
            startingNodeID: nodeID
        )
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = nodeID

        XCTAssertTrue(vm.isCharacterEngaged(character.id))
        XCTAssertEqual(
            vm.visibleInteractables(for: character.id).map(\.id),
            ["cb_corrupted_maintenance_droid", "engineering_override_console"]
        )

        _ = vm.performFreeAction(
            for: disableDrone,
            with: character,
            interactableID: "engineering_override_console"
        )

        XCTAssertFalse(vm.isCharacterEngaged(character.id))
        XCTAssertEqual(
            vm.visibleInteractables(for: character.id).map(\.id),
            ["engineering_override_console", "hidden_supplies"]
        )
    }

    func testGuidanceStorePersistsDismissedHints() throws {
        let suiteName = "GuidanceStoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            return XCTFail("Expected isolated UserDefaults suite.")
        }
        defaults.removePersistentDomain(forName: suiteName)

        let firstStore = GuidanceStore(userDefaults: defaults, resetOnLaunch: false)
        XCTAssertTrue(firstStore.shouldShow(.rollForecast))

        firstStore.dismiss(.rollForecast)
        XCTAssertFalse(firstStore.shouldShow(.rollForecast))

        let secondStore = GuidanceStore(userDefaults: defaults, resetOnLaunch: false)
        XCTAssertFalse(secondStore.shouldShow(.rollForecast))

        defaults.removePersistentDomain(forName: suiteName)
    }

    func testGuidanceStoreDebugResetClearsDismissedHints() throws {
        let suiteName = "GuidanceStoreResetTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            return XCTFail("Expected isolated UserDefaults suite.")
        }
        defaults.removePersistentDomain(forName: suiteName)

        let store = GuidanceStore(userDefaults: defaults, resetOnLaunch: false)
        store.dismiss(.activeClocks)
        XCTAssertFalse(store.shouldShow(.activeClocks))

        store.debugResetHints()
        XCTAssertTrue(store.shouldShow(.activeClocks))

        let reloadedStore = GuidanceStore(userDefaults: defaults, resetOnLaunch: false)
        XCTAssertTrue(reloadedStore.shouldShow(.activeClocks))

        defaults.removePersistentDomain(forName: suiteName)
    }

    private func makeValidatorFixtureRoot(
        scenarioID: String,
        mapFile: String? = nil,
        entryNode: String? = nil
    ) throws -> (rootURL: URL, scenarioURL: URL) {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let scenariosURL = rootURL.appendingPathComponent("Scenarios", isDirectory: true)
        let scenarioURL = scenariosURL.appendingPathComponent(scenarioID, isDirectory: true)

        try FileManager.default.createDirectory(at: scenarioURL, withIntermediateDirectories: true)

        let globalHarmFamily = HarmFamily(
            id: "test_harm",
            lesser: HarmTier(description: "Minor strain"),
            moderate: HarmTier(description: "Moderate strain"),
            severe: HarmTier(description: "Severe strain"),
            fatal: HarmTier(description: "Fatal strain")
        )
        try writeJSON([globalHarmFamily], to: rootURL.appendingPathComponent("harm_families.json"))

        let manifest = ScenarioManifest(
            id: scenarioID,
            title: "Validator Fixture",
            description: "Generated by unit tests.",
            entryNode: entryNode,
            mapFile: mapFile,
            partySize: 1,
            nativeArchetypeIDs: ["tester"],
            stressOverflowHarmFamilyID: "test_harm"
        )
        try writeJSON(manifest, to: scenarioURL.appendingPathComponent("scenario.json"))

        let archetype = ArchetypeDefinition(
            id: "tester",
            name: "Tester",
            description: "Validation test archetype.",
            defaultActions: ["Study": 1]
        )
        try writeJSON([archetype], to: scenarioURL.appendingPathComponent("archetypes.json"))

        return (rootURL, scenarioURL)
    }

    private func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }

}
