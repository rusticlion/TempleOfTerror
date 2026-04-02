import XCTest
@testable import CardGame

final class ModifierSystemTests: XCTestCase {
    func makeTestCharacter() -> Character {
        Character(id: UUID(),
                  name: "Tester",
                  characterClass: "Rogue",
                  stress: 0,
                  harm: HarmState(),
                  actions: ["Skirmish": 2],
                  treasures: [],
                  modifiers: [])
    }

    func makeTestAction() -> ActionOption {
        ActionOption(name: "Strike",
                     actionType: "Skirmish",
                     position: .risky,
                     effect: .standard)
    }

    func testRollContextIncludesOptionalModsAndPush() throws {
        var character = makeTestCharacter()
        let optional = Modifier(bonusDice: 1, uses: 1, isOptionalToApply: true, description: "Lucky Charm")
        let alwaysOn = Modifier(bonusDice: 1, uses: 1, isOptionalToApply: false, description: "Battle Fury")
        character.modifiers = [optional, alwaysOn]

        let viewModel = TestFixtures.makeViewModel()
        let context = viewModel.getRollContext(for: makeTestAction(), with: character)

        XCTAssertEqual(context.baseProjection.finalDiceCount, 3)
        XCTAssertEqual(context.optionalModifiers.count, 2)
        let descriptions = context.optionalModifiers.map { $0.description }
        XCTAssertTrue(descriptions.contains("Lucky Charm"))
        XCTAssertTrue(descriptions.contains("Push Yourself"))
    }

    func testCalculateEffectiveProjection() throws {
        let vm = GameViewModel()
        let base = RollProjectionDetails(baseDiceCount: 2,
                                         finalDiceCount: 2,
                                         rawDicePool: 2,
                                         basePosition: .risky,
                                         finalPosition: .risky,
                                         baseEffect: .standard,
                                         finalEffect: .standard,
                                         notes: [])
        let mod = Modifier(bonusDice: 2, uses: 1, isOptionalToApply: true, description: "Elixir")
        let result = vm.calculateEffectiveProjection(baseProjection: base, applying: [mod])
        XCTAssertEqual(result.finalDiceCount, 4)
    }

    func testPushCancelsZeroRatingPenalty() throws {
        let vm = GameViewModel()
        let base = RollProjectionDetails(baseDiceCount: 0,
                                         finalDiceCount: 2,
                                         rawDicePool: 0,
                                         basePosition: .risky,
                                         finalPosition: .risky,
                                         baseEffect: .standard,
                                         finalEffect: .standard,
                                         notes: [])
        let push = Modifier(bonusDice: 1, uses: 1, isOptionalToApply: true, description: "Push")
        let result = vm.calculateEffectiveProjection(baseProjection: base, applying: [push])
        XCTAssertEqual(result.rawDicePool, 1)
        XCTAssertEqual(result.finalDiceCount, 1)
    }

    func testPerformActionConsumesModifier() throws {
        var character = makeTestCharacter()
        let mod = Modifier(bonusDice: 1, uses: 1, isOptionalToApply: true, description: "Charm")
        character.modifiers = [mod]
        let vm = TestFixtures.makeViewModel()
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = UUID()

        _ = vm.performAction(for: makeTestAction(),
                             with: character,
                             interactableID: nil,
                             usingDice: [6,6,6],
                             chosenOptionalModifierIDs: [mod.id])

        XCTAssertTrue(vm.gameState.party[0].modifiers.isEmpty)
    }

    func testPerformActionConsumesAlwaysOnModifierWhenItChangesCommittedRoll() throws {
        var character = makeTestCharacter()
        let mod = Modifier(bonusDice: 1, uses: 1, isOptionalToApply: false, description: "Battle Fury")
        character.modifiers = [mod]
        let vm = TestFixtures.makeViewModel()
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = UUID()

        _ = vm.performAction(
            for: makeTestAction(),
            with: character,
            interactableID: nil,
            usingDice: [6, 5, 4]
        )

        XCTAssertTrue(vm.gameState.party[0].modifiers.isEmpty)
    }

