import XCTest
@testable import CardGame

final class PendingResolutionDriverTests: XCTestCase {
    func testCreateChoicePausesResolutionAndPersistsAcrossSaveLoad() throws {
        let tempSave = TestFixtures.makeTemporarySaveStore()
        defer { try? FileManager.default.removeItem(at: tempSave.directory) }

        let character = Character(
            id: UUID(),
            name: "Decider",
            characterClass: "Scholar",
            stress: 0,
            harm: HarmState(),
            actions: ["Study": 2]
        )
        let viewModel = GameViewModel(saveStore: tempSave.store)
        viewModel.gameState.party = [character]

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

        _ = viewModel.performFreeAction(for: freeAction, with: character, interactableID: nil)

        XCTAssertEqual(viewModel.gameState.scenarioFlags["dais_opened"], true)
        XCTAssertNil(viewModel.gameState.scenarioFlags["took_left_idol"])
        XCTAssertNil(viewModel.gameState.scenarioCounters["silver_keys"])
        XCTAssertNil(viewModel.gameState.scenarioCounters["after_choice"])
        XCTAssertEqual(viewModel.gameState.pendingResolution?.pendingChoice?.prompt, "Which prize do you claim?")

        let loadedViewModel = GameViewModel(saveStore: tempSave.store)
        XCTAssertTrue(loadedViewModel.loadGame())
        XCTAssertEqual(loadedViewModel.gameState.pendingResolution?.pendingChoice?.options.count, 2)
        XCTAssertEqual(loadedViewModel.gameState.scenarioFlags["dais_opened"], true)

        _ = loadedViewModel.choosePendingChoice(at: 1)

        XCTAssertEqual(loadedViewModel.gameState.scenarioCounters["silver_keys"], 1)
        XCTAssertEqual(loadedViewModel.gameState.scenarioCounters["after_choice"], 1)
        XCTAssertNil(loadedViewModel.gameState.scenarioFlags["took_left_idol"])
        XCTAssertNil(loadedViewModel.gameState.pendingResolution?.pendingChoice)
        XCTAssertTrue(loadedViewModel.gameState.pendingResolution?.isComplete == true)
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
        let viewModel = GameViewModel()
        viewModel.gameState.party = [character]

        let action = ActionOption(
            name: "Touch the glyph",
            actionType: "Attune",
            position: .risky,
            effect: .standard,
            outcomes: [.success: [.gainStress(3)]]
        )

        let result = viewModel.performAction(for: action, with: character, interactableID: nil, usingDice: [6])

        XCTAssertTrue(result.isAwaitingDecision)
        XCTAssertEqual(viewModel.pendingResistanceAttribute(), .resolve)

        let resistance = viewModel.resistPendingConsequence(usingDice: [6])

        XCTAssertEqual(resistance?.highestRoll, 6)
        XCTAssertEqual(resistance?.stressCost, 0)
        XCTAssertEqual(viewModel.gameState.party[0].stress, 1)
        XCTAssertTrue(viewModel.gameState.pendingResolution?.isComplete == true)
        XCTAssertEqual(viewModel.gameState.pendingResolution?.resolvedText.contains("Resisted with Resolve"), true)
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
        let viewModel = GameViewModel()
        viewModel.gameState.party = [character]
        viewModel.gameState.activeClocks = [GameClock(name: "Alarm", segments: 4, progress: 1)]

        let action = ActionOption(
            name: "Probe the mechanism",
            actionType: "Study",
            position: .risky,
            effect: .standard,
            outcomes: [.success: [.tickClock(name: "Alarm", amount: 3)]]
        )

        _ = viewModel.performAction(for: action, with: character, interactableID: nil, usingDice: [6])
        XCTAssertEqual(viewModel.pendingResistanceAttribute(), .insight)

        _ = viewModel.resistPendingConsequence(usingDice: [6])

        XCTAssertEqual(viewModel.gameState.activeClocks.first?.progress, 2)
        XCTAssertTrue(viewModel.gameState.pendingResolution?.isComplete == true)
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
        let viewModel = TestFixtures.makeViewModel()
        viewModel.gameState.party = [character]
        viewModel.gameState.activeClocks = [GameClock(name: "Alarm", segments: 4, progress: 0)]

        let action = ActionOption(
            name: "Read the omen",
            actionType: "Study",
            position: .risky,
            effect: .standard,
            outcomes: [.success: [.tickClock(name: "Alarm", amount: 2)]]
        )

        _ = viewModel.performAction(for: action, with: character, interactableID: nil, usingDice: [6])
        let resistance = viewModel.resistPendingConsequence(usingDice: [1])

        XCTAssertEqual(resistance?.stressCost, 5)
        XCTAssertEqual(viewModel.gameState.party[0].stress, 0)
        XCTAssertFalse(viewModel.gameState.party[0].harm.lesser.isEmpty)
        XCTAssertTrue(viewModel.gameState.pendingResolution?.resolvedText.contains("Stress Overload!") == true)
    }

