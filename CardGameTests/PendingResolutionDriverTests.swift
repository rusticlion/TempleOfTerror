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

    func testCreateChoiceFiltersUnavailableOptionsAndPersistsOptionMetadata() throws {
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

        let openOption = ChoiceOption(
            title: "Force the lock",
            description: "Crack it now and accept the risk.",
            costLabel: "+1 Stress",
            consequences: [.setScenarioFlag("forced_lock")]
        )
        let gatedOption = ChoiceOption(
            title: "Use the sigil key",
            description: "Requires the matching sigil.",
            conditions: [GameCondition(type: .characterHasTag, stringParam: "sigil_key")],
            costLabel: "Sigil Key",
            consequences: [.setScenarioFlag("sigil_lock")]
        )
        var choiceConsequence = Consequence.createChoice(options: [openOption, gatedOption])
        choiceConsequence.description = "How do you open the vault?"

        let freeAction = ActionOption(
            name: "Open the vault",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            requiresTest: false,
            outcomes: [.success: [choiceConsequence]]
        )

        _ = viewModel.performFreeAction(for: freeAction, with: character, interactableID: nil)

        let loadedViewModel = GameViewModel(saveStore: tempSave.store)
        XCTAssertTrue(loadedViewModel.loadGame())

        let pendingChoice = try XCTUnwrap(loadedViewModel.gameState.pendingResolution?.pendingChoice)
        XCTAssertEqual(pendingChoice.options.count, 1)
        XCTAssertEqual(pendingChoice.options.first?.title, "Force the lock")
        XCTAssertEqual(pendingChoice.options.first?.description, "Crack it now and accept the risk.")
        XCTAssertEqual(pendingChoice.options.first?.costLabel, "+1 Stress")

        _ = loadedViewModel.choosePendingChoice(at: 0)

        XCTAssertEqual(loadedViewModel.gameState.scenarioFlags["forced_lock"], true)
        XCTAssertNil(loadedViewModel.gameState.scenarioFlags["sigil_lock"])
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

    func testCriticalOutcomeBucketAppliesAdditionalConsequences() throws {
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
            name: "Invoke the relay",
            actionType: "Attune",
            position: .risky,
            effect: .standard,
            outcomes: [
                .success: [.setScenarioFlag("relay_awakened")],
                .critical: [.incrementScenarioCounter("crit_echoes", amount: 1)]
            ]
        )

        let result = viewModel.performAction(for: action, with: character, interactableID: nil, usingDice: [6, 6])

        XCTAssertEqual(result.outcome, "Full Success!")
        XCTAssertEqual(result.isCritical, true)
        XCTAssertEqual(result.finalEffect, .great)
        XCTAssertEqual(viewModel.gameState.scenarioFlags["relay_awakened"], true)
        XCTAssertEqual(viewModel.gameState.scenarioCounters["crit_echoes"], 1)
        XCTAssertTrue(result.consequences.contains("Critical Success!"))
    }

    func testExplicitResistanceCanPreventForcedMovement() throws {
        let startNodeID = UUID()
        let vaultNodeID = UUID()
        let character = Character(
            id: UUID(),
            name: "Runner",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Prowl": 2, "Wreck": 1]
        )
        let viewModel = GameViewModel()
        viewModel.gameState.party = [character]
        viewModel.gameState.dungeon = DungeonMap(
            nodes: [
                startNodeID.uuidString: MapNode(
                    id: startNodeID,
                    name: "Threshold",
                    soundProfile: "",
                    interactables: [],
                    connections: []
                ),
                vaultNodeID.uuidString: MapNode(
                    id: vaultNodeID,
                    name: "Vault",
                    soundProfile: "",
                    interactables: [],
                    connections: []
                )
            ],
            startingNodeID: startNodeID
        )
        viewModel.gameState.currentNodeID = startNodeID
        viewModel.gameState.characterLocations = [character.id.uuidString: startNodeID]

        var forcedMove = Consequence.moveActingCharacterToNode(vaultNodeID)
        forcedMove.resistance = ResistanceRule(attribute: .prowess, amount: 1)

        let action = ActionOption(
            name: "Trigger the snare",
            actionType: "Prowl",
            position: .risky,
            effect: .standard,
            outcomes: [.success: [forcedMove]]
        )

        _ = viewModel.performAction(for: action, with: character, interactableID: nil, usingDice: [6])

        let pendingResistance = try XCTUnwrap(viewModel.gameState.pendingResolution?.pendingResistance)
        XCTAssertEqual(pendingResistance.title, "Forced Move")
        XCTAssertEqual(pendingResistance.summary, "You would be forced to Vault.")
        XCTAssertEqual(pendingResistance.resistPreview, "Resist: hold your ground.")

        _ = viewModel.resistPendingConsequence(usingDice: [6])

        XCTAssertEqual(viewModel.gameState.characterLocations[character.id.uuidString], startNodeID)
        XCTAssertTrue(viewModel.gameState.pendingResolution?.isComplete == true)
    }

    func testExplicitResistanceReducesScenarioCounterIncrease() throws {
        let character = Character(
            id: UUID(),
            name: "Analyst",
            characterClass: "Scholar",
            stress: 0,
            harm: HarmState(),
            actions: ["Study": 2]
        )
        let viewModel = GameViewModel()
        viewModel.gameState.party = [character]

        var escalation = Consequence.incrementScenarioCounter("alarm_level", amount: 3)
        escalation.resistance = ResistanceRule(attribute: .insight, amount: 1)

        let action = ActionOption(
            name: "Disturb the ward",
            actionType: "Study",
            position: .risky,
            effect: .standard,
            outcomes: [.success: [escalation]]
        )

        _ = viewModel.performAction(for: action, with: character, interactableID: nil, usingDice: [6])

        let pendingResistance = try XCTUnwrap(viewModel.gameState.pendingResolution?.pendingResistance)
        XCTAssertEqual(pendingResistance.title, "Alarm Level +3")
        XCTAssertEqual(pendingResistance.resistPreview, "Resist: reduce to Alarm Level +2.")

        _ = viewModel.resistPendingConsequence(usingDice: [6])

        XCTAssertEqual(viewModel.gameState.scenarioCounters["alarm_level"], 2)
        XCTAssertTrue(viewModel.gameState.pendingResolution?.isComplete == true)
    }

    func testScopedConsequencesApplyToTargetedPartyMembers() throws {
        let sharedNodeID = UUID()
        let remoteNodeID = UUID()
        let leader = Character(
            id: UUID(),
            name: "Leader",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Study": 1]
        )
        let partner = Character(
            id: UUID(),
            name: "Partner",
            characterClass: "Engineer",
            stress: 0,
            harm: HarmState(),
            actions: ["Tinker": 1]
        )
        let remote = Character(
            id: UUID(),
            name: "Remote",
            characterClass: "Mystic",
            stress: 0,
            harm: HarmState(),
            actions: ["Attune": 1]
        )

        let viewModel = GameViewModel()
        viewModel.gameState.party = [leader, partner, remote]
        viewModel.gameState.characterLocations = [
            leader.id.uuidString: sharedNodeID,
            partner.id.uuidString: sharedNodeID,
            remote.id.uuidString: remoteNodeID
        ]

        var stressAllHere = Consequence.gainStress(2)
        stressAllHere.targetScope = .allHere

        var tagOthersHere = Consequence.addCharacterTag("shielded")
        tagOthersHere.targetScope = .othersHere

        var diceAllParty = Consequence.modifyDice(amount: 1, duration: "next roll")
        diceAllParty.targetScope = .allParty

        let action = ActionOption(
            name: "Trigger Wards",
            actionType: "Study",
            position: .risky,
            effect: .standard,
            requiresTest: false,
            outcomes: [
                .success: [
                    stressAllHere,
                    tagOthersHere,
                    diceAllParty
                ]
            ]
        )

        _ = viewModel.performFreeAction(for: action, with: leader, interactableID: nil)

        XCTAssertEqual(
            viewModel.gameState.pendingResolution?.pendingResistance?.summary,
            "Everyone here would take 2 Stress."
        )

        _ = viewModel.acceptPendingResistance()

        XCTAssertEqual(viewModel.gameState.party[0].stress, 2)
        XCTAssertEqual(viewModel.gameState.party[1].stress, 2)
        XCTAssertEqual(viewModel.gameState.party[2].stress, 0)
        XCTAssertFalse(viewModel.gameState.party[0].stateTags.contains("shielded"))
        XCTAssertTrue(viewModel.gameState.party[1].stateTags.contains("shielded"))
        XCTAssertFalse(viewModel.gameState.party[2].stateTags.contains("shielded"))
        XCTAssertEqual(viewModel.gameState.party[0].modifiers.count, 1)
        XCTAssertEqual(viewModel.gameState.party[1].modifiers.count, 1)
        XCTAssertEqual(viewModel.gameState.party[2].modifiers.count, 1)
        XCTAssertTrue(viewModel.gameState.pendingResolution?.isComplete == true)
    }

    func testGrantModifierReplaceAndRemoveHonorSourceKeyAndScope() throws {
        let sharedNodeID = UUID()
        let leader = Character(
            id: UUID(),
            name: "Leader",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Study": 1]
        )
        let partner = Character(
            id: UUID(),
            name: "Partner",
            characterClass: "Engineer",
            stress: 0,
            harm: HarmState(),
            actions: ["Tinker": 1]
        )

        let viewModel = GameViewModel()
        viewModel.gameState.party = [leader, partner]
        viewModel.gameState.characterLocations = [
            leader.id.uuidString: sharedNodeID,
            partner.id.uuidString: sharedNodeID
        ]

        var grantAllHere = Consequence.grantModifier(
            Modifier(
                sourceKey: "ward",
                bonusDice: 1,
                uses: 1,
                isOptionalToApply: false,
                description: "Protective Ward"
            )
        )
        grantAllHere.targetScope = .allHere

        let firstAction = ActionOption(
            name: "Raise the Ward",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            requiresTest: false,
            outcomes: [.success: [grantAllHere]]
        )

        _ = viewModel.performFreeAction(for: firstAction, with: leader, interactableID: nil)

        XCTAssertEqual(viewModel.gameState.party[0].modifiers.count, 1)
        XCTAssertEqual(viewModel.gameState.party[1].modifiers.count, 1)
        XCTAssertEqual(viewModel.gameState.party[1].modifiers.first?.sourceKey, "ward")
        XCTAssertEqual(viewModel.gameState.party[1].modifiers.first?.bonusDice, 1)

        var replaceOthersHere = Consequence.grantModifier(
            Modifier(
                sourceKey: "ward",
                improveEffect: true,
                uses: 1,
                isOptionalToApply: false,
                description: "Sharper Ward"
            )
        )
        replaceOthersHere.targetScope = .othersHere

        let replaceAction = ActionOption(
            name: "Refocus the Ward",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            requiresTest: false,
            outcomes: [.success: [replaceOthersHere]]
        )

        _ = viewModel.performFreeAction(for: replaceAction, with: leader, interactableID: nil)

        XCTAssertEqual(viewModel.gameState.party[0].modifiers.first?.bonusDice, 1)
        XCTAssertTrue(viewModel.gameState.party[1].modifiers.first?.improveEffect == true)
        XCTAssertEqual(viewModel.gameState.party[1].modifiers.count, 1)

        var removeOthersHere = Consequence.removeModifier(sourceKey: "ward")
        removeOthersHere.targetScope = .othersHere

        let removeAction = ActionOption(
            name: "Dismiss the Ward",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            requiresTest: false,
            outcomes: [.success: [removeOthersHere]]
        )

        _ = viewModel.performFreeAction(for: removeAction, with: leader, interactableID: nil)

        XCTAssertEqual(viewModel.gameState.party[0].modifiers.count, 1)
        XCTAssertTrue(viewModel.gameState.party[1].modifiers.isEmpty)
    }

    func testForcedScopedMovementTriggersAnchoredDestinationHooks() throws {
        let startNodeID = UUID()
        let vaultNodeID = UUID()
        let remoteNodeID = UUID()
        let leader = Character(
            id: UUID(),
            name: "Leader",
            characterClass: "Scout",
            stress: 0,
            harm: HarmState(),
            actions: ["Study": 1]
        )
        let partner = Character(
            id: UUID(),
            name: "Partner",
            characterClass: "Engineer",
            stress: 0,
            harm: HarmState(),
            actions: ["Tinker": 1]
        )
        let remote = Character(
            id: UUID(),
            name: "Remote",
            characterClass: "Mystic",
            stress: 0,
            harm: HarmState(),
            actions: ["Attune": 1]
        )

        var markArrivals = Consequence.addCharacterTag("vault_mark")
        markArrivals.targetScope = .allHere

        let viewModel = GameViewModel()
        viewModel.gameState.party = [leader, partner, remote]
        viewModel.gameState.dungeon = DungeonMap(
            nodes: [
                startNodeID.uuidString: MapNode(
                    id: startNodeID,
                    name: "Entry",
                    soundProfile: "",
                    interactables: [],
                    connections: []
                ),
                vaultNodeID.uuidString: MapNode(
                    id: vaultNodeID,
                    name: "Vault",
                    soundProfile: "",
                    interactables: [],
                    connections: [],
                    onEnter: [markArrivals],
                    onFirstEnter: [.setScenarioFlag("vault_first_entered")]
                ),
                remoteNodeID.uuidString: MapNode(
                    id: remoteNodeID,
                    name: "Remote",
                    soundProfile: "",
                    interactables: [],
                    connections: []
                )
            ],
            startingNodeID: startNodeID
        )
        viewModel.gameState.currentNodeID = startNodeID
        viewModel.gameState.characterLocations = [
            leader.id.uuidString: startNodeID,
            partner.id.uuidString: startNodeID,
            remote.id.uuidString: remoteNodeID
        ]

        var moveOthersHere = Consequence.moveActingCharacterToNode(vaultNodeID)
        moveOthersHere.targetScope = .othersHere

        let action = ActionOption(
            name: "Trigger the Lift",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            requiresTest: false,
            outcomes: [.success: [moveOthersHere]]
        )

        _ = viewModel.performFreeAction(for: action, with: leader, interactableID: nil)

        XCTAssertEqual(viewModel.gameState.characterLocations[leader.id.uuidString], startNodeID)
        XCTAssertEqual(viewModel.gameState.characterLocations[partner.id.uuidString], vaultNodeID)
        XCTAssertEqual(viewModel.gameState.characterLocations[remote.id.uuidString], remoteNodeID)
        XCTAssertFalse(viewModel.gameState.party[0].stateTags.contains("vault_mark"))
        XCTAssertTrue(viewModel.gameState.party[1].stateTags.contains("vault_mark"))
        XCTAssertFalse(viewModel.gameState.party[2].stateTags.contains("vault_mark"))
        XCTAssertEqual(viewModel.gameState.currentNodeID, startNodeID)
        XCTAssertEqual(viewModel.gameState.scenarioFlags["vault_first_entered"], true)
    }
}