    func testPerformActionKeepsAlwaysOnModifierWhenItDoesNotMateriallyChangeRoll() throws {
        var character = makeTestCharacter()
        let mod = Modifier(improvePosition: true, uses: 1, isOptionalToApply: false, description: "Perfect Cover")
        character.modifiers = [mod]
        let vm = TestFixtures.makeViewModel()
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = UUID()

        let controlledAction = ActionOption(
            name: "Hold Position",
            actionType: "Skirmish",
            position: .controlled,
            effect: .standard
        )

        _ = vm.performAction(
            for: controlledAction,
            with: character,
            interactableID: nil,
            usingDice: [6, 5]
        )

        XCTAssertEqual(vm.gameState.party[0].modifiers.count, 1)
        XCTAssertEqual(vm.gameState.party[0].modifiers.first?.uses, 1)
    }

    func testActionSpecificArrayModifier() throws {
        let vm = GameViewModel()
        var character = makeTestCharacter()
        let mod = Modifier(bonusDice: 1, improveEffect: false, applicableActions: ["Skirmish", "Wreck"], uses: 1, isOptionalToApply: false, description: "Warhammer")
        character.modifiers = [mod]

        let action = makeTestAction() // Skirmish
        let proj = vm.calculateProjection(for: action, with: character)
        XCTAssertEqual(proj.finalDiceCount, 3)

        let other = ActionOption(name: "Smash", actionType: "Wreck", position: .risky, effect: .standard)
        let proj2 = vm.calculateProjection(for: other, with: character)
        XCTAssertEqual(proj2.finalDiceCount, 3)

        let off = ActionOption(name: "Sneak", actionType: "Prowl", position: .risky, effect: .standard)
        let proj3 = vm.calculateProjection(for: off, with: character)
        XCTAssertEqual(proj3.finalDiceCount, 2)
    }

    func testActionEffectPenalty() throws {
        let vm = TestFixtures.makeViewModel(scenario: "test_penalty")
        var character = makeTestCharacter()
        character.actions["Prowl"] = 2
        character.harm.lesser = [(familyId: "sprain", description: "Ankle Sprain")]

        let action = ActionOption(name: "Sneak", actionType: "Prowl", position: .risky, effect: .standard)
        let proj = vm.calculateProjection(for: action, with: character)

        XCTAssertEqual(proj.finalEffect, .limited)
    }

    func testBanActionMarksProjectionAndSuppressesOptionalModifiers() throws {
        let vm = TestFixtures.makeViewModel(scenario: "temple_of_terror")
        var character = makeTestCharacter()
        character.actions["Tinker"] = 2
        character.harm.moderate = [(familyId: "gear_damage", description: "Broken Tools")]
        character.modifiers = [
            Modifier(bonusDice: 1, uses: 1, isOptionalToApply: true, description: "Lucky Charm")
        ]

        let action = ActionOption(name: "Repair", actionType: "Tinker", position: .risky, effect: .standard)
        let context = vm.getRollContext(for: action, with: character)

        XCTAssertTrue(context.baseProjection.isActionBanned)
        XCTAssertEqual(context.baseProjection.rawDicePool, 0)
        XCTAssertEqual(context.baseProjection.finalDiceCount, 0)
        XCTAssertTrue(context.baseProjection.notes.contains { $0.contains("Broken Tools") })
        XCTAssertTrue(context.optionalModifiers.isEmpty)
    }

    func testCalculateEffectiveProjectionCannotOverrideActionBan() throws {
        let vm = GameViewModel()
        let base = RollProjectionDetails(baseDiceCount: 2,
                                         finalDiceCount: 0,
                                         rawDicePool: 0,
                                         basePosition: .risky,
                                         finalPosition: .risky,
                                         baseEffect: .standard,
                                         finalEffect: .standard,
                                         notes: ["(Action banned by Broken Tools)"],
                                         isActionBanned: true)
        let mod = Modifier(bonusDice: 2, uses: 1, isOptionalToApply: true, description: "Elixir")
        let result = vm.calculateEffectiveProjection(baseProjection: base, applying: [mod])

        XCTAssertTrue(result.isActionBanned)
        XCTAssertEqual(result.rawDicePool, 0)
        XCTAssertEqual(result.finalDiceCount, 0)
    }

    func testPerformActionReturnsCannotForBannedAction() throws {
        let vm = TestFixtures.makeViewModel(scenario: "temple_of_terror")
        var character = makeTestCharacter()
        character.actions["Tinker"] = 2
        character.harm.moderate = [(familyId: "gear_damage", description: "Broken Tools")]

        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = UUID()

        let action = ActionOption(name: "Repair", actionType: "Tinker", position: .risky, effect: .standard)
        let result = vm.performAction(for: action,
                                      with: character,
                                      interactableID: nil,
                                      usingDice: [6, 6])

        XCTAssertEqual(result.outcome, "Cannot")
        XCTAssertEqual(result.highestRoll, 0)
        XCTAssertTrue(result.consequences.contains("Broken Tools"))
        XCTAssertNil(result.actualDiceRolled)
    }