    func testPendingResistanceIncludesConcreteFallbackSummary() throws {
        let character = Character(
            id: UUID(),
            name: "Occultist",
            characterClass: "Whisper",
            stress: 0,
            harm: HarmState(),
            actions: ["Attune": 2]
        )
        let viewModel = GameViewModel()
        viewModel.gameState.party = [character]

        let action = ActionOption(
            name: "Read the warning",
            actionType: "Attune",
            position: .risky,
            effect: .standard,
            outcomes: [.success: [.gainStress(3)]]
        )

        _ = viewModel.performAction(for: action, with: character, interactableID: nil, usingDice: [6])

        let resistance = viewModel.gameState.pendingResolution?.pendingResistance
        XCTAssertEqual(resistance?.title, "+3 Stress")
        XCTAssertEqual(resistance?.summary, "You would take 3 Stress.")
        XCTAssertEqual(resistance?.resistPreview, "Resist: reduce to +1 Stress.")
    }

    func testPendingResistanceQueuePreviewShowsUpcomingFallout() throws {
        let character = Character(
            id: UUID(),
            name: "Scout",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Study": 1]
        )
        let viewModel = GameViewModel()
        viewModel.gameState.party = [character]
        viewModel.gameState.activeClocks = [GameClock(name: "Alarm", segments: 6, progress: 0)]

        let action = ActionOption(
            name: "Probe the seal",
            actionType: "Study",
            position: .risky,
            effect: .standard,
            outcomes: [
                .success: [
                    .gainStress(1),
                    .tickClock(name: "Alarm", amount: 2)
                ]
            ]
        )

        _ = viewModel.performAction(for: action, with: character, interactableID: nil, usingDice: [6])

        let previews = viewModel.pendingResistanceQueuePreview()
        XCTAssertEqual(previews.count, 1)
        XCTAssertEqual(previews.first?.title, "Alarm +2")
        XCTAssertEqual(previews.first?.summary, "Alarm advances by 2.")
    }

    func testPendingResistanceTracksQueueProgressAcrossMultipleFalloutCards() throws {
        let character = Character(
            id: UUID(),
            name: "Scout",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Study": 1]
        )
        let viewModel = GameViewModel()
        viewModel.gameState.party = [character]
        viewModel.gameState.activeClocks = [GameClock(name: "Alarm", segments: 6, progress: 0)]

        let action = ActionOption(
            name: "Probe the seal",
            actionType: "Study",
            position: .risky,
            effect: .standard,
            outcomes: [
                .success: [
                    .gainStress(1),
                    .tickClock(name: "Alarm", amount: 2)
                ]
            ]
        )

        _ = viewModel.performAction(for: action, with: character, interactableID: nil, usingDice: [6])

        XCTAssertEqual(viewModel.gameState.pendingResolution?.pendingResistance?.sequenceIndex, 1)
        XCTAssertEqual(viewModel.gameState.pendingResolution?.pendingResistance?.sequenceTotal, 2)

        _ = viewModel.acceptPendingResistance()

        XCTAssertEqual(viewModel.gameState.pendingResolution?.pendingResistance?.sequenceIndex, 2)
        XCTAssertEqual(viewModel.gameState.pendingResolution?.pendingResistance?.sequenceTotal, 2)
    }
}
