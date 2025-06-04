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
}