    func testTagConditionalModifier() throws {
        let vm = GameViewModel()
        var character = makeTestCharacter()
        let mod = Modifier(bonusDice: 1, improveEffect: true, applicableActions: ["Skirmish"], requiredTag: "Flora", uses: 1, isOptionalToApply: false, description: "Herbicide")
        character.modifiers = [mod]

        let action = makeTestAction()
        let base = vm.calculateProjection(for: action, with: character, interactableTags: [])
        XCTAssertEqual(base.finalDiceCount, 2)

        let tagged = vm.calculateProjection(for: action, with: character, interactableTags: ["Flora"])
        XCTAssertEqual(tagged.finalDiceCount, 3)
        XCTAssertEqual(tagged.finalEffect, .great)
    }

    func testTagConditionalPenalty() throws {
        let vm = TestFixtures.makeViewModel(scenario: "test_tag_penalty")
        var character = makeTestCharacter()
        character.actions["Tinker"] = 2
        character.harm.lesser = [(familyId: "flora_allergy", description: "Allergic Reaction")]

        let action = ActionOption(name: "Clear Weeds", actionType: "Tinker", position: .risky, effect: .standard)
        let noTagProj = vm.calculateProjection(for: action, with: character, interactableTags: [])
        XCTAssertEqual(noTagProj.finalDiceCount, 2)

        let tagProj = vm.calculateProjection(for: action, with: character, interactableTags: ["Flora"])
        XCTAssertEqual(tagProj.finalDiceCount, 1)
    }

    func testTreasureModifierForSpecificAction() throws {
        let vm = GameViewModel()
        var character = makeTestCharacter()
        let mod = Modifier(bonusDice: 1, applicableToAction: "Tinker", uses: 1, isOptionalToApply: true, description: "Scrap Parts")
        let treasure = Treasure(id: "test_scrap", name: "Scrap", description: "", grantedModifier: mod)
        character.treasures = [treasure]
        character.actions["Tinker"] = 1

        let action = ActionOption(name: "Repair", actionType: "Tinker", position: .risky, effect: .standard)
        let context = vm.getRollContext(for: action, with: character)

        XCTAssertTrue(context.optionalModifiers.contains { $0.description == "Scrap Parts" })
    }

    func testTreasureRemovedWhenUsesDepleted() throws {
        var character = makeTestCharacter()
        let mod = Modifier(bonusDice: 1, uses: 1, isOptionalToApply: true, description: "Charm")
        let treasure = Treasure(id: "test_charm", name: "Charm Stone", description: "", grantedModifier: mod)
        character.modifiers = [mod]
        character.treasures = [treasure]
        let vm = TestFixtures.makeViewModel()
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = UUID()

        _ = vm.performAction(for: makeTestAction(),
                             with: character,
                             interactableID: nil,
                             usingDice: [6],
                             chosenOptionalModifierIDs: [mod.id])

        XCTAssertTrue(vm.gameState.party[0].modifiers.isEmpty)
        XCTAssertTrue(vm.gameState.party[0].treasures.isEmpty)
    }

    func testPerformActionCanUseOptionalTreasureModifierFromRollContext() throws {
        let vm = GameViewModel()
        var character = makeTestCharacter()
        character.actions["Tinker"] = 0

        let mod = Modifier(bonusDice: 1, applicableToAction: "Tinker", uses: 1, isOptionalToApply: true, description: "Scrap Parts")
        let treasure = Treasure(id: "test_scrap", name: "Scrap", description: "", grantedModifier: mod)
        character.treasures = [treasure]

        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = UUID()

        let action = ActionOption(name: "Repair", actionType: "Tinker", position: .risky, effect: .standard)
        let context = vm.getRollContext(for: action, with: character)
        guard let treasureModifier = context.optionalModifiers.first(where: { $0.description == "Scrap Parts" }) else {
            XCTFail("Expected treasure modifier to be available")
            return
        }

        let result = vm.performAction(for: action,
                                      with: character,
                                      interactableID: nil,
                                      usingDice: [1, 6],
                                      chosenOptionalModifierIDs: [treasureModifier.id])

        XCTAssertEqual(result.outcome, "Full Success!")
        XCTAssertEqual(vm.gameState.party[0].stress, 0)
    }

