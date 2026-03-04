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

        var character = Character(id: UUID(),
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
                                       outcomes: [.success: [removeCon]])

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

        var character = Character(id: UUID(),
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
                                 outcomes: [.success: [addCon]])

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

        var character = Character(id: UUID(),
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
        ContentLoader.shared = ContentLoader()
        let vm = GameViewModel()
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

        var character = Character(id: UUID(),
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

    func testRestartCurrentScenarioKeepsScenarioSelection() throws {
        ContentLoader.shared = ContentLoader(scenario: "charons_bargain")
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
            ContentLoader.shared = ContentLoader(scenario: "charons_bargain")
            let vm = GameViewModel()
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
        ContentLoader.shared = ContentLoader(scenario: "charons_bargain")
        let vm = GameViewModel()
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

        let partialInfo = ActionOption(name: "Trigger Partial Info",
                                       actionType: "Study",
                                       position: .controlled,
                                       effect: .standard,
                                       requiresTest: false,
                                       outcomes: [.success: [.triggerEvent(id: "cb_ng_partial_lab_info")]])
        let fullInfo = ActionOption(name: "Trigger Full Info",
                                    actionType: "Study",
                                    position: .controlled,
                                    effect: .standard,
                                    requiresTest: false,
                                    outcomes: [.success: [.triggerEvent(id: "cb_ng_reveals_lab_location")]])

        _ = vm.performFreeAction(for: partialInfo, with: character, interactableID: nil)
        _ = vm.performFreeAction(for: fullInfo, with: character, interactableID: nil)

        XCTAssertEqual(vm.gameState.scenarioCounters["cb_ng_partial_lab_clues"], 1)
        XCTAssertEqual(vm.gameState.scenarioFlags["cb_lab_location_known"], true)
    }

    func testAuthoredEventCanRelocateThreatAcrossNodes() throws {
        ContentLoader.shared = ContentLoader(scenario: "charons_bargain")
        let vm = GameViewModel()

        let engineeringID = UUID(uuidString: "00000000-0000-0000-0000-000000000009")!
        let corridorID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let quartersID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
        let podsID = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!

        let placeholderDroid = Interactable(id: "cb_corrupted_maintenance_droid",
                                            title: "Corrupted Maintenance Droid",
                                            description: "",
                                            availableActions: [])
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

        let evade = ActionOption(name: "Evade",
                                 actionType: "Finesse",
                                 position: .controlled,
                                 effect: .standard,
                                 requiresTest: false,
                                 outcomes: [.success: [.triggerEvent(id: "cb_droid_evaded_moves_node")]])

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

    func testPackagedScenariosHaveNoValidationErrors() throws {
        let reports = ScenarioValidator().validateAllScenarios(at: Self.scenariosRootURL)
        XCTAssertFalse(reports.isEmpty, "Expected at least one packaged scenario to validate.")

        let failingReports = reports.filter { !$0.errors.isEmpty }
        XCTAssertTrue(
            failingReports.isEmpty,
            failingReports.map(\.formattedDescription).joined(separator: "\n\n")
        )
    }

    func testStartNewRunUsesScenarioNativeArchetypes() throws {
        ContentLoader.shared = ContentLoader(scenario: "charons_bargain")
        let vm = GameViewModel()
        vm.startNewRun(scenario: "charons_bargain")

        let allowedIDs = Set(ContentLoader.shared.scenarioManifest?.nativeArchetypeIDs ?? [])
        XCTAssertFalse(allowedIDs.isEmpty)
        XCTAssertEqual(vm.gameState.party.count, ContentLoader.shared.scenarioManifest?.partySize ?? 3)
        XCTAssertTrue(vm.gameState.party.allSatisfy { character in
            guard let archetypeID = character.archetypeID else { return false }
            return allowedIDs.contains(archetypeID)
        })
    }

    func testPartyBuilderRespectsManualSelectionPlan() throws {
        ContentLoader.shared = ContentLoader(scenario: "charons_bargain")
        let builder = PartyBuilderService(content: ContentLoader.shared)
        let plan = PartyBuildPlan(
            partySize: 3,
            nativeArchetypeIDs: ContentLoader.shared.scenarioManifest?.nativeArchetypeIDs ?? [],
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
        ContentLoader.shared = ContentLoader(scenario: "charons_bargain")
        let vm = GameViewModel()
        let plan = PartyBuildPlan(
            partySize: 3,
            nativeArchetypeIDs: ContentLoader.shared.scenarioManifest?.nativeArchetypeIDs ?? [],
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
        ContentLoader.shared = ContentLoader(scenario: "charons_bargain")
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

        let description = ConsequenceExecutor(debugLogging: false)
            .checkStressOverflow(for: 0, gameState: &gameState)

        XCTAssertEqual(gameState.party[0].stress, 0)
        XCTAssertEqual(gameState.party[0].harm.lesser.first?.familyId, "vfe_cerebral_euphoria")
        XCTAssertNotNil(description)
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

}
