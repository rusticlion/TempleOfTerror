import SwiftUI

@main
struct DiceDelverApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .tint(Theme.gold)
        }
    }
}

private struct AppRootView: View {
    var body: some View {
        Group {
#if DEBUG
            if let configuration = DebugLaunchConfiguration.current {
                DebugLaunchRootView(configuration: configuration)
            } else {
                MainMenuView()
            }
#else
            MainMenuView()
#endif
        }
    }
}

#if DEBUG
private struct DebugLaunchConfiguration {
    enum Screen: String {
        case content
        case map
    }

    enum State: String {
        case fresh
        case pressure
        case solo
        case split
    }

    let screen: Screen
    let scenarioID: String
    let state: State

    static var current: DebugLaunchConfiguration? {
        let env = ProcessInfo.processInfo.environment
        guard let rawScreen = env["CODEX_DEBUG_SCREEN"],
              let screen = Screen(rawValue: rawScreen) else {
            return nil
        }

        let scenarioID = env["CODEX_DEBUG_SCENARIO"] ?? "temple_of_terror"
        let state = State(rawValue: env["CODEX_DEBUG_STATE"] ?? "fresh") ?? .fresh
        return DebugLaunchConfiguration(screen: screen, scenarioID: scenarioID, state: state)
    }
}

private struct DebugLaunchRootView: View {
    let configuration: DebugLaunchConfiguration
    @StateObject private var viewModel: GameViewModel

    init(configuration: DebugLaunchConfiguration) {
        self.configuration = configuration
        _viewModel = StateObject(
            wrappedValue: Self.makeViewModel(
                scenarioID: configuration.scenarioID,
                state: configuration.state
            )
        )
    }

    var body: some View {
        Group {
            switch configuration.screen {
            case .content:
                ContentView(viewModel: viewModel)
            case .map:
                MapView(viewModel: viewModel)
            }
        }
    }

    private static func makeViewModel(
        scenarioID: String,
        state: DebugLaunchConfiguration.State
    ) -> GameViewModel {
        let viewModel = GameViewModel(startNewWithScenario: scenarioID)

        switch state {
        case .fresh:
            break
        case .pressure:
            if !viewModel.gameState.activeClocks.isEmpty {
                let progress = max(1, min(2, viewModel.gameState.activeClocks[0].segments))
                viewModel.gameState.activeClocks[0].progress = progress
            }
        case .solo:
            viewModel.partyMovementMode = .solo
        case .split:
            viewModel.partyMovementMode = .solo
            if let characterID = viewModel.gameState.party.first(where: { !$0.isDefeated })?.id,
               let node = viewModel.node(for: characterID),
               let connection = node.connections.first(where: \.isUnlocked) ?? node.connections.first {
                viewModel.move(characterID: characterID, to: connection)
            }
        }

        if let fixedDice = ProcessInfo.processInfo.environment["CODEX_DEBUG_FIXED_DICE"],
           viewModel.setDebugFixedDice(from: fixedDice) {
            viewModel.debugFixedDiceEnabled = true
        }

        return viewModel
    }
}
#endif