    func testPushStressCostIncludesActiveHarmPenalty() throws {
        let vm = TestFixtures.makeViewModel()
        var character = makeTestCharacter()
        character.stress = 6
        character.harm.lesser = [(familyId: "mental_anguish", description: "Unease")]
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = UUID()

        let action = makeTestAction()
        let context = vm.getRollContext(for: action, with: character)
        guard let push = context.optionalModifiers.first(where: { $0.description == "Push Yourself" }) else {
            XCTFail("Expected Push Yourself option to be available")
            return
        }
        XCTAssertEqual(push.remainingUses, "Costs 3 Stress")

        _ = vm.performAction(for: action,
                             with: character,
                             interactableID: nil,
                             usingDice: [6, 5, 4],
                             chosenOptionalModifierIDs: [push.id])

        XCTAssertEqual(vm.gameState.party[0].stress, 9)
    }

    func testActionResolverGroupActionAppliesLeaderStressAndConsequences() throws {
        let runtime = ScenarioRuntime()
        let resolver = ActionResolver(
            runtime: runtime,
            rollRules: RollRulesEngine(),
            debugLogging: false
        )

        let leader = Character(
            id: UUID(),
            name: "Leader",
            characterClass: "Rogue",
            stress: 0,
            harm: HarmState(),
            actions: ["Skirmish": 2]
        )
        let ally = Character(
            id: UUID(),
            name: "Ally",
            characterClass: "Guardian",
            stress: 0,
            harm: HarmState(),
            actions: ["Skirmish": 1]
        )
        let groupAction = ActionOption(
            name: "Coordinated Strike",
            actionType: "Skirmish",
            position: .risky,
            effect: .standard,
            isGroupAction: true,
            outcomes: [.success: [.setScenarioFlag("group_success")]]
        )

        var gameState = GameState(party: [leader, ally])
        let result = resolver.performAction(
            for: groupAction,
            with: leader,
            interactableID: nil,
            partyMovementMode: .grouped,
            groupRolls: [[6], [2]],
            in: &gameState
        )

        XCTAssertEqual(result.outcome, "Full Success!")
        XCTAssertEqual(gameState.party[0].stress, 1)
        XCTAssertEqual(gameState.scenarioFlags["group_success"], true)
        XCTAssertTrue(result.consequences.contains("Leader takes 1 Stress"))
    }

    func testActionResolverGroupActionOnlyUsesCharactersInSameRoom() throws {
        let runtime = ScenarioRuntime()
        let resolver = ActionResolver(
            runtime: runtime,
            rollRules: RollRulesEngine(),
            debugLogging: false
        )

        let sharedNodeID = UUID()
        let remoteNodeID = UUID()
        let leader = Character(
            id: UUID(),
            name: "Leader",
            characterClass: "Rogue",
            stress: 0,
            harm: HarmState(),
            actions: ["Skirmish": 2]
        )
        let ally = Character(
            id: UUID(),
            name: "Ally",
            characterClass: "Guardian",
            stress: 0,
            harm: HarmState(),
            actions: ["Skirmish": 1]
        )
        let remote = Character(
            id: UUID(),
            name: "Remote",
            characterClass: "Sniper",
            stress: 0,
            harm: HarmState(),
            actions: ["Skirmish": 3]
        )
        let groupAction = ActionOption(
            name: "Hold the Line",
            actionType: "Skirmish",
            position: .risky,
            effect: .standard,
            isGroupAction: true,
            outcomes: [
                .success: [.setScenarioFlag("should_not_happen")],
                .failure: [.setScenarioFlag("local_failure")]
            ]
        )

        var gameState = GameState(party: [leader, ally, remote])
        gameState.characterLocations = [
            leader.id.uuidString: sharedNodeID,
            ally.id.uuidString: sharedNodeID,
            remote.id.uuidString: remoteNodeID
        ]

        let result = resolver.performAction(
            for: groupAction,
            with: leader,
            interactableID: nil,
            partyMovementMode: .solo,
            groupRolls: [[2], [2], [6]],
            in: &gameState
        )

        XCTAssertEqual(result.outcome, "Failure.")
        XCTAssertEqual(gameState.party[0].stress, 1)
        XCTAssertEqual(gameState.scenarioFlags["local_failure"], true)
        XCTAssertNil(gameState.scenarioFlags["should_not_happen"])
    }
}
