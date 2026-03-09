import XCTest
@testable import CardGame

final class StressOverflowTests: XCTestCase {
    private func makeViewModel(scenario: String = "tomb") -> GameViewModel {
        var runtime = ScenarioRuntime()
        _ = runtime.activateScenario(named: scenario)
        let viewModel = GameViewModel(runtime: runtime)
        viewModel.gameState.scenarioName = scenario
        return viewModel
    }

    func testOverflowAppliesMentalFraying() throws {
        var character = Character(id: UUID(),
                                  name: "Tester",
                                  characterClass: "Rogue",
                                  stress: 8,
                                  harm: HarmState(),
                                  actions: ["Study": 1],
                                  treasures: [],
                                  modifiers: [])
        let vm = makeViewModel()
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = UUID()

        vm.pushYourself(forCharacter: character)
        XCTAssertEqual(vm.gameState.party[0].stress, 0)
        XCTAssertEqual(vm.gameState.party[0].harm.lesser.count, 1)
        XCTAssertEqual(vm.gameState.party[0].harm.lesser[0].familyId, "mental_fraying")
    }
}
