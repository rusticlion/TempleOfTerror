import Foundation

/// Basic information about a scenario.
struct ScenarioManifest: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var description: String
    var entryNode: String?
    /// Name of a JSON file defining a fixed map for this scenario.
    var mapFile: String?
}

extension DecodingError {
    /// A readable representation of the coding path where the decoding failed.
    var pathDescription: String {
        switch self {
        case .dataCorrupted(let context),
             .keyNotFound(_, let context),
             .typeMismatch(_, let context),
             .valueNotFound(_, let context):
            return context.codingPath.map { $0.stringValue }.joined(separator: ".")
        @unknown default:
            return ""
        }
    }

    /// The debug description extracted from the underlying error context.
    var contextDebugDescription: String {
        switch self {
        case .dataCorrupted(let context),
             .keyNotFound(_, let context),
             .typeMismatch(_, let context),
             .valueNotFound(_, let context):
            return context.debugDescription
        @unknown default:
            return localizedDescription
        }
    }
}

class ContentLoader {
    /// Shared loader using the default scenario ("tomb"). This can be
    /// reassigned when the player selects a different scenario from the
    /// main menu.
    static var shared = ContentLoader()

    let scenarioName: String
    let scenarioManifest: ScenarioManifest?
    let interactableTemplates: [Interactable]
    let harmFamilies: [HarmFamily]
    let harmFamilyDict: [String: HarmFamily]
    let treasureTemplates: [Treasure]
    let clockTemplates: [GameClock]

    /// Initialize a loader for a specific scenario directory.
    init(scenario: String = "tomb") {
        self.scenarioName = scenario
        self.scenarioManifest = Self.loadManifest(for: scenario)
        self.interactableTemplates = Self.load("interactables.json", for: scenario)
        self.harmFamilies = Self.load("harm_families.json", for: scenario)
        self.harmFamilyDict = Dictionary(uniqueKeysWithValues: harmFamilies.map { ($0.id, $0) })
        self.treasureTemplates = Self.load("treasures.json", for: scenario)
        self.clockTemplates = Self.load("clocks.json", for: scenario)
    }

    private static func url(for filename: String, scenario: String) -> URL? {
        if let url = Bundle.main.url(forResource: filename,
                                     withExtension: nil,
                                     subdirectory: "Content/Scenarios/\(scenario)") {
            return url
        }
        return Bundle.main.url(forResource: filename,
                               withExtension: nil,
                               subdirectory: "Content")
    }

    private static func loadManifest(for scenario: String) -> ScenarioManifest? {
        guard let url = url(for: "scenario.json", scenario: scenario) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(ScenarioManifest.self, from: data)
        } catch {
            print("Failed to decode scenario.json for \(scenario): \(error)")
            return nil
        }
    }

    /// Retrieve all scenario manifests packaged with the app.
    static func availableScenarios() -> [ScenarioManifest] {
        guard let baseURL = Bundle.main.resourceURL?.appendingPathComponent("Content/Scenarios") else {
            return []
        }
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return []
        }
        var manifests: [ScenarioManifest] = []
        for dir in contents where dir.hasDirectoryPath {
            let name = dir.lastPathComponent
            if let url = Bundle.main.url(forResource: "scenario.json", withExtension: nil, subdirectory: "Content/Scenarios/\(name)"),
               let data = try? Data(contentsOf: url),
               let manifest = try? JSONDecoder().decode(ScenarioManifest.self, from: data) {
                manifests.append(manifest)
            }
        }
        return manifests.sorted { $0.title < $1.title }
    }

    private static func load<T: Decodable>(_ filename: String, for scenario: String) -> [T] {
        guard let url = url(for: filename, scenario: scenario) else {
            print("Failed to locate \(filename) for scenario \(scenario)")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            // Explicitly use default keys so optional fields like `conditions`
            // in `Consequence` decode without additional configuration.
            decoder.keyDecodingStrategy = .useDefaultKeys
            if let array = try? decoder.decode([T].self, from: data) {
                return array
            } else if let dict = try? decoder.decode([String: [T]].self, from: data) {
                return dict.flatMap { $0.value }
            } else {
                print("Failed to decode \(filename): unexpected format")
                return []
            }
        } catch let error as DecodingError {
            print("Failed to decode \(filename) for scenario \(scenario): Decoding Error: \(error.localizedDescription)\nPath: \(error.pathDescription)\nDebug Description: \(error.contextDebugDescription)")
            return []
        } catch {
            print("Failed to decode \(filename) for scenario \(scenario): \(error)")
            return []
        }
    }

    /// Load a predefined DungeonMap from the given file name within this scenario.
    func loadMap(named file: String) -> DungeonMap? {
        guard let url = Self.url(for: file, scenario: scenarioName) else {
            print("Failed to locate map file \(file) for scenario \(scenarioName)")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(DungeonMap.self, from: data)
        } catch {
            print("Failed to decode map file \(file): \(error)")
            return nil
        }
    }
}
