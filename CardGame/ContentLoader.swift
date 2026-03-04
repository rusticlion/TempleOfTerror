import Foundation

/// Basic information about a scenario.
struct ScenarioManifest: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var description: String
    var entryNode: String?
    /// Name of a JSON file defining a fixed map for this scenario.
    var mapFile: String?
    var partySize: Int?
    var nativeArchetypeIDs: [String]?
    var stressOverflowHarmFamilyID: String?
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
    let archetypeTemplates: [ArchetypeDefinition]
    let archetypeDict: [String: ArchetypeDefinition]
    let eventTemplates: [ScenarioEvent]
    let eventDict: [String: ScenarioEvent]

    /// Initialize a loader for a specific scenario directory.
    init(scenario: String = "tomb") {
        self.scenarioName = scenario
        self.scenarioManifest = Self.loadManifest(for: scenario)
        self.interactableTemplates = Self.load("interactables.json", for: scenario)
        self.harmFamilies = Self.loadMergedByID("harm_families.json", for: scenario)
        self.harmFamilyDict = Dictionary(uniqueKeysWithValues: harmFamilies.map { ($0.id, $0) })
        self.treasureTemplates = Self.load("treasures.json", for: scenario)
        self.clockTemplates = Self.load("clocks.json", for: scenario)
        self.archetypeTemplates = Self.loadScenarioOnly("archetypes.json", for: scenario)
        self.archetypeDict = Dictionary(uniqueKeysWithValues: archetypeTemplates.map { ($0.id, $0) })
        self.eventTemplates = Self.loadOptional("events.json", for: scenario)
        self.eventDict = Dictionary(uniqueKeysWithValues: eventTemplates.map { ($0.id, $0) })
    }

    private static func scenarioURL(for filename: String, scenario: String) -> URL? {
        Bundle.main.url(
            forResource: filename,
            withExtension: nil,
            subdirectory: "Content/Scenarios/\(scenario)"
        )
    }

    private static func globalURL(for filename: String) -> URL? {
        Bundle.main.url(
            forResource: filename,
            withExtension: nil,
            subdirectory: "Content"
        )
    }

    private static func preferredURL(for filename: String, scenario: String) -> URL? {
        scenarioURL(for: filename, scenario: scenario) ?? globalURL(for: filename)
    }

    private static func loadManifest(for scenario: String) -> ScenarioManifest? {
        guard let url = preferredURL(for: "scenario.json", scenario: scenario) else { return nil }
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
        guard let url = preferredURL(for: filename, scenario: scenario) else {
            print("Failed to locate \(filename) for scenario \(scenario)")
            return []
        }
        return decodeCollection(T.self, from: url, filename: filename, scenario: scenario) ?? []
    }

    private static func loadScenarioOnly<T: Decodable>(_ filename: String, for scenario: String) -> [T] {
        guard let url = scenarioURL(for: filename, scenario: scenario) else {
            print("Failed to locate scenario-local \(filename) for scenario \(scenario)")
            return []
        }
        return decodeCollection(T.self, from: url, filename: filename, scenario: scenario) ?? []
    }

    private static func loadMergedByID<T: Decodable & Identifiable>(
        _ filename: String,
        for scenario: String
    ) -> [T] where T.ID == String {
        let globalValues = globalURL(for: filename).flatMap {
            decodeCollection(T.self, from: $0, filename: filename, scenario: "global")
        } ?? []
        let scenarioValues = scenarioURL(for: filename, scenario: scenario).flatMap {
            decodeCollection(T.self, from: $0, filename: filename, scenario: scenario)
        } ?? []

        var mergedByID: [String: T] = [:]
        var order: [String] = []

        for value in globalValues + scenarioValues {
            if mergedByID[value.id] == nil {
                order.append(value.id)
            }
            mergedByID[value.id] = value
        }

        return order.compactMap { mergedByID[$0] }
    }

    private static func decodeCollection<T: Decodable>(
        _ type: T.Type,
        from url: URL,
        filename: String,
        scenario: String
    ) -> [T]? {
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
                return nil
            }
        } catch let error as DecodingError {
            print("Failed to decode \(filename) for scenario \(scenario): Decoding Error: \(error.localizedDescription)\nPath: \(error.pathDescription)\nDebug Description: \(error.contextDebugDescription)")
            return nil
        } catch {
            print("Failed to decode \(filename) for scenario \(scenario): \(error)")
            return nil
        }
    }

    private static func loadOptional<T: Decodable>(_ filename: String, for scenario: String) -> [T] {
        guard let url = preferredURL(for: filename, scenario: scenario) else {
            return []
        }
        return decodeCollection(T.self, from: url, filename: filename, scenario: scenario) ?? []
    }

    /// Load a predefined DungeonMap from the given file name within this scenario.
    func loadMap(named file: String) -> DungeonMap? {
        guard let url = Self.preferredURL(for: file, scenario: scenarioName) else {
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
