import Foundation
@testable import CardGame

enum TestFixtures {
    static var scenariosRootURL: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Content/Scenarios", isDirectory: true)
    }

    static var contentRootURL: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Content", isDirectory: true)
    }

    static func makeViewModel(
        scenario: String = RuntimeDefaults.defaultScenarioID,
        saveStore: SaveGameStore = SaveGameStore()
    ) -> GameViewModel {
        let viewModel = GameViewModel(
            dependencies: .configuredForScenario(
                scenario,
                saveStore: saveStore
            )
        )
        viewModel.gameState.scenarioName = scenario
        return viewModel
    }

    static func makeRuntime(
        scenario: String = RuntimeDefaults.defaultScenarioID
    ) -> ScenarioRuntime {
        var runtime = ScenarioRuntime()
        _ = runtime.activateScenario(named: scenario)
        return runtime
    }

    static func makeTemporarySaveStore() -> (store: SaveGameStore, directory: URL) {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let saveURL = tempDirectory.appendingPathComponent("savegame.json")
        return (SaveGameStore(saveURL: saveURL), tempDirectory)
    }
}
