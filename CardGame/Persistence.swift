import Foundation

protocol GameStateStoring {
    var saveURL: URL { get }
    func saveExists() -> Bool
    func save(_ gameState: GameState) throws
    func load() throws -> GameState
    func delete() throws
}

struct SaveGameStore: GameStateStoring {
    let saveURL: URL

    init(saveURL: URL = SaveGameStore.defaultSaveURL) {
        self.saveURL = saveURL
    }

    static var defaultSaveURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("savegame.json")
    }

    func saveExists() -> Bool {
        FileManager.default.fileExists(atPath: saveURL.path)
    }

    func save(_ gameState: GameState) throws {
        let directory = saveURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
        try gameState.save(to: saveURL)
    }

    func load() throws -> GameState {
        try GameState.load(from: saveURL)
    }

    func delete() throws {
        guard saveExists() else { return }
        try FileManager.default.removeItem(at: saveURL)
    }
}

protocol ScenarioEntitlementStoring {
    func loadTestingUnlockedScenarioIDs() -> Set<String>
    func saveTestingUnlockedScenarioIDs(_ scenarioIDs: Set<String>)
    func setTestingUnlocked(_ isUnlocked: Bool, forScenarioID scenarioID: String)
    func resetTestingUnlockedScenarioIDs()
}

struct EntitlementStore: ScenarioEntitlementStoring {
    let userDefaults: UserDefaults
    let storageKey: String

    init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = "scenarioTestingUnlockedIDs"
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    func loadTestingUnlockedScenarioIDs() -> Set<String> {
        let storedScenarioIDs = userDefaults.stringArray(forKey: storageKey) ?? []
        return Set(
            storedScenarioIDs.compactMap { rawID in
                let trimmedID = rawID.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmedID.isEmpty ? nil : trimmedID
            }
        )
    }

    func saveTestingUnlockedScenarioIDs(_ scenarioIDs: Set<String>) {
        userDefaults.set(scenarioIDs.sorted(), forKey: storageKey)
    }

    func setTestingUnlocked(_ isUnlocked: Bool, forScenarioID scenarioID: String) {
        let trimmedID = scenarioID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedID.isEmpty else { return }

        var unlockedScenarioIDs = loadTestingUnlockedScenarioIDs()
        if isUnlocked {
            unlockedScenarioIDs.insert(trimmedID)
        } else {
            unlockedScenarioIDs.remove(trimmedID)
        }
        saveTestingUnlockedScenarioIDs(unlockedScenarioIDs)
    }

    func resetTestingUnlockedScenarioIDs() {
        userDefaults.removeObject(forKey: storageKey)
    }
}
