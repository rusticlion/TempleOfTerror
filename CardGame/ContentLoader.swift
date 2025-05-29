import Foundation

class ContentLoader {
    static let shared = ContentLoader()

    let interactableTemplates: [Interactable]
    let harmFamilies: [HarmFamily]
    let harmFamilyDict: [String: HarmFamily]
    let treasureTemplates: [Treasure]

    private init() {
        self.interactableTemplates = Self.load("interactables.json")
        self.harmFamilies = Self.load("harm_families.json")
        self.harmFamilyDict = Dictionary(uniqueKeysWithValues: harmFamilies.map { ($0.id, $0) })
        self.treasureTemplates = Self.load("treasures.json")
    }

    private static func load<T: Decodable>(_ filename: String) -> [T] {
        // The JSON files are stored within the "Content" folder reference in the
        // Xcode project. When bundled, this folder becomes a subdirectory in the
        // app bundle, so we must specify it when looking up the resource.
        guard let url = Bundle.main.url(forResource: filename,
                                        withExtension: nil,
                                        subdirectory: "Content") else {
            print("Failed to locate \(filename)")
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
