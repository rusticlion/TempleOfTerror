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
