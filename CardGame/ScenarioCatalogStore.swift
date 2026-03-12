import Foundation

struct ScenarioCatalogStore {
    let bundle: Bundle
    let entitlementStore: EntitlementStore

    init(
        bundle: Bundle = .main,
        entitlementStore: EntitlementStore = EntitlementStore()
    ) {
        self.bundle = bundle
        self.entitlementStore = entitlementStore
    }

    func loadScenarios() -> [ResolvedScenarioCatalogEntry] {
        ContentLoader.availableScenarioCatalogEntries(
            bundle: bundle,
            testingUnlockedScenarioIDs: entitlementStore.loadTestingUnlockedScenarioIDs()
        )
    }

    func enableTestingAccess(for scenarioID: String) {
        entitlementStore.setTestingUnlocked(true, forScenarioID: scenarioID)
    }

    func disableTestingAccess(for scenarioID: String) {
        entitlementStore.setTestingUnlocked(false, forScenarioID: scenarioID)
    }

    func resetTestingAccess() {
        entitlementStore.resetTestingUnlockedScenarioIDs()
    }
}
