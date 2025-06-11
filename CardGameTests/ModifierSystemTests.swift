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
        ContentLoader.shared = ContentLoader()
        var character = makeTestCharacter()
        let optional = Modifier(bonusDice: 1, uses: 1, isOptionalToApply: true, description: "Lucky Charm")
        let alwaysOn = Modifier(bonusDice: 1, uses: 1, isOptionalToApply: false, description: "Battle Fury")
        character.modifiers = [optional, alwaysOn]

        let viewModel = GameViewModel()
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
        ContentLoader.shared = ContentLoader()
        var character = makeTestCharacter()
        let mod = Modifier(bonusDice: 1, uses: 1, isOptionalToApply: true, description: "Charm")
        character.modifiers = [mod]
        let vm = GameViewModel()
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = UUID()

        _ = vm.performAction(for: makeTestAction(),
                             with: character,
                             interactableID: nil,
                             usingDice: [6,6,6],
                             chosenOptionalModifierIDs: [mod.id])

        XCTAssertTrue(vm.gameState.party[0].modifiers.isEmpty)
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
        ContentLoader.shared = ContentLoader(scenario: "test_penalty")
        let vm = GameViewModel()
        var character = makeTestCharacter()
        character.actions["Prowl"] = 2
        character.harm.lesser = [(familyId: "sprain", description: "Ankle Sprain")]

        let action = ActionOption(name: "Sneak", actionType: "Prowl", position: .risky, effect: .standard)
        let proj = vm.calculateProjection(for: action, with: character)

        XCTAssertEqual(proj.finalEffect, .limited)
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
        ContentLoader.shared = ContentLoader(scenario: "test_tag_penalty")
        let vm = GameViewModel()
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
        ContentLoader.shared = ContentLoader()
        var character = makeTestCharacter()
        let mod = Modifier(bonusDice: 1, uses: 1, isOptionalToApply: true, description: "Charm")
        let treasure = Treasure(id: "test_charm", name: "Charm Stone", description: "", grantedModifier: mod)
        character.modifiers = [mod]
        character.treasures = [treasure]
        let vm = GameViewModel()
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
}
