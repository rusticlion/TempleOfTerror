import Foundation

/// Basic information about a scenario.
struct ScenarioManifest: Codable {
    var id: String
    var title: String
    var description: String
    var entryNode: String?
}

class ContentLoader {
    /// Shared loader using the default scenario ("tomb").
    static let shared = ContentLoader()

    let scenarioName: String
    let scenarioManifest: ScenarioManifest?
    let interactableTemplates: [Interactable]
    let harmFamilies: [HarmFamily]
    let harmFamilyDict: [String: HarmFamily]
    let treasureTemplates: [Treasure]

    /// Initialize a loader for a specific scenario directory.
    init(scenario: String = "tomb") {
        self.scenarioName = scenario
        self.scenarioManifest = Self.loadManifest(for: scenario)
        self.interactableTemplates = Self.load("interactables.json", for: scenario)
        self.harmFamilies = Self.load("harm_families.json", for: scenario)
        self.harmFamilyDict = Dictionary(uniqueKeysWithValues: harmFamilies.map { ($0.id, $0) })
        self.treasureTemplates = Self.load("treasures.json", for: scenario)
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

    private static func load<T: Decodable>(_ filename: String, for scenario: String) -> [T] {
        guard let url = url(for: filename, scenario: scenario) else {
            print("Failed to locate \(filename) for scenario \(scenario)")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            if let array = try? decoder.decode([T].self, from: data) {
                return array
            } else if let dict = try? decoder.decode([String: [T]].self, from: data) {
                return dict.flatMap { $0.value }
            } else {
                print("Failed to decode \(filename): unexpected format")
                return []
            }
        } catch {
            print("Failed to decode \(filename): \(error)")
            return []
        }
    }
}
