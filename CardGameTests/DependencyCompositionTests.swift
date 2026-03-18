import XCTest
@testable import CardGame

final class DependencyCompositionTests: XCTestCase {
    func testRestartCurrentScenarioKeepsScenarioSelection() throws {
        let viewModel = GameViewModel()
        viewModel.startNewRun(scenario: "charons_bargain")
        viewModel.restartCurrentScenario()

        XCTAssertEqual(viewModel.gameState.scenarioName, "charons_bargain")
        XCTAssertEqual(
            viewModel.gameState.dungeon?.startingNodeID.uuidString.lowercased(),
            "00000000-0000-0000-0000-000000000001"
        )
    }

    func testStartNewRunUsesScenarioNativeArchetypes() throws {
        let loader = ContentLoader(scenario: "charons_bargain")
        let viewModel = GameViewModel()
        viewModel.startNewRun(scenario: "charons_bargain")

        let allowedIDs = Set(loader.scenarioManifest?.nativeArchetypeIDs ?? [])
        XCTAssertFalse(allowedIDs.isEmpty)
        XCTAssertEqual(viewModel.gameState.party.count, loader.scenarioManifest?.partySize ?? 3)
        XCTAssertTrue(viewModel.gameState.party.allSatisfy { character in
            guard let archetypeID = character.archetypeID else { return false }
            return allowedIDs.contains(archetypeID)
        })
    }

    func testRestartCurrentScenarioReusesLaunchPartyPlan() throws {
        let loader = ContentLoader(scenario: "charons_bargain")
        let viewModel = GameViewModel()
        let plan = PartyBuildPlan(
            partySize: 3,
            nativeArchetypeIDs: loader.scenarioManifest?.nativeArchetypeIDs ?? [],
            selectedArchetypeIDs: ["pilot", "medic", "engineer"],
            mode: .manualSelection
        )

        viewModel.startNewRun(scenario: "charons_bargain", partyPlan: plan)
        viewModel.restartCurrentScenario()

        XCTAssertEqual(viewModel.gameState.launchPartyPlan, plan)
        XCTAssertEqual(
            viewModel.gameState.party.compactMap(\.archetypeID),
            ["pilot", "medic", "engineer"]
        )
    }

    func testAuthoredEventUsesRunScopedContent() throws {
        let viewModel = GameViewModel()
        viewModel.startNewRun(scenario: "charons_bargain")

        guard let character = viewModel.gameState.party.first else {
            XCTFail("Expected a party member in the started run.")
            return
        }

        let action = ActionOption(
            name: "Trigger Full Info",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            requiresTest: false,
            outcomes: [.success: [.triggerEvent(id: "cb_ng_reveals_lab_location")]]
        )

        _ = viewModel.performFreeAction(for: action, with: character, interactableID: nil)

        XCTAssertEqual(viewModel.gameState.scenarioFlags["cb_lab_location_known"], true)
    }

    func testStressOverflowUsesScenarioConfiguredHarmFamily() throws {
        var runtime = TestFixtures.makeRuntime(scenario: "charons_bargain")
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

    func testPushYourselfUsesRunScopedContent() throws {
        let viewModel = GameViewModel()
        viewModel.startNewRun(scenario: "charons_bargain")

        guard let character = viewModel.gameState.party.first else {
            XCTFail("Expected a party member in the started run.")
            return
        }

        viewModel.gameState.party[0].stress = 8
        viewModel.pushYourself(forCharacter: character)

        XCTAssertEqual(viewModel.gameState.party[0].stress, 0)
        XCTAssertEqual(viewModel.gameState.party[0].harm.lesser.first?.familyId, "vfe_cerebral_euphoria")
    }
}
