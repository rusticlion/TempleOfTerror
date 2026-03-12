import Foundation
import SwiftUI

@MainActor
final class ScenarioCatalogViewModel: ObservableObject {
    @Published private(set) var availableScenarios: [ResolvedScenarioCatalogEntry] = []

    private let store: ScenarioCatalogStore

    init(store: ScenarioCatalogStore = ScenarioCatalogStore()) {
        self.store = store
        refresh()
    }

    var preferredScenario: ResolvedScenarioCatalogEntry? {
        availableScenarios.first(where: { $0.recommendedStart && $0.isAccessibleWithoutTestingUnlock })
            ?? availableScenarios.first(where: \.isAccessibleWithoutTestingUnlock)
            ?? availableScenarios.first(where: \.isStartable)
    }

    var testingAccessScenarios: [ResolvedScenarioCatalogEntry] {
        availableScenarios.filter(\.isTestingUnlocked)
    }

    var hasTestingAccessOverrides: Bool {
        !testingAccessScenarios.isEmpty
    }

    func refresh() {
        availableScenarios = store.loadScenarios()
    }

    func enableTestingAccess(for scenario: ResolvedScenarioCatalogEntry) {
        guard scenario.canEnableTestingAccess else { return }
        store.enableTestingAccess(for: scenario.catalogEntry.scenarioID)
        refresh()
    }

    func disableTestingAccess(for scenario: ResolvedScenarioCatalogEntry) {
        guard scenario.isTestingUnlocked else { return }
        store.disableTestingAccess(for: scenario.catalogEntry.scenarioID)
        refresh()
    }

    func resetTestingAccess() {
        store.resetTestingAccess()
        refresh()
    }
}
